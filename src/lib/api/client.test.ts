import { ApiError } from "./errors";

jest.mock("./token-storage", () => ({
  getAccessToken: jest.fn(),
  getRefreshToken: jest.fn(),
  setTokens: jest.fn(),
  clearTokens: jest.fn(),
}));

import { getAccessToken, getRefreshToken, setTokens } from "./token-storage";
import { apiClient } from "./client";

function jsonResponse(body: unknown, init: { status?: number; headers?: Record<string, string> } = {}) {
  return new Response(JSON.stringify(body), {
    status: init.status ?? 200,
    headers: { "content-type": "application/json", ...init.headers },
  });
}

describe("apiClient", () => {
  beforeEach(() => {
    jest.clearAllMocks();
    (getAccessToken as jest.Mock).mockResolvedValue(null);
    (getRefreshToken as jest.Mock).mockResolvedValue(null);
    globalThis.fetch = jest.fn();
  });

  it("sends a GET request without an Authorization header when no token is stored", async () => {
    (globalThis.fetch as jest.Mock).mockResolvedValueOnce(jsonResponse({ ok: true }));

    const result = await apiClient.get<{ ok: boolean }>("me/dashboard");

    expect(result).toEqual({ ok: true });
    const [, init] = (globalThis.fetch as jest.Mock).mock.calls[0];
    expect((init.headers as Headers).has("Authorization")).toBe(false);
  });

  it("sends the request without an Authorization header when reading the token throws", async () => {
    (getAccessToken as jest.Mock).mockRejectedValueOnce(new Error("Keychain locked"));
    (globalThis.fetch as jest.Mock).mockResolvedValueOnce(jsonResponse({ ok: true }));

    const result = await apiClient.get<{ ok: boolean }>("me/dashboard");

    expect(result).toEqual({ ok: true });
    const [, init] = (globalThis.fetch as jest.Mock).mock.calls[0];
    expect((init.headers as Headers).has("Authorization")).toBe(false);
  });

  it("attaches a Bearer token when one is stored", async () => {
    (getAccessToken as jest.Mock).mockResolvedValue("token-abc");
    (globalThis.fetch as jest.Mock).mockResolvedValueOnce(jsonResponse({ ok: true }));

    await apiClient.get("me/dashboard");

    const [, init] = (globalThis.fetch as jest.Mock).mock.calls[0];
    expect((init.headers as Headers).get("Authorization")).toBe("Bearer token-abc");
  });

  it("falls back to a generic message when the error body is not JSON", async () => {
    (globalThis.fetch as jest.Mock).mockResolvedValueOnce(
      new Response("<html>Bad Gateway</html>", {
        status: 502,
        headers: { "content-type": "text/html" },
      }),
    );

    await expect(apiClient.get("me/dashboard")).rejects.toMatchObject({
      message: "Request failed with status 502",
      status: 502,
    });
  });

  it("preserves the backend's error code and requestId", async () => {
    (globalThis.fetch as jest.Mock).mockResolvedValueOnce(
      jsonResponse({ message: "Invalid", code: "VALIDATION_FAILED", requestId: "req-999" }, { status: 400 }),
    );

    await expect(apiClient.get("me/dashboard")).rejects.toMatchObject({
      code: "VALIDATION_FAILED",
      requestId: "req-999",
      status: 400,
    });
  });

  it("returns a 499 cancellation error and does not retry when the caller aborts", async () => {
    const callerController = new AbortController();
    (globalThis.fetch as jest.Mock).mockImplementationOnce((_url: string, init: { signal: AbortSignal }) => {
      const rejectAborted = (reject: (reason: unknown) => void) => {
        const err = new Error("Aborted");
        err.name = "AbortError";
        reject(err);
      };
      return new Promise((_resolve, reject) => {
        if (init.signal.aborted) return rejectAborted(reject);
        init.signal.addEventListener("abort", () => rejectAborted(reject));
      });
    });

    const promise = apiClient.get("me/slow", { signal: callerController.signal });
    callerController.abort();

    await expect(promise).rejects.toMatchObject({ status: 499, code: "REQUEST_CANCELLED" });
    expect(globalThis.fetch).toHaveBeenCalledTimes(1);
  });

  it("refreshes once on 401, retries with the fresh token attached, and only calls fetch twice", async () => {
    (getAccessToken as jest.Mock)
      .mockResolvedValueOnce("stale-token")
      .mockResolvedValueOnce("fresh-token");
    (getRefreshToken as jest.Mock).mockResolvedValue("refresh-abc");
    (globalThis.fetch as jest.Mock)
      .mockResolvedValueOnce(jsonResponse({ message: "Unauthorized" }, { status: 401 }))
      .mockResolvedValueOnce(jsonResponse({ accessToken: "fresh-token", refreshToken: "refresh-def" }))
      .mockResolvedValueOnce(jsonResponse({ ok: true }));

    const result = await apiClient.get<{ ok: boolean }>("me/dashboard");

    expect(result).toEqual({ ok: true });
    expect(globalThis.fetch).toHaveBeenCalledTimes(3);
    expect(setTokens).toHaveBeenCalledWith("fresh-token", "refresh-def");
    const [refreshUrl] = (globalThis.fetch as jest.Mock).mock.calls[1];
    expect(refreshUrl).toBe("http://localhost:8080/api/v1/auth/refresh");
    const [, finalInit] = (globalThis.fetch as jest.Mock).mock.calls[2];
    expect((finalInit.headers as Headers).get("Authorization")).toBe("Bearer fresh-token");
  });

  it("deduplicates concurrent 401s into a single refresh call", async () => {
    (getAccessToken as jest.Mock).mockResolvedValue("stale-token");
    (getRefreshToken as jest.Mock).mockResolvedValue("refresh-abc");
    // Both initial requests 401; the single deduped refresh succeeds; both retries then succeed.
    let unauthorizedCount = 0;
    (globalThis.fetch as jest.Mock).mockImplementation((url: string) => {
      if (String(url).includes("/auth/refresh"))
        return Promise.resolve(jsonResponse({ accessToken: "fresh-token", refreshToken: "refresh-def" }));
      unauthorizedCount += 1;
      if (unauthorizedCount <= 2) return Promise.resolve(jsonResponse({ message: "Unauthorized" }, { status: 401 }));
      return Promise.resolve(jsonResponse({ ok: true }));
    });

    const [r1, r2] = await Promise.all([apiClient.get("me/a"), apiClient.get("me/b")]);

    expect(r1).toEqual({ ok: true });
    expect(r2).toEqual({ ok: true });
    const refreshCalls = (globalThis.fetch as jest.Mock).mock.calls.filter(([url]) =>
      String(url).includes("/auth/refresh"),
    );
    expect(refreshCalls).toHaveLength(1);
  });

  it("surfaces the original 401 unchanged when the refresh token itself is invalid, with no infinite loop", async () => {
    (getAccessToken as jest.Mock).mockResolvedValue("stale-token");
    (getRefreshToken as jest.Mock).mockResolvedValue("expired-refresh");
    (globalThis.fetch as jest.Mock)
      .mockResolvedValueOnce(jsonResponse({ message: "Unauthorized" }, { status: 401 }))
      .mockResolvedValueOnce(jsonResponse({ message: "Invalid refresh token" }, { status: 401 }));

    await expect(apiClient.get("me/dashboard")).rejects.toMatchObject({
      status: 401,
      message: "Unauthorized",
    });
    expect(globalThis.fetch).toHaveBeenCalledTimes(2);
  });

  it("prefixes every request with /api/v1 against EXPO_PUBLIC_API_URL", async () => {
    (globalThis.fetch as jest.Mock).mockResolvedValueOnce(jsonResponse({ ok: true }));

    await apiClient.get("me/orders");

    const [url] = (globalThis.fetch as jest.Mock).mock.calls[0];
    expect(url).toBe("http://localhost:8080/api/v1/me/orders");
  });

  it("builds an absolute /api/v1 URL with query params against EXPO_PUBLIC_API_URL", async () => {
    (globalThis.fetch as jest.Mock).mockResolvedValueOnce(jsonResponse({ ok: true }));

    await apiClient.get("me/orders", { params: { page: 2, search: "" } });

    const [url] = (globalThis.fetch as jest.Mock).mock.calls[0];
    expect(url).toContain("/api/v1/me/orders");
    expect(url).toContain("page=2");
    expect(url).not.toContain("search=");
  });

  it("resolves the same /api/v1 path even when EXPO_PUBLIC_API_URL has a trailing slash", () => {
    let freshClient: typeof apiClient;
    jest.isolateModules(() => {
      process.env.EXPO_PUBLIC_API_URL = "http://localhost:9090/";
      freshClient = require("./client").apiClient;
    });
    globalThis.fetch = jest.fn();
    (globalThis.fetch as jest.Mock).mockResolvedValueOnce(jsonResponse({ ok: true }));
    return freshClient!.get("me/orders").then(() => {
      const [url] = (globalThis.fetch as jest.Mock).mock.calls[0];
      expect(url).toBe("http://localhost:9090/api/v1/me/orders");
      delete process.env.EXPO_PUBLIC_API_URL;
    });
  });
});

import { ApiError } from "./errors";
import { requestId, validRequestId } from "./request-id";
import { getAccessToken, getRefreshToken, setTokens } from "./token-storage";
import type { ApiClientOptions, QueryParamValue } from "../../types/api";

const API_PREFIX = "/api/v1";
const BASE_URL = process.env.EXPO_PUBLIC_API_URL ?? "http://localhost:8080";

function resolveUrl(path: string): URL {
  return new URL(`${API_PREFIX}/${path.replace(/^\/+/, "")}`, BASE_URL);
}

let refreshPromise: Promise<boolean> | null = null;

async function refreshSession(): Promise<boolean> {
  if (!refreshPromise) {
    refreshPromise = (async () => {
      const refreshToken = await getRefreshToken();
      if (!refreshToken) return false;
      try {
        const response = await fetch(resolveUrl("auth/refresh").toString(), {
          method: "POST",
          headers: { "Content-Type": "application/json", Accept: "application/json" },
          body: JSON.stringify({ refreshToken }),
        });
        if (!response.ok) return false;
        const data = (await response.json()) as { accessToken: string; refreshToken: string };
        await setTokens(data.accessToken, data.refreshToken);
        return true;
      } catch {
        return false;
      }
    })().finally(() => {
      refreshPromise = null;
    });
  }
  return refreshPromise;
}

class ApiClient {
  private buildUrl(endpoint: string, params?: Record<string, QueryParamValue>): string {
    const url = resolveUrl(endpoint);
    Object.entries(params ?? {}).forEach(([key, value]) => {
      if (value !== null && value !== undefined && value !== "")
        url.searchParams.set(key, String(value));
    });
    return url.toString();
  }

  private async parseResponse(response: Response): Promise<unknown> {
    if (response.status === 204) return undefined;
    return response.headers.get("content-type")?.includes("application/json")
      ? response.json()
      : response.text();
  }

  private async request<T>(
    endpoint: string,
    method: string,
    body?: unknown,
    options: ApiClientOptions = {},
    retried = false,
  ): Promise<T> {
    const {
      params,
      timeout = 30_000,
      isFormData = false,
      headers: customHeaders,
      signal: callerSignal,
      skipAuthRefresh = false,
      ...requestInit
    } = options;
    const controller = new AbortController();
    const abort = () => controller.abort(callerSignal?.reason);
    if (callerSignal?.aborted) abort();
    else callerSignal?.addEventListener("abort", abort, { once: true });
    let timedOut = false;
    const timeoutId = setTimeout(() => {
      timedOut = true;
      controller.abort();
    }, timeout);
    const headers = new Headers(customHeaders);
    const id = requestId(headers.get("X-Request-Id"));
    headers.set("X-Request-Id", id);
    headers.set("Accept", "application/json");
    let accessToken: string | null = null;
    try {
      accessToken = await getAccessToken();
    } catch {
      accessToken = null;
    }
    if (accessToken) headers.set("Authorization", `Bearer ${accessToken}`);
    let requestBody: BodyInit | undefined;
    if (body !== undefined) {
      const formData = isFormData || (typeof FormData !== "undefined" && body instanceof FormData);
      if (!formData) headers.set("Content-Type", "application/json");
      requestBody = formData ? (body as BodyInit) : JSON.stringify(body);
    }
    try {
      const response = await fetch(this.buildUrl(endpoint, params), {
        ...requestInit,
        method,
        headers,
        body: requestBody,
        signal: controller.signal,
      });
      if (response.status === 401 && !skipAuthRefresh && !retried && (await refreshSession()))
        return this.request<T>(endpoint, method, body, { ...options, headers }, true);
      const data = await this.parseResponse(response);
      if (!response.ok) {
        const raw =
          typeof data === "object" && data !== null && "message" in data
            ? (data as Record<string, unknown>).message
            : undefined;
        const message = Array.isArray(raw)
          ? raw
              .map((v: unknown) =>
                v && typeof v === "object" && "message" in v
                  ? String((v as Record<string, unknown>).message)
                  : String(v),
              )
              .join(" · ")
          : typeof raw === "string"
            ? raw
            : `Request failed with status ${response.status}`;
        throw new ApiError(
          message,
          response.status,
          data,
          validRequestId(response.headers.get("X-Request-Id"))
            ? response.headers.get("X-Request-Id")!
            : id,
        );
      }
      return data as T;
    } catch (error) {
      if (error instanceof ApiError) throw error;
      if (controller.signal.aborted)
        throw new ApiError(
          timedOut ? "Yêu cầu đã hết thời gian chờ." : "Yêu cầu đã được hủy.",
          timedOut ? 408 : 499,
          { code: timedOut ? "REQUEST_TIMEOUT" : "REQUEST_CANCELLED" },
          id,
        );
      throw new ApiError("Không thể kết nối máy chủ.", 0, { code: "NETWORK_ERROR" }, id);
    } finally {
      clearTimeout(timeoutId);
      callerSignal?.removeEventListener("abort", abort);
    }
  }
  get<T>(endpoint: string, options?: ApiClientOptions) {
    return this.request<T>(endpoint, "GET", undefined, options);
  }
  post<T>(endpoint: string, body?: unknown, options?: ApiClientOptions) {
    return this.request<T>(endpoint, "POST", body, options);
  }
  put<T>(endpoint: string, body?: unknown, options?: ApiClientOptions) {
    return this.request<T>(endpoint, "PUT", body, options);
  }
  patch<T>(endpoint: string, body?: unknown, options?: ApiClientOptions) {
    return this.request<T>(endpoint, "PATCH", body, options);
  }
  delete<T>(endpoint: string, options?: ApiClientOptions) {
    return this.request<T>(endpoint, "DELETE", undefined, options);
  }
}

export const apiClient = new ApiClient();

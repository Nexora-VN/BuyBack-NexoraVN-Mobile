import { ApiError } from "./errors";

describe("ApiError", () => {
  it("defaults code to REQUEST_FAILED when the body has none", () => {
    const error = new ApiError("Something broke", 500);
    expect(error.status).toBe(500);
    expect(error.code).toBe("REQUEST_FAILED");
    expect(error.message).toBe("Something broke");
  });

  it("reads code, requestId and details from the response body", () => {
    const error = new ApiError("Invalid", 400, {
      code: "VALIDATION_FAILED",
      requestId: "req-123",
      details: [{ field: "email", code: "invalid", message: "Bad email" }],
    });
    expect(error.code).toBe("VALIDATION_FAILED");
    expect(error.requestId).toBe("req-123");
    expect(error.details).toEqual([{ field: "email", code: "invalid", message: "Bad email" }]);
  });

  it("falls back to the id argument when the body has no requestId", () => {
    const error = new ApiError("Oops", 500, {}, "fallback-id");
    expect(error.requestId).toBe("fallback-id");
  });
});

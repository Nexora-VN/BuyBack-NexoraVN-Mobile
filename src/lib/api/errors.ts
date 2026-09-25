export class ApiError extends Error {
  readonly code: string;
  readonly requestId?: string;
  readonly details?: Array<{ field: string; code: string; message: string }>;
  constructor(
    message: string,
    readonly status: number,
    readonly data?: unknown,
    id?: string,
  ) {
    super(message);
    this.name = "ApiError";
    const body = data && typeof data === "object" ? (data as Record<string, unknown>) : {};
    this.code = typeof body.code === "string" ? body.code : "REQUEST_FAILED";
    this.requestId = typeof body.requestId === "string" ? body.requestId : id;
    this.details = Array.isArray(body.details) ? body.details : undefined;
  }
}

import * as Crypto from "expo-crypto";
import { requestId, validRequestId } from "./request-id";

jest.mock("expo-crypto", () => ({
  randomUUID: jest.fn(() => "11111111-1111-4111-8111-111111111111"),
}));

describe("validRequestId", () => {
  it("accepts a well-formed v4 UUID", () => {
    expect(validRequestId("11111111-1111-4111-8111-111111111111")).toBe(true);
  });

  it("rejects a non-UUID string", () => {
    expect(validRequestId("not-a-uuid")).toBe(false);
  });

  it("rejects undefined", () => {
    expect(validRequestId(undefined)).toBe(false);
  });
});

describe("requestId", () => {
  it("returns the input when it is already a valid UUID", () => {
    expect(requestId("11111111-1111-4111-8111-111111111111")).toBe(
      "11111111-1111-4111-8111-111111111111",
    );
  });

  it("generates a new UUID when the input is missing or invalid", () => {
    expect(requestId("nope")).toBe("11111111-1111-4111-8111-111111111111");
    expect(Crypto.randomUUID).toHaveBeenCalled();
  });
});

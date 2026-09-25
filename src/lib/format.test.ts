import { formatDateTime, formatVnd, initials } from "./format";

describe("formatters", () => {
  it("formats integer VND with Vietnamese separators", () => {
    expect(formatVnd(134300)).toBe("134.300 ₫");
    expect(formatVnd(-500000)).toBe("-500.000 ₫");
  });

  it("preserves precision for settlement-scale numeric strings", () => {
    expect(formatVnd("123456789012345678")).toBe("123.456.789.012.345.678 ₫");
  });

  it("groups a zero-value amount without a leading separator", () => {
    expect(formatVnd(0)).toBe("0 ₫");
  });

  it("groups a value beyond Number.MAX_SAFE_INTEGER passed as a bigint", () => {
    expect(formatVnd(999999999999999999999n)).toBe("999.999.999.999.999.999.999 ₫");
  });

  it("returns an em dash for a non-numeric string", () => {
    expect(formatVnd("not-a-number")).toBe("—");
  });

  it("formats dates in the configured timezone", () => {
    const value = formatDateTime("2026-08-27T08:20:53Z");
    expect(value).toContain("27/8/26");
    expect(value).toContain("15:20");
  });

  it("returns an em dash for an invalid date", () => {
    expect(formatDateTime("not-a-date")).toBe("—");
  });

  it("creates stable initials", () => {
    expect(initials("Nguyễn Văn An")).toBe("VA");
    expect(initials(null)).toBe("BB");
  });
});

import { renderHook } from "@testing-library/react-native";
import i18n from "./config";
import { useCopy } from "./use-copy";

describe("useCopy", () => {
  afterEach(async () => {
    await i18n.changeLanguage("vi");
  });

  it("translates a known source string to Vietnamese by default", async () => {
    const { result } = await renderHook(() => useCopy());
    expect(result.current("4 số cuối")).toBe("4 số cuối");
  });

  it("translates the same key to English after switching language", async () => {
    await i18n.changeLanguage("en");
    const { result } = await renderHook(() => useCopy());
    expect(result.current("4 số cuối")).toBe("Last 4 digits");
  });

  it("interpolates a value into a source string with an ICU-style single-brace placeholder", async () => {
    const { result } = await renderHook(() => useCopy());
    expect(result.current("Sync cách {value0}s", { value0: 12 })).toBe("Sync cách 12s");
  });

  it("interpolates the same placeholder in English", async () => {
    await i18n.changeLanguage("en");
    const { result } = await renderHook(() => useCopy());
    expect(result.current("Sync cách {value0}s", { value0: 12 })).toBe("Synced 12s ago");
  });

  it("falls back to the raw source string when no translation key exists", async () => {
    const { result } = await renderHook(() => useCopy());
    expect(result.current("a string nobody has translated yet")).toBe(
      "a string nobody has translated yet",
    );
  });

  it("maps a known backend error code through the error map", async () => {
    const { result } = await renderHook(() => useCopy());
    expect(result.current.error("INSUFFICIENT_BALANCE")).toBe("Số dư khả dụng không đủ");
  });

  it("falls back to a generic message with the raw code appended for an unknown error code", async () => {
    const { result } = await renderHook(() => useCopy());
    expect(result.current.error("SOME_UNKNOWN_CODE")).toBe(
      "Không thể hoàn tất yêu cầu. Vui lòng thử lại. (SOME_UNKNOWN_CODE)",
    );
  });
});

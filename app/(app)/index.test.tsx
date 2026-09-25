import { render, screen, waitFor } from "@testing-library/react-native";
import "../../src/i18n/config";
import { AppQueryProvider } from "../../src/providers/query-provider";
import DashboardScreen from "./index";

jest.mock("expo-router", () => ({
  router: { push: jest.fn(), navigate: jest.fn() },
  usePathname: () => "/",
  useIsFocused: () => true,
}));

jest.mock("../../src/lib/api/client", () => ({
  apiClient: { get: jest.fn(), post: jest.fn() },
}));

import { apiClient } from "../../src/lib/api/client";

function Wrapped() {
  return (
    <AppQueryProvider>
      <DashboardScreen />
    </AppQueryProvider>
  );
}

describe("Dashboard screen", () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it("renders the web dashboard: generate-link panel, cashback overview, recent orders", async () => {
    (apiClient.get as jest.Mock).mockImplementation((path: string) => {
      if (path === "me/dashboard")
        return Promise.resolve({
          orders: 5,
          wallet: { available: "134300", reserved: "20000" },
          cashbackSummary: [
            { state: "PENDING", userAmount: "58000", count: 1 },
            { state: "VALIDATED", userAmount: "2000", count: 1 },
            { state: "AVAILABLE", userAmount: "999", count: 1 },
          ],
          commissions: [],
        });
      return Promise.resolve({ data: [], meta: { page: 1, limit: 3, total: 0, totalPages: 0 } });
    });

    await render(<Wrapped />);

    expect(screen.getByText("Link sản phẩm Shopee, TikTok")).toBeTruthy();
    expect(screen.getByText("Vài lưu ý Piggy gửi tới bạn")).toBeTruthy();
    await waitFor(() => expect(screen.getByText("Bạn có thể rút")).toBeTruthy(), { timeout: 5000 });
    expect(screen.getByText("134.300 ₫")).toBeTruthy();
    // pending = PENDING + VALIDATED cashback only (web CashbackOverview)
    expect(screen.getByText("60.000 ₫")).toBeTruthy();
    expect(screen.getByText("20.000 ₫")).toBeTruthy();
    expect(screen.getByText("Đơn hàng gần đây")).toBeTruthy();
  });

  it("shows the web's empty copy when there are no recent orders", async () => {
    (apiClient.get as jest.Mock).mockImplementation((path: string) => {
      if (path === "me/dashboard")
        return Promise.resolve({ orders: 0, wallet: { available: "0", reserved: "0" }, commissions: [] });
      return Promise.resolve({ data: [], meta: { page: 1, limit: 3, total: 0, totalPages: 0 } });
    });

    await render(<Wrapped />);

    await waitFor(
      () => expect(screen.getByText("Bạn chưa có đơn hàng nào cả. Tạo link mua sắm ngay nào.")).toBeTruthy(),
      { timeout: 5000 },
    );
  });
});

import { render, screen } from "@testing-library/react-native";
import "../../i18n/config";
import { StatusBadge } from "./StatusBadge";

describe("StatusBadge", () => {
  it("renders the Vietnamese label for a general status", async () => {
    await render(<StatusBadge status="PENDING" />);
    expect(screen.getByText("Chờ xử lý")).toBeTruthy();
  });

  it("renders the domain-specific label for a cashback status", async () => {
    await render(<StatusBadge status="AVAILABLE" domain="cashback" />);
    expect(screen.getByText("Có thể rút")).toBeTruthy();
  });

  it("renders the domain-specific label for an order status", async () => {
    await render(<StatusBadge status="VALIDATED" domain="order" />);
    expect(screen.getByText("Hoàn thành")).toBeTruthy();
  });
});

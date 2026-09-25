import { render, screen } from "@testing-library/react-native";
import { CircleCheck } from "lucide-react-native";
import { Badge } from "./Badge";

describe("Badge", () => {
  it("renders its label", async () => {
    await render(<Badge label="Đang xử lý" />);
    expect(screen.getByText("Đang xử lý")).toBeTruthy();
  });

  it("accepts every web variant without throwing", async () => {
    const variants = ["default", "success", "warning", "danger", "info", "muted"] as const;
    for (const variant of variants) {
      await render(<Badge label={variant} variant={variant} icon={CircleCheck} />);
      expect(screen.getByText(variant)).toBeTruthy();
    }
  });
});

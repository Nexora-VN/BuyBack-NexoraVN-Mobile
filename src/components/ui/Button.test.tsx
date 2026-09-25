import { fireEvent, render, screen } from "@testing-library/react-native";
import { Button } from "./Button";

describe("Button", () => {
  it("renders its label", async () => {
    await render(<Button label="Đăng nhập" onPress={() => {}} />);
    expect(screen.getByText("Đăng nhập")).toBeTruthy();
  });

  it("calls onPress when tapped", async () => {
    const onPress = jest.fn();
    await render(<Button label="Tap" onPress={onPress} />);
    await fireEvent.press(screen.getByText("Tap"));
    expect(onPress).toHaveBeenCalledTimes(1);
  });

  it("keeps its label next to the spinner while loading, like the web", async () => {
    await render(<Button label="Đang đăng nhập" onPress={() => {}} loading />);
    expect(screen.getByText("Đang đăng nhập")).toBeTruthy();
  });

  it("does not fire onPress when disabled", async () => {
    const onPress = jest.fn();
    await render(<Button label="Tap" onPress={onPress} disabled />);
    await fireEvent.press(screen.getByText("Tap"));
    expect(onPress).not.toHaveBeenCalled();
  });
});

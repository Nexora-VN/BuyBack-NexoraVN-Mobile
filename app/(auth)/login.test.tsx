import { fireEvent, render, screen } from "@testing-library/react-native";
import "../../src/i18n/config";
import { AppQueryProvider } from "../../src/providers/query-provider";
import { AuthProvider } from "../../src/providers/auth-provider";
import LoginScreen from "./login";

jest.mock("expo-router", () => ({ router: { replace: jest.fn() } }));

function Wrapped() {
  return (
    <AppQueryProvider>
      <AuthProvider>
        <LoginScreen />
      </AuthProvider>
    </AppQueryProvider>
  );
}

describe("Login screen", () => {
  it("renders the web login layout: Google button, divider, email/password form", async () => {
    await render(<Wrapped />);
    expect(screen.getByText("Chào mừng trở lại")).toBeTruthy();
    expect(screen.getByText("Đăng nhập với Google")).toBeTruthy();
    expect(screen.getByText("HOẶC TIẾP TỤC VỚI TÀI KHOẢN HỆ THỐNG")).toBeTruthy();
    expect(screen.getByPlaceholderText("you@example.com")).toBeTruthy();
    expect(screen.getByLabelText("Mật khẩu")).toBeTruthy();
    expect(screen.getByText("Duy trì đăng nhập trên thiết bị này")).toBeTruthy();
    expect(screen.getByText("Đăng nhập")).toBeTruthy();
  });

  it("shows the web's validation errors", async () => {
    await render(<Wrapped />);
    await fireEvent.changeText(screen.getByPlaceholderText("you@example.com"), "not-an-email");
    await fireEvent.press(screen.getByText("Đăng nhập"));
    expect(await screen.findByText("Email không hợp lệ")).toBeTruthy();
    expect(screen.getByText("Mật khẩu phải có ít nhất 8 ký tự")).toBeTruthy();
  });

  it("toggles password visibility", async () => {
    await render(<Wrapped />);
    const passwordInput = screen.getByLabelText("Mật khẩu");
    expect(passwordInput.props.secureTextEntry).toBe(true);
    await fireEvent.press(screen.getByLabelText("Hiện mật khẩu"));
    expect(screen.getByLabelText("Mật khẩu").props.secureTextEntry).toBe(false);
  });

  it("keeps 'remember me' checked by default and lets the user untick it", async () => {
    await render(<Wrapped />);
    const checkbox = screen.getByRole("checkbox");
    expect(checkbox.props.accessibilityState.checked).toBe(true);
    await fireEvent.press(checkbox);
    expect(screen.getByRole("checkbox").props.accessibilityState.checked).toBe(false);
  });
});

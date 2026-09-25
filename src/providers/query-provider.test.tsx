import { render, screen } from "@testing-library/react-native";
import { Text } from "react-native";
import { AppQueryProvider, queryClient } from "./query-provider";

describe("AppQueryProvider", () => {
  it("renders its children", async () => {
    await render(
      <AppQueryProvider>
        <Text>child content</Text>
      </AppQueryProvider>,
    );
    expect(screen.getByText("child content")).toBeTruthy();
  });

  it("exposes a shared QueryClient with the default in-memory cache", () => {
    expect(queryClient.getQueryCache()).toBeDefined();
    expect(queryClient.getDefaultOptions().queries?.gcTime).not.toBe(0);
  });
});

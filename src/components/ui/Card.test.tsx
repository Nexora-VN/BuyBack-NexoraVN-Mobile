import { render, screen } from "@testing-library/react-native";
import { Text } from "react-native";
import { Card } from "./Card";

describe("Card", () => {
  it("renders its children", async () => {
    await render(
      <Card>
        <Text>Inside the card</Text>
      </Card>,
    );
    expect(screen.getByText("Inside the card")).toBeTruthy();
  });
});

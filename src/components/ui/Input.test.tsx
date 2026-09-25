import { fireEvent, render, screen } from "@testing-library/react-native";
import { Input, Select } from "./Input";

describe("Input", () => {
  it("renders its placeholder", async () => {
    await render(<Input placeholder="you@example.com" value="" onChangeText={() => {}} />);
    expect(screen.getByPlaceholderText("you@example.com")).toBeTruthy();
  });

  it("calls onChangeText as the user types", async () => {
    const onChangeText = jest.fn();
    await render(<Input placeholder="Email" value="" onChangeText={onChangeText} />);
    await fireEvent.changeText(screen.getByPlaceholderText("Email"), "a@b.com");
    expect(onChangeText).toHaveBeenCalledWith("a@b.com");
  });
});

describe("Select", () => {
  const options = [
    { value: "desc", label: "Mới nhất" },
    { value: "asc", label: "Cũ nhất" },
  ];

  it("shows the selected option's label", async () => {
    await render(<Select title="Sắp xếp" value="asc" options={options} onChange={() => {}} />);
    expect(screen.getByText("Cũ nhất")).toBeTruthy();
  });

  it("opens the options sheet and reports the chosen value", async () => {
    const onChange = jest.fn();
    await render(<Select title="Sắp xếp" value="desc" options={options} onChange={onChange} />);
    await fireEvent.press(screen.getByRole("combobox"));
    await fireEvent.press(screen.getAllByText("Cũ nhất").at(-1)!);
    expect(onChange).toHaveBeenCalledWith("asc");
  });
});

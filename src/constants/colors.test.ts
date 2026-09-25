import { colors, font, fonts, radii } from "./colors";

const HEX = /^#[0-9a-f]{6}$/i;

describe("design tokens", () => {
  it("defines every color from AGENTS.md as a valid hex value", () => {
    const expectedKeys = [
      "primary",
      "primaryForeground",
      "secondary",
      "secondaryForeground",
      "background",
      "foreground",
      "card",
      "cardForeground",
      "muted",
      "mutedForeground",
      "accent",
      "accentForeground",
      "border",
      "input",
      "ring",
      "success",
      "successSoft",
      "warning",
      "warningSoft",
      "danger",
      "dangerSoft",
      "info",
      "infoSoft",
    ];
    for (const key of expectedKeys) {
      expect(colors).toHaveProperty(key);
      expect((colors as Record<string, string>)[key]).toMatch(HEX);
    }
  });

  it("mirrors the web's resolved Tailwind radius scale", () => {
    expect(radii).toEqual({ base: 4, sm: 8, md: 12, lg: 16, xl: 24, "2xl": 16, full: 9999 });
  });

  it("maps Tailwind text sizes to Be Vietnam Pro weights with default leading", () => {
    expect(font(14, 600)).toEqual({ fontFamily: fonts[600], fontSize: 14, lineHeight: 20 });
    expect(font(24, 700)).toEqual({ fontFamily: fonts[700], fontSize: 24, lineHeight: 32 });
    expect(font(14, 400, 24).lineHeight).toBe(24);
  });
});

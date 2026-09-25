import type { TextStyle } from "react-native";

// Ported from the web frontend's globals.css :root tokens.
export const colors = {
  primary: "#a8245e",
  primaryForeground: "#ffffff",
  secondary: "#ffe8f1",
  secondaryForeground: "#75003f",
  background: "#fff8f8",
  foreground: "#25181e",
  card: "#ffffff",
  cardForeground: "#25181e",
  muted: "#fff0f4",
  mutedForeground: "#725f68",
  accent: "#ffd9e3",
  accentForeground: "#89124d",
  border: "#eedde5",
  input: "#ddbfc6",
  ring: "#e05b91",
  success: "#16845b",
  successSoft: "#e9f7f1",
  warning: "#a96813",
  warningSoft: "#fff5dc",
  danger: "#c23b55",
  dangerSoft: "#fdecef",
  info: "#3568c9",
  infoSoft: "#eaf1ff",
} as const;

// NOTE: the web's globals.css sets `* { border-color: var(--border) }` outside any @layer, so it beats every
// Tailwind `border-<color>` utility. Every bordered element on the web therefore renders `colors.border`.

// Tailwind utility colors the web uses outside the token set (platform chip, overlays).
export const extra = {
  orange50: "#fff7ed",
  orange600: "#f54900",
  secondary50: "rgba(255, 232, 241, 0.5)",
  primary5: "rgba(168, 36, 94, 0.05)",
  muted50: "rgba(255, 240, 244, 0.5)",
  muted40: "rgba(255, 240, 244, 0.4)",
  mutedFg60: "rgba(114, 95, 104, 0.6)",
  mutedFg70: "rgba(114, 95, 104, 0.7)",
  overlay: "rgba(37, 24, 30, 0.35)",
  ring15: "rgba(224, 91, 145, 0.15)",
} as const;

// Tailwind radius utilities as the web theme resolves them (globals.css @theme overrides).
// rounded = 4, rounded-sm = 8, rounded-md = 12, rounded-lg = 16, rounded-xl = 24, rounded-2xl = 16.
export const radii = { base: 4, sm: 8, md: 12, lg: 16, xl: 24, "2xl": 16, full: 9999 } as const;

export const fonts = {
  400: "BeVietnamPro_400Regular",
  500: "BeVietnamPro_500Medium",
  600: "BeVietnamPro_600SemiBold",
  700: "BeVietnamPro_700Bold",
  900: "BeVietnamPro_900Black",
} as const;

export type Weight = keyof typeof fonts;

// Tailwind text-* sizes with their default line heights.
const leading: Record<number, number> = { 10: 15, 11: 16, 12: 16, 14: 20, 16: 24, 18: 28, 20: 28, 24: 32, 30: 36, 36: 40 };

/** Text style equivalent to Tailwind `text-<size> font-<weight>` (optionally with a custom leading). */
export function font(size: number, weight: Weight = 400, lineHeight?: number): TextStyle {
  return { fontFamily: fonts[weight], fontSize: size, lineHeight: lineHeight ?? leading[size] ?? Math.round(size * 1.5) };
}

import type { LucideIcon } from "lucide-react-native";
import type { ReactNode } from "react";
import {
  ActivityIndicator,
  Pressable,
  StyleSheet,
  Text,
  View,
  type PressableProps,
  type StyleProp,
  type ViewStyle,
} from "react-native";
import { colors, font, radii } from "../../constants/colors";

export type ButtonVariant = "default" | "outline" | "ghost" | "danger";
export type ButtonSize = "default" | "sm" | "lg" | "icon";

export interface ButtonProps extends Omit<PressableProps, "style" | "children"> {
  label?: string;
  children?: ReactNode;
  variant?: ButtonVariant;
  size?: ButtonSize;
  icon?: LucideIcon;
  /** Replaces the icon with a spinner (web: LoaderCircle animate-spin). */
  loading?: boolean;
  style?: StyleProp<ViewStyle>;
  /** Text color override: web outline/ghost buttons inherit the surrounding text color. */
  color?: string;
  wrap?: boolean;
}

const fg: Record<ButtonVariant, string> = {
  default: colors.primaryForeground,
  outline: colors.foreground,
  ghost: colors.foreground,
  danger: "#ffffff",
};

export function Button({
  label,
  children,
  variant = "default",
  size = "default",
  icon: Icon,
  loading = false,
  disabled,
  style,
  color,
  wrap = false,
  ...props
}: ButtonProps) {
  const textColor = color ?? fg[variant];
  return (
    <Pressable
      accessibilityRole="button"
      accessibilityState={{ disabled: !!disabled }}
      disabled={disabled}
      style={({ pressed }) => [
        styles.base,
        sizes[size],
        variants[variant],
        pressed && pressedStyles[variant],
        disabled && styles.disabled,
        style,
      ]}
      {...props}
    >
      {loading ? (
        <ActivityIndicator size={16} color={textColor} />
      ) : Icon ? (
        <Icon color={textColor} size={16} />
      ) : null}
      {label != null ? (
        <Text
          numberOfLines={wrap ? undefined : 1}
          style={[size === "lg" ? styles.labelLg : styles.label, { color: textColor }, wrap && styles.wrap]}
        >
          {label}
        </Text>
      ) : null}
      {children != null ? <View style={styles.row}>{children}</View> : null}
    </Pressable>
  );
}

const styles = StyleSheet.create({
  base: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "center",
    gap: 8,
    borderRadius: radii.lg,
    flexShrink: 0,
  },
  disabled: { opacity: 0.5 },
  label: { ...font(14, 500) },
  labelLg: { ...font(16, 500) },
  wrap: { flexShrink: 1, textAlign: "center" },
  row: { flexDirection: "row", alignItems: "center", gap: 8 },
});

const sizes = StyleSheet.create({
  default: { minHeight: 44, paddingHorizontal: 16, paddingVertical: 8 },
  sm: { minHeight: 44, paddingHorizontal: 12 },
  lg: { height: 48, borderRadius: radii.xl, paddingHorizontal: 24 },
  icon: { width: 44, height: 44 },
});

const variants = StyleSheet.create({
  default: { backgroundColor: colors.primary },
  outline: { borderWidth: 1, borderColor: colors.border, backgroundColor: colors.background },
  ghost: { backgroundColor: "transparent" },
  danger: { backgroundColor: colors.danger },
});

// Web hover/active states → press feedback.
const pressedStyles = StyleSheet.create({
  default: { backgroundColor: "rgba(168, 36, 94, 0.9)" },
  outline: { backgroundColor: colors.accent },
  ghost: { backgroundColor: colors.accent },
  danger: { backgroundColor: "rgba(194, 59, 85, 0.9)" },
});

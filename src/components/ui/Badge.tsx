import type { LucideIcon } from "lucide-react-native";
import { StyleSheet, Text, View } from "react-native";
import { colors, font, radii } from "../../constants/colors";

export type BadgeVariant = "default" | "success" | "warning" | "danger" | "info" | "muted";

const variantStyles: Record<BadgeVariant, { bg: string; fg: string }> = {
  default: { bg: colors.secondary, fg: colors.secondaryForeground },
  success: { bg: colors.successSoft, fg: colors.success },
  warning: { bg: colors.warningSoft, fg: colors.warning },
  danger: { bg: colors.dangerSoft, fg: colors.danger },
  info: { bg: colors.infoSoft, fg: colors.info },
  muted: { bg: colors.muted, fg: colors.mutedForeground },
};

export interface BadgeProps {
  label: string;
  variant?: BadgeVariant;
  icon?: LucideIcon;
}

/** web `Badge`: inline-flex gap-1 rounded-full px-2.5 py-1 text-xs font-semibold. */
export function Badge({ label, variant = "default", icon: Icon }: BadgeProps) {
  const v = variantStyles[variant];
  return (
    <View style={[styles.badge, { backgroundColor: v.bg }]}>
      {Icon ? <Icon color={v.fg} size={14} style={styles.icon} /> : null}
      <Text style={[styles.label, { color: v.fg }]}>{label}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  badge: {
    alignSelf: "flex-start",
    flexDirection: "row",
    alignItems: "center",
    gap: 4,
    borderRadius: radii.full,
    paddingHorizontal: 10,
    paddingVertical: 4,
  },
  label: { ...font(12, 600), flexShrink: 1 },
  icon: { flexShrink: 0 },
});

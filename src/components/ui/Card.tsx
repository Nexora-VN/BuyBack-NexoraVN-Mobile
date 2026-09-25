import type { ReactNode } from "react";
import { StyleSheet, Text, View, type ViewProps } from "react-native";
import { colors, font, radii } from "../../constants/colors";
import { useCopy } from "../../i18n/use-copy";

export function Card({ style, ...props }: ViewProps) {
  return <View style={[styles.card, style]} {...props} />;
}

export function StatCard({
  label,
  value,
  helper,
}: {
  label: string;
  value: ReactNode;
  helper?: string;
}) {
  const t = useCopy();
  return (
    <Card>
      <Text style={styles.label}>{t(label)}</Text>
      <Text style={styles.value}>{value}</Text>
      {helper ? <Text style={styles.helper}>{t(helper)}</Text> : null}
    </Card>
  );
}

const styles = StyleSheet.create({
  card: {
    backgroundColor: colors.card,
    borderRadius: radii["2xl"],
    borderWidth: 1,
    borderColor: colors.border,
    padding: 16,
    minWidth: 0,
  },
  label: { ...font(14), color: colors.mutedForeground },
  value: {
    ...font(24, 700),
    letterSpacing: -0.6,
    color: colors.foreground,
    marginTop: 8,
    fontVariant: ["tabular-nums"],
  },
  helper: { ...font(12), color: colors.mutedForeground, marginTop: 8 },
});

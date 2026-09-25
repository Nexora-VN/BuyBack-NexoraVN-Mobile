import * as Clipboard from "expo-clipboard";
import { Check, Copy } from "lucide-react-native";
import { createContext, useContext, useState, type ReactNode } from "react";
import { Platform, Pressable, StyleSheet, Text, View, type StyleProp, type TextStyle } from "react-native";
import { ProductThumbnail } from "../../../components/patterns/ProductThumbnail";
import { useToast } from "../../../components/patterns/Toast";
import { StatusBadge, type StatusDomain } from "../../../components/ui/StatusBadge";
import { colors, extra, font } from "../../../constants/colors";
import { useCopy } from "../../../i18n/use-copy";
import { formatDateTime, formatVnd } from "../../../lib/format";
import type { FinanceRow } from "../../../types/finance";

export const mono = Platform.select({
  web: "ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, 'Liberation Mono', 'Courier New', monospace",
  ios: "Menlo",
  default: "monospace",
});

export function read(row: unknown, path: string): unknown {
  return path
    .split(".")
    .reduce<unknown>((v, k) => (v && typeof v === "object" ? (v as Record<string, unknown>)[k] : undefined), row);
}

export const text = (row: unknown, path: string) => {
  const value = read(row, path);
  return value == null ? "—" : String(value);
};

/** Text style of the enclosing table cell (web cells inherit it through CSS). */
export const CellStyle = createContext<StyleProp<TextStyle>>(null);

export function CellText({ children, block = false }: { children: ReactNode; block?: boolean }) {
  return <Text style={[useContext(CellStyle), block && styles.block]}>{children}</Text>;
}

export type Specs = [string, string, ("money" | "status" | "date")?][];

export interface Column<T> {
  key: string;
  label: string;
  render: (row: T) => ReactNode;
  mobilePrimary?: boolean;
}

/** Port of web `columns()` from finance-columns.tsx. */
export function columns(specs: Specs, domain: StatusDomain = "general"): Column<FinanceRow>[] {
  return specs.map(([key, label, type]) => ({
    key,
    label,
    mobilePrimary: ["productSummary.name", "checkout.checkoutId", "bankName", "orderSn"].includes(key),
    render: (row) => {
      const value = text(row, key);

      if (key === "productSummary.name") {
        const platform = (read(row, "productSummary.platform") || read(row, "platform")) as string | undefined;
        const itemCount = Number(read(row, "productSummary.itemCount") ?? 1);
        const imageUrl = read(row, "productSummary.imageUrl") as string | null;
        return (
          <View style={styles.product}>
            <ProductThumbnail src={imageUrl} name={value === "—" ? "" : value} size={56} />
            <View style={styles.productBody}>
              {/* inline-flex chip inside the cell's 24px line box */}
              {platform ? (
                <View style={styles.chipLine}>
                  <PlatformChip platform={platform} />
                </View>
              ) : null}
              <Text numberOfLines={2} style={styles.productName}>
                {value === "—" ? text(row, "orderSn") : value}
              </Text>
              <View style={styles.productMeta}>
                <Text style={styles.metaText}>
                  {itemCount} <CopyText value="sản phẩm" />
                </Text>
                {itemCount > 1 ? (
                  <View style={styles.moreChip}>
                    <Text style={styles.moreText}>
                      +{itemCount - 1} <CopyText value="khác" />
                    </Text>
                  </View>
                ) : null}
              </View>
            </View>
          </View>
        );
      }

      if (key === "orderSn") {
        const platform = (read(row, "platform") || read(row, "productSummary.platform")) as string | undefined;
        return (
          <View style={styles.sn}>
            <View style={styles.snRow}>
              <Text numberOfLines={1} style={styles.snText}>
                {value}
              </Text>
              <CopySnButton value={value} />
            </View>
            {platform ? <Text style={styles.snPlatform}>{platform}</Text> : null}
          </View>
        );
      }

      if (value === "—") return <CellText>{value}</CellText>;

      if (key.includes("cashback") || key === "checkout.commission.cashback.userAmount") {
        return <Text style={styles.cashback}>+{formatVnd(value)}</Text>;
      }

      if (type === "money") return <Text style={styles.money}>{formatVnd(value)}</Text>;

      if (type === "status") {
        return (
          <StatusBadge
            status={value}
            domain={key.includes("cashback") ? "cashback" : key.includes("commission") ? "commission" : domain}
          />
        );
      }

      if (type === "date") return <CellText>{formatDateTime(value)}</CellText>;

      // web: <span className="block max-w-72 break-words">
      return <CellText block>{key === "type" ? <CopyText value={value} /> : value}</CellText>;
    },
  }));
}

/** web: rounded-md border-orange-200/60 bg-orange-50 px-1.5 py-0.5 text-[10px] font-bold tracking-wider text-orange-600 uppercase. */
export function PlatformChip({ platform, large = false }: { platform: string; large?: boolean }) {
  return (
    <View style={[styles.chip, large && styles.chipLarge]}>
      <Text style={large ? styles.chipTextLarge : styles.chipText}>{platform.toUpperCase()}</Text>
    </View>
  );
}

function CopySnButton({ value }: { value: string }) {
  const [copied, setCopied] = useState(false);
  const t = useCopy();
  const toast = useToast();
  if (!value || value === "—") return null;
  return (
    <Pressable
      accessibilityLabel={t("Sao chép mã đơn")}
      hitSlop={12}
      style={({ pressed }) => [styles.copyBtn, pressed && { backgroundColor: colors.muted }]}
      onPress={() => {
        Clipboard.setStringAsync(value)
          .then(() => {
            setCopied(true);
            toast.success(t("Đã sao chép mã đơn"));
            setTimeout(() => setCopied(false), 2000);
          })
          .catch(() => toast.error(t("Không thể sao chép")));
      }}
    >
      {copied ? <Check color={colors.success} size={12} /> : <Copy color={colors.mutedForeground} size={12} />}
    </Pressable>
  );
}

function CopyText({ value }: { value: string }) {
  const t = useCopy();
  return t(value);
}

const styles = StyleSheet.create({
  block: { maxWidth: 288 },
  product: { flexDirection: "row", alignItems: "center", gap: 12, paddingVertical: 4, minWidth: 0 },
  productBody: { flex: 1, minWidth: 0, gap: 4 },
  productName: { ...font(14, 600, 19.25), color: colors.foreground },
  // the inline-flex chip hangs 1px below its 24px line box
  chipLine: { height: 25, paddingTop: 4, alignItems: "flex-start" },
  productMeta: { flexDirection: "row", alignItems: "center", gap: 8 },
  // inherits font-semibold from the table's primary cell
  metaText: { ...font(12, 600), color: colors.mutedForeground },
  moreChip: { backgroundColor: colors.muted, borderRadius: 4, paddingHorizontal: 6, paddingVertical: 2 },
  moreText: { ...font(10, 500, 13.33), color: colors.mutedForeground },
  chip: {
    borderRadius: 12,
    borderWidth: 1,
    borderColor: colors.border,
    backgroundColor: extra.orange50,
    paddingHorizontal: 6,
    paddingVertical: 2,
  },
  chipLarge: { paddingHorizontal: 8 },
  chipText: { ...font(10, 700, 15), letterSpacing: 0.5, color: extra.orange600 },
  chipTextLarge: { ...font(12, 700, 16), letterSpacing: 0.6, color: extra.orange600 },
  sn: { paddingVertical: 4, gap: 4 },
  snRow: { flexDirection: "row", alignItems: "center", gap: 6 },
  snText: { fontFamily: mono, fontSize: 12, lineHeight: 16, fontWeight: "500", color: colors.foreground, flexShrink: 1 },
  // text-[11px] keeps text-sm's unitless leading (20/14) → 15.7px
  snPlatform: { ...font(11, 400, 15.71), color: colors.mutedForeground },
  copyBtn: { width: 20, height: 20, borderRadius: 4, alignItems: "center", justifyContent: "center" },
  cashback: { ...font(14, 700), color: colors.success, fontVariant: ["tabular-nums"] },
  money: { ...font(14, 600), color: colors.foreground, fontVariant: ["tabular-nums"] },
});

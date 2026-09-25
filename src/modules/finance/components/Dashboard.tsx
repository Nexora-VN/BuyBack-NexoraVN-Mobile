import { router } from "expo-router";
import { Pressable, StyleSheet, Text, View } from "react-native";
import { ProductThumbnail } from "../../../components/patterns/ProductThumbnail";
import { Failure, Loading } from "../../../components/patterns/QueryState";
import { Card, StatCard } from "../../../components/ui/Card";
import { StatusBadge } from "../../../components/ui/StatusBadge";
import { colors, extra, font } from "../../../constants/colors";
import { useCopy } from "../../../i18n/use-copy";
import { formatVnd } from "../../../lib/format";
import type { Dashboard, FinanceList, OrderRow } from "../../../types/finance";
import { useFinance } from "../use-finance";
import { mono, PlatformChip, read, text } from "./columns";

/** Port of web `CashbackOverview`. */
export function CashbackOverview() {
  const t = useCopy();
  const query = useFinance<Dashboard>("me/dashboard");
  if (query.isLoading) return <Loading />;
  if (query.isError) return <Failure message={query.error.message} retry={() => void query.refetch()} />;
  if (!query.data) return null;
  const pending = query.data.cashbackSummary
    ?.filter((row) => ["PENDING", "VALIDATED"].includes(row.state))
    .reduce((sum, row) => sum + BigInt(row.userAmount), 0n);
  return (
    <View style={styles.grid3}>
      <Card style={styles.withdrawCard}>
        <Text style={styles.muted14}>{t("Bạn có thể rút")}</Text>
        <Text style={styles.available}>{formatVnd(query.data.wallet.available)}</Text>
        <Pressable
          accessibilityRole="link"
          onPress={() => router.push("/withdrawals/new")}
          style={({ pressed }) => [styles.withdrawLink, pressed && { backgroundColor: colors.secondary }]}
        >
          <Text style={styles.withdrawLinkText}>{t("Rút tiền")}</Text>
        </Pressable>
      </Card>
      <StatCard
        label="Số tiền chờ xác nhận"
        value={pending === undefined ? "—" : formatVnd(pending)}
        helper="Chưa tính vào số dư có thể rút"
      />
      <StatCard label="Đang giữ cho yêu cầu rút" value={formatVnd(query.data.wallet.reserved)} />
    </View>
  );
}

/** Port of web `RecentOrders`. */
export function RecentOrders() {
  const t = useCopy();
  const query = useFinance<FinanceList<OrderRow>>("me/orders?limit=3");
  if (query.isLoading) return <Loading />;
  if (query.isError) return <Failure message={query.error.message} retry={() => void query.refetch()} />;
  const rows = query.data?.data ?? [];
  return (
    <View style={styles.list}>
      {rows.length ? (
        rows.map((row, index) => {
          const platform = (read(row, "productSummary.platform") || read(row, "platform")) as string | undefined;
          const imageUrl = read(row, "productSummary.imageUrl") as string | null;
          const productName =
            text(row, "productSummary.name") === "—" ? text(row, "orderSn") : text(row, "productSummary.name");
          const cashbackAmount = text(row, "checkout.commission.cashback.userAmount");
          const itemCount = Number(read(row, "productSummary.itemCount") ?? 1);
          return (
            <Pressable
              key={row.id}
              accessibilityRole="link"
              onPress={() => router.push(`/orders/${row.id}`)}
              style={({ pressed }) => [styles.row, index > 0 && styles.divider, pressed && { backgroundColor: extra.muted40 }]}
            >
              <View style={styles.rowMain}>
                <ProductThumbnail src={imageUrl} name={productName} size={56} />
                <View style={styles.rowBody}>
                  <View style={styles.rowTop}>
                    {platform ? <PlatformChip platform={platform} /> : null}
                    <Text style={styles.sn}>{text(row, "orderSn")}</Text>
                  </View>
                  <Text numberOfLines={1} style={styles.name}>
                    {productName}
                  </Text>
                  <View style={styles.meta}>
                    <Text style={styles.metaText}>
                      {itemCount} {t("sản phẩm")}
                    </Text>
                    {cashbackAmount !== "—" ? <Text style={styles.cashback}>+{formatVnd(cashbackAmount)}</Text> : null}
                  </View>
                </View>
              </View>
              <View style={styles.rowStatus}>
                <StatusBadge domain="order" status={text(row, "status")} />
              </View>
            </Pressable>
          );
        })
      ) : (
        <Text style={styles.empty}>{t("Bạn chưa có đơn hàng nào cả. Tạo link mua sắm ngay nào.")}</Text>
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  grid3: { gap: 12 },
  withdrawCard: { backgroundColor: "#fff0f5" },
  muted14: { ...font(14), color: colors.mutedForeground },
  available: { ...font(30, 700), color: colors.primary, marginTop: 8, fontVariant: ["tabular-nums"] },
  withdrawLink: {
    alignSelf: "flex-start",
    marginTop: 12,
    minHeight: 44,
    justifyContent: "center",
    borderRadius: 16,
    borderWidth: 1,
    borderColor: colors.border,
    paddingHorizontal: 16,
    paddingVertical: 8,
  },
  withdrawLinkText: { ...font(16, 500), color: colors.primary },
  list: { backgroundColor: colors.card, borderRadius: 16, borderWidth: 1, borderColor: colors.border, overflow: "hidden" },
  row: { flexDirection: "row", alignItems: "center", justifyContent: "space-between", gap: 16, padding: 16 },
  divider: { borderTopWidth: 1, borderTopColor: colors.border },
  rowMain: { flex: 1, minWidth: 0, flexDirection: "row", alignItems: "center", gap: 12 },
  rowBody: { flex: 1, minWidth: 0, gap: 4 },
  rowTop: { flexDirection: "row", alignItems: "center", gap: 8 },
  sn: { fontFamily: mono, fontSize: 12, lineHeight: 16, color: colors.mutedForeground, flexShrink: 1 },
  name: { ...font(14, 600), color: colors.foreground },
  meta: { flexDirection: "row", alignItems: "center", gap: 8 },
  metaText: { ...font(12), color: colors.mutedForeground, flexShrink: 1 },
  cashback: { ...font(12, 600), color: colors.success, flexShrink: 1 },
  rowStatus: { flexShrink: 0, alignItems: "flex-end", gap: 6 },
  empty: { ...font(14), color: colors.mutedForeground, padding: 20 },
});

import { router } from "expo-router";
import { Pressable, StyleSheet, Text } from "react-native";
import { Page } from "../../../src/components/ui/Page";
import { colors, font } from "../../../src/constants/colors";
import { useCopy } from "../../../src/i18n/use-copy";
import { FinanceTable } from "../../../src/modules/finance/components/FinanceTable";
import type { Specs } from "../../../src/modules/finance/components/columns";

export const orderSpecs: Specs = [
  ["productSummary.name", "Sản phẩm"],
  ["orderSn", "Mã đơn & Sàn"],
  ["checkout.purchasedAt", "Ngày mua", "date"],
  ["totalAmountVnd", "Giá mua", "money"],
  ["status", "Trạng thái đơn", "status"],
  ["checkout.commission.state", "Đối soát", "status"],
  ["checkout.commission.cashback.userAmount", "Cashback", "money"],
];

/** Web `/app/orders` → UserOrdersPage. */
export default function OrdersScreen() {
  const t = useCopy();
  return (
    <Page title={t("Đơn hàng của bạn")} description="Các đơn hàng của bạn mua qua Piggy sẽ được hiển thị dưới đây nè.">
      <FinanceTable
        path="me/orders"
        searchLabel="Mã đơn Shopee, TikTok"
        states={["VALIDATED", "REJECTED", "PARTIALLY_VALIDATED", "MANUAL_REVIEW"]}
        specs={orderSpecs}
        actions={(row) => (
          <Pressable accessibilityRole="link" style={styles.detail} onPress={() => router.push(`/orders/${row.id}`)}>
            <Text style={styles.detailText}>{t("Chi tiết")}</Text>
          </Pressable>
        )}
      />
    </Page>
  );
}

const styles = StyleSheet.create({
  detail: { minHeight: 44, justifyContent: "center" },
  detailText: { ...font(16, 500), color: colors.primary, textDecorationLine: "underline" },
});

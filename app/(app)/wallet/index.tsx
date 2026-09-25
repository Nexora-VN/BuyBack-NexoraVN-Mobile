import { router } from "expo-router";
import { StyleSheet, Text, View } from "react-native";
import { Button } from "../../../src/components/ui/Button";
import { Card } from "../../../src/components/ui/Card";
import { Page } from "../../../src/components/ui/Page";
import { colors, font } from "../../../src/constants/colors";
import { useCopy } from "../../../src/i18n/use-copy";
import { CashbackOverview } from "../../../src/modules/finance/components/Dashboard";
import { FinanceTable } from "../../../src/modules/finance/components/FinanceTable";
import { useFinance } from "../../../src/modules/finance/use-finance";
import type { Dashboard } from "../../../src/types/finance";

/** Web `/app/wallet` → WalletPage. */
export default function WalletScreen() {
  const t = useCopy();
  const wallet = useFinance<Dashboard>("me/dashboard");
  return (
    <Page
      title={t("Ví của bạn")}
      actions={<Button label={t("Yêu cầu rút")} onPress={() => router.push("/withdrawals/new")} />}
    >
      <CashbackOverview />
      <View style={styles.links}>
        <Button variant="outline" label={t("Lịch sử hoàn tiền")} onPress={() => router.push("/cashback")} />
        <Button variant="outline" label={t("Lịch sử rút tiền")} onPress={() => router.push("/withdrawals")} />
      </View>
      {wallet.data && BigInt(wallet.data.wallet.available) < 0n ? (
        <Card accessibilityRole="alert">
          <Text style={styles.alert}>
            {t(
              "Ví đang có khoản hoàn trả sau điều chỉnh đơn hàng. Bạn có thể rút tiếp khi số dư khả dụng đủ mức tối thiểu.",
            )}
          </Text>
        </Card>
      ) : null}
      <FinanceTable
        path="me/wallet/transactions"
        searchLabel="Mã tham chiếu"
        specs={[
          ["type", t("Loại giao dịch")],
          ["availableDelta", t("Thay đổi khả dụng"), "money"],
          ["reservedDelta", t("Thay đổi đang giữ"), "money"],
          ["availableAfter", t("Khả dụng sau giao dịch"), "money"],
          ["createdAt", t("Thời gian"), "date"],
        ]}
      />
    </Page>
  );
}

const styles = StyleSheet.create({
  links: { flexDirection: "row", flexWrap: "wrap", gap: 12 },
  alert: { ...font(16), color: colors.foreground },
});

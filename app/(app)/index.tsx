import { router } from "expo-router";
import { Pressable, StyleSheet, Text, View } from "react-native";
import { Page } from "../../src/components/ui/Page";
import { colors, font } from "../../src/constants/colors";
import { useCopy } from "../../src/i18n/use-copy";
import { GenerateLinkPanel } from "../../src/modules/affiliate/GenerateLinkPanel";
import { CashbackOverview, RecentOrders } from "../../src/modules/finance/components/Dashboard";

/** Web `/app` → UserDashboardPage. */
export default function DashboardScreen() {
  const t = useCopy();
  return (
    <Page
      title={t("Mua sắm cùng hoàn tiền cùng Piggy nào!")}
      description="Dán link Shopee, Tiktok để và bạn có thể biết được hoa hồng dự tính để mua sắm nhaa."
    >
      <GenerateLinkPanel />
      <CashbackOverview />
      <View style={styles.section}>
        <View style={styles.sectionHead}>
          <Text style={styles.h2}>{t("Đơn hàng gần đây")}</Text>
          <Pressable accessibilityRole="link" onPress={() => router.navigate("/orders")}>
            <Text style={styles.link}>{t("Xem tất cả")}</Text>
          </Pressable>
        </View>
        <RecentOrders />
      </View>
    </Page>
  );
}

const styles = StyleSheet.create({
  section: { gap: 16 },
  sectionHead: { flexDirection: "row", alignItems: "center", justifyContent: "space-between" },
  h2: { ...font(18, 600), color: colors.foreground },
  link: { ...font(14, 500), color: colors.primary },
});

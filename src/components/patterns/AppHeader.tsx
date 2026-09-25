import { router } from "expo-router";
import { Link2, WalletCards } from "lucide-react-native";
import { Pressable, StyleSheet, Text, View } from "react-native";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { colors, font } from "../../constants/colors";
import { useCopy } from "../../i18n/use-copy";

/** Port of the web `UserShell` header at mobile width: logo + "Piggy", and the create-link shortcut. */
export function AppHeader() {
  const t = useCopy();
  const insets = useSafeAreaInsets();
  return (
    <View style={[styles.header, { paddingTop: insets.top }]}>
      <View style={styles.bar}>
        <Pressable accessibilityRole="link" onPress={() => router.navigate("/")} style={styles.brand}>
          <View style={styles.logo}>
            <WalletCards color={colors.primaryForeground} size={20} />
          </View>
          {/* web: "Piggy <span hidden sm:inline>Back</span>" — "Back" is hidden below 640px. */}
          <Text style={styles.brandText}>Piggy</Text>
        </Pressable>
        <Pressable
          accessibilityRole="link"
          accessibilityLabel={t("Tạo link")}
          onPress={() => router.navigate("/links/new")}
          style={({ pressed }) => [styles.createLink, pressed && styles.pressed]}
        >
          <Link2 color={colors.primary} size={20} />
        </Pressable>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  header: { backgroundColor: colors.card, borderBottomWidth: 1, borderBottomColor: colors.border, zIndex: 30 },
  bar: {
    height: 64,
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    gap: 16,
    paddingHorizontal: 16,
  },
  brand: { flexDirection: "row", alignItems: "center", gap: 8, flexShrink: 0 },
  logo: {
    width: 36,
    height: 36,
    borderRadius: 18,
    backgroundColor: colors.primary,
    alignItems: "center",
    justifyContent: "center",
  },
  brandText: { ...font(16, 700), color: colors.primary },
  createLink: {
    width: 44,
    height: 44,
    borderRadius: 22,
    backgroundColor: colors.secondary,
    alignItems: "center",
    justifyContent: "center",
  },
  pressed: { opacity: 0.85 },
});

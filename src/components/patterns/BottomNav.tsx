import { router, usePathname } from "expo-router";
import { ClipboardList, House, UserRound, WalletCards, type LucideIcon } from "lucide-react-native";
import { useEffect, useState } from "react";
import { Keyboard, Pressable, StyleSheet, Text, View } from "react-native";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { colors, font } from "../../constants/colors";
import { useCopy } from "../../i18n/use-copy";
import { useChrome } from "./chrome";

// web app-shell.tsx `nav` (lucide `Home` is an alias of `House`).
const nav: { href: string; label: string; icon: LucideIcon }[] = [
  { href: "/", label: "Trang chủ", icon: House },
  { href: "/orders", label: "Đơn hàng", icon: ClipboardList },
  { href: "/wallet", label: "Ví", icon: WalletCards },
  { href: "/account", label: "Tài khoản", icon: UserRound },
];

/** Port of web `userNavActive` with the `/app` prefix removed. */
export function userNavActive(path: string, href: string) {
  if (href === "/") return path === "/" || path.startsWith("/links");
  if (href === "/wallet") return ["/wallet", "/cashback", "/withdrawals"].some((route) => path.startsWith(route));
  return path.startsWith(href);
}

/** Port of `.app-bottom-nav`: 4 equal columns, 8px padding, active item `bg-secondary text-primary`. */
export function BottomNav() {
  const t = useCopy();
  const path = usePathname();
  const insets = useSafeAreaInsets();
  const { navHidden } = useChrome();
  const [keyboard, setKeyboard] = useState(false);

  // web hides the nav while an input is focused (`body:has(input:focus) .app-bottom-nav`).
  useEffect(() => {
    const show = Keyboard.addListener("keyboardDidShow", () => setKeyboard(true));
    const hide = Keyboard.addListener("keyboardDidHide", () => setKeyboard(false));
    return () => {
      show.remove();
      hide.remove();
    };
  }, []);

  if (navHidden || keyboard) return null;
  return (
    <View
      accessibilityRole="tablist"
      accessibilityLabel={t("Điều hướng chính")}
      style={[styles.nav, { paddingBottom: Math.max(8, insets.bottom) }]}
    >
      {nav.map(({ href, label, icon: Icon }) => {
        const active = userNavActive(path, href);
        return (
          <Pressable
            key={href}
            accessibilityRole="tab"
            accessibilityState={{ selected: active }}
            onPress={() => router.navigate(href as never)}
            style={[styles.item, active && styles.itemActive]}
          >
            <Icon color={active ? colors.primary : colors.mutedForeground} size={20} />
            <Text style={[styles.label, { color: active ? colors.primary : colors.mutedForeground }]}>{t(label)}</Text>
          </Pressable>
        );
      })}
    </View>
  );
}

const styles = StyleSheet.create({
  nav: {
    flexDirection: "row",
    backgroundColor: colors.card,
    borderTopWidth: 1,
    borderTopColor: colors.border,
    paddingTop: 8,
    paddingHorizontal: 8,
  },
  item: {
    flex: 1,
    minHeight: 48,
    alignItems: "center",
    justifyContent: "center",
    gap: 4,
    borderRadius: 24,
  },
  itemActive: { backgroundColor: colors.secondary },
  label: { ...font(12, 500) },
});

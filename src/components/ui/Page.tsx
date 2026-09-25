import { router, useIsFocused, usePathname } from "expo-router";
import { ArrowLeft, Inbox } from "lucide-react-native";
import { useEffect, useState, type ReactNode } from "react";
import { Animated, Easing, RefreshControl, ScrollView, StyleSheet, Text, View } from "react-native";
import { useQueryClient } from "@tanstack/react-query";
import { colors, font } from "../../constants/colors";
import { useCopy } from "../../i18n/use-copy";
import { useChrome } from "../patterns/chrome";
import { Button } from "./Button";

/**
 * Port of web `Page` + `.app-page`: padding 20/16, 24px gap between sections, page-enter animation
 * (opacity 0→1, translateY 8→0, 220ms ease-out). Detail routes (`/new` or an id) get the back button.
 */
export function Page({
  title,
  description,
  actions,
  badge,
  children,
  taskForm = false,
}: {
  title: string;
  description?: string;
  actions?: ReactNode;
  badge?: ReactNode;
  children: ReactNode;
  taskForm?: boolean;
}) {
  const t = useCopy();
  const path = usePathname();
  const detail = /\/(new|[0-9a-f-]{20,})$/.test(path);
  const focused = useIsFocused();
  const { setNavHidden } = useChrome();
  const client = useQueryClient();
  const [refreshing, setRefreshing] = useState(false);
  const [enter] = useState(() => new Animated.Value(0));

  useEffect(() => {
    // CSS `ease-out` = cubic-bezier(0, 0, 0.58, 1)
    Animated.timing(enter, { toValue: 1, duration: 220, easing: Easing.bezier(0, 0, 0.58, 1), useNativeDriver: true }).start();
  }, [enter]);

  // web: `.app-page[data-task-form]` hides the bottom navigation.
  useEffect(() => {
    if (!focused || !taskForm) return;
    setNavHidden(true);
    return () => setNavHidden(false);
  }, [focused, taskForm, setNavHidden]);

  function back() {
    if (router.canGoBack()) router.back();
    else router.replace((path.slice(0, path.lastIndexOf("/")) || "/") as never);
  }

  // Native-only addition (AGENTS.md phase 4): pull-to-refresh re-fetches every finance query.
  async function refresh() {
    setRefreshing(true);
    try {
      await client.invalidateQueries({ queryKey: ["finance"] });
    } finally {
      setRefreshing(false);
    }
  }

  return (
    <ScrollView
      style={styles.scroll}
      contentContainerStyle={[styles.page, taskForm && styles.taskForm]}
      keyboardShouldPersistTaps="handled"
      refreshControl={<RefreshControl refreshing={refreshing} onRefresh={refresh} tintColor={colors.primary} colors={[colors.primary]} />}
    >
      <Animated.View
        style={[
          styles.inner,
          { opacity: enter, transform: [{ translateY: enter.interpolate({ inputRange: [0, 1], outputRange: [8, 0] }) }] },
        ]}
      >
        <View style={styles.heading}>
          <View style={styles.titleRow}>
            {detail ? (
              <Button size="icon" variant="ghost" icon={ArrowLeft} onPress={back} accessibilityLabel={t("Quay lại")} />
            ) : null}
            <View style={styles.titleCol}>
              <View style={styles.titleWrap}>
                <Text accessibilityRole="header" style={styles.title}>
                  {t(title)}
                </Text>
                {badge}
              </View>
              {description ? <Text style={styles.description}>{t(description)}</Text> : null}
            </View>
          </View>
          {actions ? <View style={styles.actions}>{actions}</View> : null}
        </View>
        {children}
      </Animated.View>
    </ScrollView>
  );
}

export function EmptyState({ title, description, action }: { title: string; description: string; action?: ReactNode }) {
  const t = useCopy();
  return (
    <View style={styles.empty}>
      <Inbox color={colors.primary} size={32} style={styles.emptyIcon} />
      <Text style={styles.emptyTitle}>{t(title)}</Text>
      <Text style={styles.emptyText}>{t(description)}</Text>
      {action ? <View style={styles.emptyAction}>{action}</View> : null}
    </View>
  );
}

const styles = StyleSheet.create({
  scroll: { flex: 1, backgroundColor: colors.background },
  // .app-page bottom padding is 96px under a fixed 65px nav; the nav is in-flow here, so 96 - 65.
  page: { paddingTop: 20, paddingHorizontal: 16, paddingBottom: 31 },
  taskForm: { paddingBottom: 24 },
  inner: { gap: 24 },
  heading: { gap: 16 },
  titleRow: { flexDirection: "row", alignItems: "flex-start", gap: 8 },
  titleCol: { flex: 1, minWidth: 0 },
  titleWrap: { flexDirection: "row", flexWrap: "wrap", alignItems: "center", gap: 8 },
  title: { ...font(20, 700), letterSpacing: -0.5, color: colors.foreground },
  description: { ...font(14, 400, 24), color: colors.mutedForeground, marginTop: 8 },
  actions: { flexDirection: "row", flexWrap: "wrap", gap: 8 },
  empty: {
    backgroundColor: colors.card,
    borderRadius: 16,
    borderWidth: 1,
    borderColor: colors.border,
    paddingHorizontal: 20,
    paddingVertical: 40,
    alignItems: "center",
  },
  emptyIcon: { marginBottom: 16 },
  emptyTitle: { ...font(16, 600), color: colors.foreground, textAlign: "center" },
  emptyText: { ...font(14, 400, 24), color: colors.mutedForeground, marginTop: 8, textAlign: "center", maxWidth: 448 },
  emptyAction: { marginTop: 20 },
});

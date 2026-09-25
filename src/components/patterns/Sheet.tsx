import { X } from "lucide-react-native";
import { createContext, useContext, useEffect, useState, type ReactNode } from "react";
import { KeyboardAvoidingView, Modal, Platform, Pressable, ScrollView, StyleSheet, Text, View } from "react-native";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { colors, extra, font } from "../../constants/colors";
import { useCopy } from "../../i18n/use-copy";
import { Button } from "../ui/Button";

const BusyContext = createContext<((busy: boolean) => void) | null>(null);

/** Children (forms) mark the dialog busy so it can't be dismissed mid-request. */
export function useDialogBusy(busy: boolean) {
  const setBusy = useContext(BusyContext);
  useEffect(() => {
    setBusy?.(busy);
    return () => setBusy?.(false);
  }, [busy, setBusy]);
}

/**
 * Port of web `SurfaceDialog`: `compact` → `.app-sheet` (bottom sheet, 24px top radius, max 90% height);
 * otherwise `.app-dialog` (full-screen). Header: `.dialog-header` (px-20 py-12, bottom border).
 */
export function Sheet({
  open,
  onOpenChange,
  title,
  children,
  compact = false,
  busy = false,
}: {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  title: string;
  children: ReactNode;
  compact?: boolean;
  busy?: boolean;
}) {
  const t = useCopy();
  const insets = useSafeAreaInsets();
  const [childBusy, setChildBusy] = useState(false);
  const locked = busy || childBusy;
  const close = () => {
    if (!locked) onOpenChange(false);
  };
  return (
    <Modal
      visible={open}
      transparent
      animationType={compact ? "slide" : "fade"}
      onRequestClose={close}
      statusBarTranslucent
    >
      <View style={styles.root}>
        <Pressable accessibilityLabel={t("Đóng")} style={styles.overlay} onPress={close} />
        <KeyboardAvoidingView
          behavior={Platform.OS === "ios" ? "padding" : undefined}
          style={[compact ? styles.sheetWrap : styles.dialogWrap, styles.passThrough]}
        >
          <View
            accessibilityRole={"dialog" as never}
            aria-modal
            style={[compact ? styles.sheet : [styles.dialog, { paddingTop: insets.top }]]}
          >
            <View style={styles.header}>
              <Text style={styles.title}>{t(title)}</Text>
              <Button
                size="icon"
                variant="ghost"
                icon={X}
                disabled={locked}
                accessibilityLabel={t("Đóng")}
                onPress={close}
              />
            </View>
            <ScrollView
              style={compact ? undefined : styles.flex}
              contentContainerStyle={[styles.body, { paddingBottom: 24 + insets.bottom }]}
              keyboardShouldPersistTaps="handled"
            >
              <BusyContext.Provider value={setChildBusy}>{children}</BusyContext.Provider>
            </ScrollView>
          </View>
        </KeyboardAvoidingView>
      </View>
    </Modal>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1 },
  flex: { flex: 1 },
  overlay: { ...StyleSheet.absoluteFill, backgroundColor: extra.overlay },
  sheetWrap: { flex: 1, justifyContent: "flex-end" },
  dialogWrap: { flex: 1 },
  passThrough: { pointerEvents: "box-none" },
  sheet: {
    maxHeight: "90%",
    backgroundColor: colors.card,
    borderTopLeftRadius: 24,
    borderTopRightRadius: 24,
  },
  dialog: { flex: 1, backgroundColor: colors.card },
  header: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    gap: 16,
    paddingHorizontal: 20,
    paddingVertical: 12,
    borderBottomWidth: 1,
    borderBottomColor: colors.border,
  },
  title: { ...font(18, 600), color: colors.foreground, flexShrink: 1 },
  body: { padding: 20 },
});

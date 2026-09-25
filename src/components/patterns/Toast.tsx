import { CircleAlert, CircleCheck } from "lucide-react-native";
import { createContext, useCallback, useContext, useEffect, useMemo, useState, type ReactNode } from "react";
import { Animated, Pressable, StyleSheet, Text, View } from "react-native";
import { useSafeAreaInsets } from "react-native-safe-area-context";

type Kind = "success" | "error";
type Item = { id: number; kind: Kind; message: string };

// sonner `richColors` palette; sonner renders with the system UI font, not the app font.
const palette = {
  success: { bg: "#ecfdf3", border: "#bffcd9", fg: "#008a2e", Icon: CircleCheck },
  error: { bg: "#fff0f0", border: "#ffe0e1", fg: "#e60000", Icon: CircleAlert },
} as const;

type Toast = { success: (message: string) => void; error: (message: string) => void };
const ToastContext = createContext<Toast>({ success: () => {}, error: () => {} });
export const useToast = () => useContext(ToastContext);

let nextId = 0;

/** Mobile equivalent of `<Toaster richColors position="top-right" />` (full-width with 16px insets below 600px). */
export function ToastProvider({ children }: { children: ReactNode }) {
  const [items, setItems] = useState<Item[]>([]);
  const insets = useSafeAreaInsets();
  const push = useCallback((kind: Kind, message: string) => {
    const id = ++nextId;
    setItems((list) => [{ id, kind, message }, ...list].slice(0, 3));
    setTimeout(() => setItems((list) => list.filter((i) => i.id !== id)), 4000);
  }, []);
  const api = useMemo<Toast>(() => ({ success: (m) => push("success", m), error: (m) => push("error", m) }), [push]);
  return (
    <ToastContext.Provider value={api}>
      {children}
      <View style={[styles.stack, { top: insets.top + 16 }]}>
        {items.map((item) => (
          <ToastView key={item.id} item={item} onDismiss={() => setItems((l) => l.filter((i) => i.id !== item.id))} />
        ))}
      </View>
    </ToastContext.Provider>
  );
}

function ToastView({ item, onDismiss }: { item: Item; onDismiss: () => void }) {
  const p = palette[item.kind];
  const [anim] = useState(() => new Animated.Value(0));
  useEffect(() => {
    Animated.timing(anim, { toValue: 1, duration: 400, useNativeDriver: true }).start();
  }, [anim]);
  return (
    <Animated.View
      accessibilityRole="alert"
      style={{ opacity: anim, transform: [{ translateY: anim.interpolate({ inputRange: [0, 1], outputRange: [-24, 0] }) }] }}
    >
      <Pressable onPress={onDismiss} style={[styles.toast, { backgroundColor: p.bg, borderColor: p.border }]}>
        <p.Icon color={p.bg} fill={p.fg} size={16} style={styles.icon} />
        <Text style={[styles.text, { color: p.fg }]}>{item.message}</Text>
      </Pressable>
    </Animated.View>
  );
}

const styles = StyleSheet.create({
  stack: { position: "absolute", left: 16, right: 16, gap: 8, zIndex: 999, pointerEvents: "box-none" },
  toast: {
    flexDirection: "row",
    alignItems: "center",
    gap: 6,
    padding: 16,
    borderRadius: 8,
    borderWidth: 1,
    boxShadow: "0 4px 12px rgba(0, 0, 0, 0.1)",
  },
  // sonner [data-icon]: 16×16, margin-left -3px, margin-right 4px
  icon: { marginLeft: -3, marginRight: 4, flexShrink: 0 },
  text: { fontSize: 13, lineHeight: 19.5, fontWeight: "500", flexShrink: 1 },
});

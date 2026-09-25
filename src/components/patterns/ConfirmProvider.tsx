import { createContext, useContext, useRef, useState, type ReactNode } from "react";
import { StyleSheet, Text, View } from "react-native";
import { colors, font } from "../../constants/colors";
import { useCopy } from "../../i18n/use-copy";
import { Button } from "../ui/Button";
import { Sheet } from "./Sheet";

const ConfirmContext = createContext<(message: string) => Promise<boolean>>(() => Promise.resolve(false));
export const useConfirm = () => useContext(ConfirmContext);

/** Port of web `ConfirmProvider`: compact sheet titled "Xác nhận thao tác" with Hủy / Xác nhận (danger). */
export function ConfirmProvider({ children }: { children: ReactNode }) {
  const t = useCopy();
  const [message, setMessage] = useState<string | null>(null);
  const resolve = useRef<((value: boolean) => void) | null>(null);
  function finish(value: boolean) {
    resolve.current?.(value);
    resolve.current = null;
    setMessage(null);
  }
  return (
    <ConfirmContext.Provider
      value={(next) =>
        new Promise<boolean>((done) => {
          resolve.current?.(false);
          resolve.current = done;
          setMessage(next);
        })
      }
    >
      {children}
      <Sheet
        compact
        open={message !== null}
        onOpenChange={(open) => {
          if (!open) finish(false);
        }}
        title={t("Xác nhận thao tác")}
      >
        <Text style={styles.message}>{message ? t(message) : ""}</Text>
        <View style={styles.actions}>
          <Button variant="outline" label={t("Hủy")} onPress={() => finish(false)} />
          <Button variant="danger" label={t("Xác nhận")} onPress={() => finish(true)} />
        </View>
      </Sheet>
    </ConfirmContext.Provider>
  );
}

const styles = StyleSheet.create({
  message: { ...font(14, 400, 24), color: colors.foreground },
  actions: { marginTop: 24, flexDirection: "row", justifyContent: "flex-end", gap: 12 },
});

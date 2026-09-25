import * as Clipboard from "expo-clipboard";
import { StyleSheet, Text, View } from "react-native";
import { colors, font } from "../../constants/colors";
import { useCopy } from "../../i18n/use-copy";
import { ApiError } from "../../lib/api/errors";
import { Button } from "../ui/Button";
import { Card } from "../ui/Card";
import { Skeleton } from "../ui/Skeleton";
import { useToast } from "./Toast";

/** web finance-states `Loading`: skeleton h-12 w-2/3 rounded-xl + two h-28 rounded-2xl blocks. */
export function Loading() {
  const t = useCopy();
  return (
    <View accessibilityRole="progressbar" accessibilityLabel={t("Đang tải")} style={styles.loading}>
      <Skeleton height={48} width="66.6667%" radius={24} />
      <Skeleton height={112} radius={16} />
      <Skeleton height={112} radius={16} />
    </View>
  );
}

/** web `ApiErrorNotice`: danger text plus a copyable request id. */
export function ApiErrorNotice({ error }: { error: unknown }) {
  const t = useCopy();
  const toast = useToast();
  if (!error) return null;
  const id = error instanceof ApiError ? error.requestId : undefined;
  return (
    <View accessibilityRole="alert">
      <Text style={styles.danger}>{t.error(error instanceof Error ? error.message : "Không thể xử lý yêu cầu.")}</Text>
      {id ? (
        <Button
          variant="ghost"
          size="sm"
          style={styles.selfStart}
          label={`Mã tra lỗi: ${id}`}
          // ghost button inherits the alert's text-danger color on the web
          color={colors.danger}
          onPress={() =>
            void Clipboard.setStringAsync(id).then(
              () => toast.success(t("Đã sao chép")),
              () => toast.error(t("Không thể sao chép")),
            )
          }
        />
      ) : null}
    </View>
  );
}

/** web finance-states `Failure`: Card(role=alert) with the error and an outline "Thử lại" button. */
export function Failure({ message, retry, error }: { message: string; retry: () => void; error?: unknown }) {
  const t = useCopy();
  return (
    <Card accessibilityRole="alert">
      {error ? <ApiErrorNotice error={error} /> : <Text style={styles.dangerBase}>{t.error(message)}</Text>}
      <Button variant="outline" label={t("Thử lại")} onPress={retry} style={[styles.retry, styles.selfStart]} />
    </Card>
  );
}

const styles = StyleSheet.create({
  loading: { gap: 12 },
  danger: { ...font(14), color: colors.danger },
  dangerBase: { ...font(16), color: colors.danger },
  retry: { marginTop: 12 },
  selfStart: { alignSelf: "flex-start" },
});

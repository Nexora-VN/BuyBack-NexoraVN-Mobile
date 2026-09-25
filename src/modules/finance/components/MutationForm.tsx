import { createContext, useContext, useRef, useState, type ReactNode } from "react";
import { StyleSheet, Text, View } from "react-native";
import type { z } from "zod";
import { ApiErrorNotice } from "../../../components/patterns/QueryState";
import { Sheet, useDialogBusy } from "../../../components/patterns/Sheet";
import { useToast } from "../../../components/patterns/Toast";
import { Button } from "../../../components/ui/Button";
import { Input } from "../../../components/ui/Input";
import { colors, font } from "../../../constants/colors";
import { useCopy } from "../../../i18n/use-copy";
import { financeService } from "../../../lib/api/finance-service";
import { useRefreshFinance } from "../use-finance";

export type Field = { name: string; label: string; help?: string; required?: boolean };

const ActionContext = createContext<(() => void) | null>(null);

/** Port of web `ActionDialog`: outline sm trigger that opens a full-screen SurfaceDialog. */
export function ActionDialog({ label, children }: { label: string; children: ReactNode }) {
  const t = useCopy();
  const [open, setOpen] = useState(false);
  return (
    <>
      <Button variant="outline" size="sm" label={t(label)} onPress={() => setOpen(true)} />
      <Sheet open={open} onOpenChange={setOpen} title={t(label)}>
        <ActionContext.Provider value={() => setOpen(false)}>{children}</ActionContext.Provider>
      </Sheet>
    </>
  );
}

/** Port of web `MutationForm` (text fields only — the user area uses no select/textarea fields). */
export function MutationForm({
  title,
  fields,
  path,
  method = "post",
  schema,
  initialValues = {},
}: {
  title: string;
  fields: Field[];
  path: string;
  method?: "post" | "put" | "patch";
  schema?: z.ZodType;
  initialValues?: Record<string, string>;
}) {
  const t = useCopy();
  const toast = useToast();
  const close = useContext(ActionContext);
  const refresh = useRefreshFinance();
  const [values, setValues] = useState<Record<string, string>>(initialValues);
  const [errors, setErrors] = useState<Record<string, string>>({});
  const [error, setError] = useState<unknown>(null);
  const [pending, setPending] = useState(false);
  const [review, setReview] = useState(false);
  const lock = useRef(false);
  useDialogBusy(pending);

  async function send() {
    if (lock.current) return;
    lock.current = true;
    setPending(true);
    setError(null);
    try {
      await financeService.mutate(path, values, method);
      setValues(initialValues);
      setReview(false);
      await refresh();
      close?.();
      toast.success(t("Đã lưu thay đổi"));
    } catch (e) {
      setError(e);
    } finally {
      lock.current = false;
      setPending(false);
    }
  }

  function validate() {
    const missing = fields.filter((field) => field.required !== false && !values[field.name]?.trim());
    if (missing.length) {
      setErrors(Object.fromEntries(missing.map((field) => [field.name, t("Vui lòng nhập trường này")])));
      return false;
    }
    const result = schema?.safeParse(values);
    if (result && !result.success) {
      const next: Record<string, string> = {};
      for (const issue of result.error.issues)
        next[String(issue.path[0] ?? "_form")] =
          issue.message.startsWith("Too ") || issue.message.startsWith("Invalid ") ? "Thông tin không hợp lệ" : issue.message;
      setErrors(next);
      return false;
    }
    setErrors({});
    return true;
  }

  return (
    <View style={styles.box}>
      <View style={styles.form}>
        <Text style={styles.title}>{review ? t("Kiểm tra thông tin") : t(title)}</Text>
        {review ? (
          <View>
            {fields.map((field, index) => (
              <View key={field.name} style={[styles.reviewRow, index > 0 && styles.reviewDivider]}>
                <Text style={styles.dt}>{t(field.label)}</Text>
                <Text style={styles.dd}>{values[field.name] || "—"}</Text>
              </View>
            ))}
          </View>
        ) : (
          <View style={styles.fields}>
            {fields.map((field) => (
              <View key={field.name}>
                <Text style={styles.label}>{t(field.label)}</Text>
                <Input
                  value={values[field.name] ?? ""}
                  invalid={!!errors[field.name]}
                  keyboardType={field.name === "accountNumber" ? "number-pad" : "default"}
                  onChangeText={(v) => setValues((prev) => ({ ...prev, [field.name]: v }))}
                />
                {/* web: an (often empty) `mt-1 block` help span, then a `mt-1 block` error span. The empty
                    span's margin collapses with the error's, so the field keeps a single 4px gap. */}
                <View style={styles.helpBox}>{field.help ? <Text style={styles.help}>{t(field.help)}</Text> : null}</View>
                {errors[field.name] ? (
                  <Text accessibilityRole="alert" style={[styles.fieldError, !field.help && styles.collapsed]}>
                    {t(errors[field.name])}
                  </Text>
                ) : null}
              </View>
            ))}
          </View>
        )}
        {error || errors._form ? (
          <View accessibilityRole="alert">
            {error ? <ApiErrorNotice error={error} /> : <Text style={styles.fieldError}>{t(errors._form)}</Text>}
          </View>
        ) : null}
        <View style={styles.actions}>
          {review ? (
            <>
              <Button variant="outline" label={t("Chỉnh sửa")} disabled={pending} onPress={() => setReview(false)} />
              <Button label={t(pending ? "Đang xử lý…" : "Xác nhận")} disabled={pending} onPress={() => void send()} />
            </>
          ) : (
            <Button
              label={t(pending ? "Đang xử lý…" : "Tiếp tục")}
              disabled={pending}
              onPress={() => {
                if (validate()) setReview(true);
              }}
            />
          )}
        </View>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  box: { backgroundColor: colors.card, borderRadius: 16, borderWidth: 1, borderColor: colors.border, padding: 16 },
  form: { gap: 20 },
  title: { ...font(18, 600), color: colors.foreground },
  fields: { gap: 16 },
  label: { ...font(14, 500), color: colors.foreground, marginBottom: 8 },
  helpBox: { marginTop: 4 },
  help: { ...font(12, 400, 20), color: colors.mutedForeground },
  collapsed: { marginTop: 0 },
  fieldError: { ...font(14), color: colors.danger, marginTop: 4 },
  reviewRow: { paddingVertical: 12 },
  reviewDivider: { borderTopWidth: 1, borderTopColor: colors.border },
  dt: { ...font(14), color: colors.mutedForeground },
  dd: { ...font(16, 500), color: colors.foreground, marginTop: 4 },
  actions: {
    flexDirection: "row",
    justifyContent: "flex-end",
    gap: 12,
    paddingVertical: 16,
    borderTopWidth: 1,
    borderTopColor: colors.border,
    backgroundColor: colors.card,
  },
});

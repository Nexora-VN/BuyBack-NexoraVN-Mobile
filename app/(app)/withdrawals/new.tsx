import * as Crypto from "expo-crypto";
import { router } from "expo-router";
import { CheckCircle2 } from "lucide-react-native";
import { useRef, useState } from "react";
import { Pressable, StyleSheet, Text, View } from "react-native";
import { Failure, Loading } from "../../../src/components/patterns/QueryState";
import { Button } from "../../../src/components/ui/Button";
import { Card } from "../../../src/components/ui/Card";
import { Input, Select } from "../../../src/components/ui/Input";
import { Page } from "../../../src/components/ui/Page";
import { colors, font } from "../../../src/constants/colors";
import { useCopy } from "../../../src/i18n/use-copy";
import { financeService } from "../../../src/lib/api/finance-service";
import { formatVnd } from "../../../src/lib/format";
import { text } from "../../../src/modules/finance/components/columns";
import { withdrawalSchema } from "../../../src/modules/finance/schemas/finance";
import { useFinance, useRefreshFinance } from "../../../src/modules/finance/use-finance";
import type { FinanceList } from "../../../src/types/finance";

/** Web `/app/withdrawals/new` → NewWithdrawalPage. */
export default function NewWithdrawalScreen() {
  const t = useCopy();
  const banks = useFinance<FinanceList>("me/bank-accounts?status=APPROVED&limit=100");
  const wallet = useFinance<{ available: string }>("me/wallet");
  const [amount, setAmount] = useState("");
  const [bankId, setBank] = useState("");
  const [step, setStep] = useState<"edit" | "review" | "done">("edit");
  const [errors, setErrors] = useState<Record<string, string>>({});
  const [error, setError] = useState("");
  const [pending, setPending] = useState(false);
  const key = useRef<string | null>(null);
  const lock = useRef(false);
  const refresh = useRefreshFinance();
  const bank = banks.data?.data.find((row) => row.id === bankId);

  function validate() {
    const result = withdrawalSchema.safeParse({ amount, bankId });
    if (!result.success) {
      setErrors(Object.fromEntries(result.error.issues.map((i) => [String(i.path[0]), i.message])));
      return;
    }
    if (!wallet.data || BigInt(amount) > BigInt(wallet.data.available)) {
      setErrors({ amount: t("Số dư khả dụng không đủ") });
      return;
    }
    setErrors({});
    setStep("review");
  }

  async function send() {
    if (lock.current) return;
    lock.current = true;
    setPending(true);
    setError("");
    key.current ??= Crypto.randomUUID();
    try {
      await financeService.mutate("me/withdrawals", { amount, bankId, idempotencyKey: key.current });
      await refresh();
      key.current = null;
      setStep("done");
    } catch (e) {
      setError(e instanceof Error ? e.message : t("Không thể tạo yêu cầu"));
    } finally {
      lock.current = false;
      setPending(false);
    }
  }

  const hasBanks = !!banks.data?.data.length;

  return (
    <Page taskForm title={t("Yêu cầu rút tiền")} description="Tối thiểu 50.000 VND. Số tiền được giữ ngay khi gửi yêu cầu.">
      {banks.isLoading || wallet.isLoading ? (
        <Loading />
      ) : banks.isError || wallet.isError ? (
        <Failure
          message={(banks.error || wallet.error)?.message || t("Không thể tải dữ liệu")}
          retry={() => {
            void banks.refetch();
            void wallet.refetch();
          }}
        />
      ) : (
        <Card>
          {step === "done" ? (
            <View style={styles.done}>
              <CheckCircle2 color={colors.success} size={48} />
              <Text style={styles.doneTitle}>{t("Đã gửi yêu cầu rút tiền")}</Text>
              <Text style={styles.doneText}>
                {t("Số tiền được giữ để xử lý yêu cầu. Theo dõi tiến độ trong lịch sử rút tiền.")}
              </Text>
              <Button label={t("Xem lịch sử rút tiền")} onPress={() => router.replace("/withdrawals")} />
            </View>
          ) : (
            <View style={styles.form}>
              <View style={styles.balance}>
                <Text style={styles.balanceLabel}>{t("Có thể rút")}</Text>
                <Text style={styles.balanceValue}>{formatVnd(wallet.data!.available)}</Text>
              </View>
              {step === "edit" ? (
                <>
                  <View style={styles.field}>
                    <Text style={styles.fieldLabel}>{t("Số tiền (VND)")}</Text>
                    <Input
                      keyboardType="number-pad"
                      inputMode="numeric"
                      value={amount}
                      invalid={!!errors.amount}
                      style={errors.amount ? styles.beforeError : undefined}
                      onChangeText={(v) => {
                        setAmount(v);
                        key.current = null;
                      }}
                      onSubmitEditing={validate}
                    />
                    {errors.amount ? (
                      <Text accessibilityRole="alert" style={styles.fieldError}>
                        {t(errors.amount)}
                      </Text>
                    ) : null}
                  </View>
                  <View style={styles.field}>
                    <Text style={styles.fieldLabel}>{t("Tài khoản đã duyệt")}</Text>
                    <View style={errors.bankId ? styles.beforeError : undefined}>
                      <Select
                        title={t("Tài khoản đã duyệt")}
                        value={bankId}
                        invalid={!!errors.bankId}
                        onChange={(v) => {
                          setBank(v);
                          key.current = null;
                        }}
                        options={[
                          { value: "", label: t("Chọn tài khoản") },
                          ...(banks.data?.data ?? []).map((row) => ({
                            value: row.id,
                            label: `${text(row, "bankName")} · ****${text(row, "lastFour")}`,
                          })),
                        ]}
                      />
                    </View>
                    {errors.bankId ? (
                      <Text accessibilityRole="alert" style={styles.fieldError}>
                        {t(errors.bankId)}
                      </Text>
                    ) : null}
                  </View>
                  {!hasBanks ? (
                    <Pressable accessibilityRole="link" onPress={() => router.navigate("/account")}>
                      <Text style={styles.addBank}>{t("Thêm tài khoản ngân hàng để tiếp tục")}</Text>
                    </Pressable>
                  ) : null}
                </>
              ) : (
                <>
                  <Text style={styles.reviewTitle}>{t("Kiểm tra yêu cầu rút")}</Text>
                  <View style={styles.review}>
                    <View>
                      <Text style={styles.dt}>{t("Số tiền")}</Text>
                      <Text style={styles.reviewAmount}>{formatVnd(amount)}</Text>
                    </View>
                    <View>
                      <Text style={styles.dt}>{t("Ngân hàng nhận")}</Text>
                      <Text style={styles.dd}>
                        {text(bank, "bankName")} · ****{text(bank, "lastFour")}
                      </Text>
                      <Text style={styles.dd}>{text(bank, "accountHolder")}</Text>
                    </View>
                  </View>
                </>
              )}
              {error ? (
                <Text accessibilityRole="alert" style={styles.error}>
                  {t.error(error)}
                </Text>
              ) : null}
              <View style={styles.actions}>
                {step === "review" ? (
                  <>
                    <Button variant="outline" label={t("Chỉnh sửa")} disabled={pending} onPress={() => setStep("edit")} />
                    <Button
                      label={t(pending ? "Đang gửi…" : "Xác nhận rút tiền")}
                      disabled={pending}
                      onPress={() => void send()}
                    />
                  </>
                ) : (
                  <Button label={t("Tiếp tục")} disabled={!hasBanks} onPress={validate} />
                )}
              </View>
            </View>
          )}
        </Card>
      )}
    </Page>
  );
}

const styles = StyleSheet.create({
  done: { alignItems: "center", gap: 20, paddingVertical: 16 },
  doneTitle: { ...font(20, 600), color: colors.foreground, textAlign: "center" },
  doneText: { ...font(14, 400, 24), color: colors.mutedForeground, textAlign: "center" },
  form: { gap: 20 },
  balance: { backgroundColor: colors.muted, borderRadius: 24, padding: 16 },
  balanceLabel: { ...font(14), color: colors.mutedForeground },
  balanceValue: { ...font(24, 700), color: colors.primary, marginTop: 4 },
  // <label class="block space-y-2"> holding an inline span + input: measured 24 + 44, no visible gap.
  field: {},
  // Tailwind v4 space-y adds margin-block-end to every child but the last: once an error follows, the input gets 8px.
  beforeError: { marginBottom: 8 },
  fieldLabel: { ...font(16), color: colors.foreground },
  error: { ...font(14), color: colors.danger },
  // inline 14px span in the label's 24px line box: 1px below centre
  fieldError: { ...font(14, 400, 23), paddingTop: 1, color: colors.danger },
  addBank: { ...font(14), color: colors.primary, textDecorationLine: "underline" },
  reviewTitle: { ...font(18, 600), color: colors.foreground },
  review: { gap: 16 },
  dt: { ...font(14), color: colors.mutedForeground },
  dd: { ...font(16), color: colors.foreground },
  reviewAmount: { ...font(24, 700), color: colors.foreground },
  // web `.form-actions`: sticky footer, right-aligned, top border, card background.
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

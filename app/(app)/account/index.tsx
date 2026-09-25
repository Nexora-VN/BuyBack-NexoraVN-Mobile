import { router } from "expo-router";
import { useRef, useState } from "react";
import { StyleSheet, Text, View } from "react-native";
import { useConfirm } from "../../../src/components/patterns/ConfirmProvider";
import { LanguageSwitcher } from "../../../src/components/patterns/LanguageSwitcher";
import { useToast } from "../../../src/components/patterns/Toast";
import { Button } from "../../../src/components/ui/Button";
import { Card } from "../../../src/components/ui/Card";
import { Page } from "../../../src/components/ui/Page";
import { colors, font } from "../../../src/constants/colors";
import { useCopy } from "../../../src/i18n/use-copy";
import { financeService } from "../../../src/lib/api/finance-service";
import { text } from "../../../src/modules/finance/components/columns";
import { FinanceTable } from "../../../src/modules/finance/components/FinanceTable";
import { ActionDialog, MutationForm, type Field } from "../../../src/modules/finance/components/MutationForm";
import { bankSchema } from "../../../src/modules/finance/schemas/finance";
import { useRefreshFinance } from "../../../src/modules/finance/use-finance";
import { useAuth } from "../../../src/providers/auth-provider";

const bankFields: Field[] = [
  { name: "bankCode", label: "Mã ngân hàng" },
  { name: "bankName", label: "Tên ngân hàng" },
  { name: "accountHolder", label: "Tên chủ tài khoản" },
  { name: "accountNumber", label: "Số tài khoản" },
];

/** Web `/app/account` → AccountPage. */
export default function AccountScreen() {
  const t = useCopy();
  const toast = useToast();
  const { user, logout } = useAuth();
  const refresh = useRefreshFinance();
  const confirm = useConfirm();
  const [removing, setRemoving] = useState<string | null>(null);
  const removeLock = useRef(false);

  async function remove(id: string) {
    if (removeLock.current) return;
    if (!(await confirm(t("Gỡ tài khoản khỏi danh sách sử dụng? Yêu cầu rút đã tạo vẫn giữ nguyên thông tin.")))) return;
    removeLock.current = true;
    setRemoving(id);
    try {
      await financeService.remove("me/bank-accounts/" + id);
      await refresh();
      toast.success(t("Đã gỡ"));
    } catch (error) {
      toast.error(t.error(error instanceof Error ? error.message : "Không thể xóa"));
    } finally {
      setRemoving(null);
      removeLock.current = false;
    }
  }

  return (
    <Page title={t("Tài khoản của bạn")}>
      <Card>
        <Text style={styles.email}>{user?.email}</Text>
        <Text style={styles.muted}>
          {t(
            "Thông tin ngân hàng của bạn sẽ được bảo mật.  Thêm/ Sửa tài khoản ngân hàng của bạn để admin hỗ trợ duyệt/rút tiền cho bạn nha/",
          )}
        </Text>
      </Card>
      <View style={styles.bankHead}>
        <Text style={styles.h2}>{t("Tài khoản ngân hàng")}</Text>
        <ActionDialog label="Thêm tài khoản ngân hàng">
          <MutationForm title={t("Thêm tài khoản ngân hàng")} path="me/bank-accounts" fields={bankFields} schema={bankSchema} />
        </ActionDialog>
      </View>
      <FinanceTable
        path="me/bank-accounts"
        searchLabel="Tên chủ tài khoản"
        states={["PENDING", "APPROVED", "REJECTED"]}
        specs={[
          ["bankName", t("Ngân hàng")],
          ["accountHolder", t("Chủ tài khoản")],
          ["lastFour", t("4 số cuối")],
          ["status", t("Trạng thái"), "status"],
          ["reviewReason", t("Kết quả duyệt")],
        ]}
        actions={(row) => (
          <View style={styles.rowActions}>
            <ActionDialog label="Thay thông tin">
              <MutationForm
                title={t("Tạo phiên bản tài khoản mới")}
                path={"me/bank-accounts/" + row.id}
                method="patch"
                fields={bankFields}
                schema={bankSchema}
                initialValues={{
                  bankCode: text(row, "bankCode"),
                  bankName: text(row, "bankName"),
                  accountHolder: text(row, "accountHolder"),
                }}
              />
            </ActionDialog>
            <Button variant="outline" label={t("Gỡ")} disabled={removing !== null} onPress={() => void remove(row.id)} />
          </View>
        )}
      />
      <Card>
        <Text style={[styles.h2base, styles.mb16]}>{t("Ngôn ngữ")}</Text>
        <LanguageSwitcher grow />
      </Card>
      <View style={styles.footer}>
        <Button variant="outline" label={t("Link của tôi")} onPress={() => router.push("/links")} />
        <Button
          variant="outline"
          label={t("Đăng xuất")}
          onPress={async () => {
            await logout();
            router.replace("/login");
          }}
        />
      </View>
    </Page>
  );
}

const styles = StyleSheet.create({
  email: { ...font(16, 600), color: colors.foreground },
  muted: { ...font(14), color: colors.mutedForeground, marginTop: 8 },
  bankHead: { flexDirection: "row", flexWrap: "wrap", alignItems: "center", justifyContent: "space-between", gap: 12 },
  h2: { ...font(18, 600), color: colors.foreground },
  h2base: { ...font(16, 600), color: colors.foreground },
  mb16: { marginBottom: 16 },
  rowActions: { flexDirection: "row", gap: 8 },
  footer: { flexDirection: "row", flexWrap: "wrap", gap: 12 },
});

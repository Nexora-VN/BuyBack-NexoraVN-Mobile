import { Page } from "../../../src/components/ui/Page";
import { useCopy } from "../../../src/i18n/use-copy";
import { FinanceTable } from "../../../src/modules/finance/components/FinanceTable";

/** Web `/app/withdrawals` → WithdrawalHistoryPage. */
export default function WithdrawalHistoryScreen() {
  const t = useCopy();
  return (
    <Page title={t("Lịch sử rút tiền")}>
      <FinanceTable
        path="me/withdrawals"
        searchLabel="Mã chuyển khoản"
        states={["PENDING", "PROCESSING", "COMPLETED", "REJECTED", "FAILED"]}
        specs={[
          ["id", t("Mã yêu cầu")],
          ["amount", t("Số tiền"), "money"],
          ["bank.bankName", t("Ngân hàng")],
          ["bank.lastFour", t("4 số cuối")],
          ["status", t("Trạng thái"), "status"],
          ["createdAt", t("Ngày tạo"), "date"],
        ]}
      />
    </Page>
  );
}

import { Page } from "../../src/components/ui/Page";
import { useCopy } from "../../src/i18n/use-copy";
import { FinanceTable } from "../../src/modules/finance/components/FinanceTable";

/** Web `/app/cashback` → CashbackPage. */
export default function CashbackScreen() {
  const t = useCopy();
  return (
    <Page
      title="Cashback"
      description="Hoa hồng chờ trả chỉ là dự kiến. Cashback chỉ khả dụng sau khi xác nhận nhận tiền và hoàn tất kỳ thanh toán."
    >
      <FinanceTable
        path="me/cashbacks"
        searchLabel="Mã checkout Shopee"
        states={["PENDING", "VALIDATED", "AVAILABLE", "REJECTED", "REVERSED"]}
        specs={[
          ["commission.id", t("Mã hoa hồng")],
          ["userAmount", "Cashback", "money"],
          ["state", t("Trạng thái"), "status"],
          ["createdAt", t("Ghi nhận"), "date"],
        ]}
      />
    </Page>
  );
}

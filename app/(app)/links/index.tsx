import * as Clipboard from "expo-clipboard";
import { router } from "expo-router";
import { useToast } from "../../../src/components/patterns/Toast";
import { Button } from "../../../src/components/ui/Button";
import { Page } from "../../../src/components/ui/Page";
import { useCopy } from "../../../src/i18n/use-copy";
import { text } from "../../../src/modules/finance/components/columns";
import { FinanceTable } from "../../../src/modules/finance/components/FinanceTable";

/** Web `/app/links` → LinkHistoryPage. */
export default function LinkHistoryScreen() {
  const t = useCopy();
  const toast = useToast();
  return (
    <Page title={t("Link của tôi")} actions={<Button label={t("Tạo link mới")} onPress={() => router.push("/links/new")} />}>
      <FinanceTable
        path="me/affiliate-links"
        searchLabel="Tìm URL gốc"
        specs={[
          ["product.productName", t("Sản phẩm")],
          ["affiliateLinkStatus", t("Trạng thái"), "status"],
          ["createdAt", t("Ngày tạo"), "date"],
        ]}
        actions={(row) => (
          <Button
            variant="outline"
            size="sm"
            label={t("Sao chép link")}
            onPress={() =>
              void Clipboard.setStringAsync(text(row, "fullLinkSystem"))
                .then(() => toast.success(t("Đã sao chép")))
                .catch(() => toast.error(t.error("Không thể sao chép")))
            }
          />
        )}
      />
    </Page>
  );
}

import { Page } from "../../../src/components/ui/Page";
import { useCopy } from "../../../src/i18n/use-copy";
import { GenerateLinkPanel } from "../../../src/modules/affiliate/GenerateLinkPanel";

/** Web `/app/links/new` → GenerateLinkPage. */
export default function GenerateLinkScreen() {
  const t = useCopy();
  return (
    <Page title={t("Tạo link cashback")} description="Dán link sản phẩm Shopee để xem hoa hồng dự kiến và bắt đầu mua sắm.">
      <GenerateLinkPanel />
    </Page>
  );
}

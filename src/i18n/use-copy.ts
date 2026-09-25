import { useTranslation } from "react-i18next";
import keys from "../../translations/copy-keys.json";

const errors: Record<string, string> = {
  INSUFFICIENT_BALANCE: "Số dư khả dụng không đủ",
  WITHDRAWALS_DISABLED: "Rút tiền đang tạm dừng",
  SETTLEMENT_DISABLED: "Quyết toán đang tạm dừng",
  BANK_NOT_APPROVED: "Tài khoản ngân hàng chưa được duyệt",
  COMMISSIONS_NOT_ELIGIBLE: "Hoa hồng chưa đủ điều kiện quyết toán",
  PROVIDER_COMMISSION_NOT_PAID: "Đối tác chưa xác nhận trả hoa hồng",
  VERIFY_ACCOUNT_AND_VND_FIRST: "Cần xác thực tài khoản và đơn vị VND",
  OPEN_RECONCILIATION_ISSUES: "Còn vấn đề đối soát chưa xử lý",
  CROSS_PROVIDER_DUPLICATE: "Trùng đơn giữa các nguồn",
  GROSS_DIFFERS_FROM_VALIDATED_COMMISSION: "Tổng phải khớp hoa hồng đã chọn",
  SETTLEMENT_TOTALS_MISMATCH: "Thực nhận phải bằng tổng trước phí trừ khấu trừ",
  COMMISSION_REVISION_CHANGED: "Dữ liệu đã thay đổi. Vui lòng tải lại và kiểm tra.",
  COMMISSION_CHANGED_RESYNC_REQUIRED: "Dữ liệu đã thay đổi. Vui lòng tải lại và kiểm tra.",
  "Invalid credentials": "Email hoặc mật khẩu không đúng",
  Unauthorized: "Phiên đăng nhập đã hết hạn",
  Forbidden: "Bạn không có quyền thực hiện thao tác này",
};

type TranslationValues = Record<string, string | number>;

export function useCopy() {
  const { t } = useTranslation("UI");
  // The web renders copy as HTML, which collapses runs of whitespace; RN <Text> would keep them.
  const copy = (source: string, values?: TranslationValues) => {
    const key = (keys as Record<string, string>)[source];
    return (key ? t(key, values) : source).replace(/\s{2,}/g, " ");
  };
  return Object.assign(copy, {
    error: (source: string) => {
      const message = errors[source] ?? source;
      if ((keys as Record<string, string>)[message]) return copy(message);
      return (
        copy("Không thể hoàn tất yêu cầu. Vui lòng thử lại.") +
        (/^[A-Z][A-Z_]+$/.test(source) ? ` (${source})` : "")
      );
    },
  });
}

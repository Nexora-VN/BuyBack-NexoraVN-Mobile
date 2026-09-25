// Copied from the web frontend (modules/finance/schemas/finance.ts) — user-area schemas only.
import { z } from "zod";
const amount = z.string().regex(/^\d{1,18}$/, "Nhập số nguyên VND");
export const withdrawalSchema = z.object({
  bankId: z.uuid("Chọn tài khoản ngân hàng"),
  amount: amount.refine((v) => {
    try {
      return /^\d+$/.test(v) && BigInt(v) >= 50000n;
    } catch {
      return false;
    }
  }, "Tối thiểu 50.000 VND"),
});
export const bankSchema = z.object({
  bankCode: z.string().trim().min(2, "Nhập ít nhất 2 ký tự"),
  bankName: z.string().trim().min(2, "Nhập ít nhất 2 ký tự"),
  accountHolder: z.string().trim().min(2, "Nhập ít nhất 2 ký tự"),
  accountNumber: z.string().regex(/^[0-9]{6,30}$/, "Số tài khoản gồm 6–30 chữ số"),
});

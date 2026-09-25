export interface FinanceRow {
  id: string;
  [key: string]: unknown;
}

export interface FinanceList<T extends FinanceRow = FinanceRow> {
  data: T[];
  meta: { page: number; limit: number; total: number; totalPages: number };
}

export interface Dashboard {
  orders: number;
  cashbackSummary?: { state: string; userAmount: string; count: number }[];
  wallet: { available: string; reserved: string };
  commissions: {
    state: string;
    _count: number;
    _sum: { estimatedVnd: string | null; settledVnd: string | null };
  }[];
}

export interface ProductSummary {
  name: string | null;
  imageUrl: string | null;
  itemCount: number;
  platform?: string | null;
}

export interface OrderRow extends FinanceRow {
  orderSn: string;
  status: string;
  platform?: string;
  totalAmountVnd?: string;
  productSummary: ProductSummary;
  checkout: {
    purchasedAt: string | null;
    commission: { state: string; cashback: { state: string; userAmount: string } | null } | null;
  };
}

export interface BankAccountRow extends FinanceRow {
  bankCode: string;
  bankName: string;
  accountHolder: string;
  accountNumber?: string;
  lastFour: string;
  status: string;
  reviewReason?: string | null;
}

export interface WithdrawalRow extends FinanceRow {
  amount: string;
  status: string;
  bank: { bankName: string; lastFour: string };
  createdAt: string;
}

export interface WalletTransactionRow extends FinanceRow {
  type: string;
  availableDelta: string;
  reservedDelta: string;
  availableAfter: string;
  createdAt: string;
}

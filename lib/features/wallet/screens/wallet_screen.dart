import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/stat_card.dart';
import '../../finance/models/dashboard_model.dart';
import '../../finance/models/wallet_transaction_model.dart';
import '../../finance/repositories/finance_repository.dart';

final walletDashboardProvider = FutureProvider.autoDispose<DashboardModel>((ref) {
  final repo = ref.watch(financeRepositoryProvider);
  return repo.getDashboard();
});

final walletTransactionsProvider = FutureProvider.autoDispose<List<WalletTransactionModel>>((ref) {
  final repo = ref.watch(financeRepositoryProvider);
  return repo.getTransactions(page: 1, limit: 30);
});

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(walletDashboardProvider);
    final transactionsAsync = ref.watch(walletTransactionsProvider);

    return Scaffold(
      backgroundColor: AppColors.pageTint,
      appBar: AppBar(
        title: const Text('Ví của bạn'),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref.invalidate(walletDashboardProvider);
          ref.invalidate(walletTransactionsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Balances Overview
              dashboardAsync.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
                error: (err, _) => AppCard(
                  child: Text('Lỗi: $err', style: const TextStyle(color: AppColors.statusDangerText)),
                ),
                data: (dashboard) {
                  return Column(
                    children: [
                      StatCard(
                        label: 'Số dư khả dụng có thể rút',
                        value: FormatUtils.formatVnd(dashboard.wallet.available),
                        backgroundColor: AppColors.softSurface.withValues(alpha: 0.6),
                        valueColor: AppColors.primary,
                        action: AppButton(
                          text: 'Yêu cầu rút tiền',
                          icon: const Icon(LucideIcons.arrowDownToLine, size: 16, color: Colors.white),
                          onPressed: () => context.push('/app/withdrawals/new'),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: StatCard(
                              label: 'Chờ xác nhận',
                              value: FormatUtils.formatVnd(dashboard.pendingCashback.toString()),
                              helper: 'Chưa vào ví',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: StatCard(
                              label: 'Đang giữ để rút',
                              value: FormatUtils.formatVnd(dashboard.wallet.reserved),
                              helper: 'Đang xử lý',
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),

              // Quick Action Shortcuts
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: 'Lịch sử hoàn tiền',
                      icon: const Icon(LucideIcons.coins, size: 16, color: AppColors.primary),
                      variant: AppButtonVariant.outline,
                      height: 44,
                      onPressed: () => context.push('/app/cashback'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppButton(
                      text: 'Lịch sử rút tiền',
                      icon: const Icon(LucideIcons.history, size: 16, color: AppColors.primary),
                      variant: AppButtonVariant.outline,
                      height: 44,
                      onPressed: () => context.push('/app/withdrawals'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Ledger Transactions List
              const Text(
                'LỊCH SỬ BIẾN ĐỘNG SỐ DƯ (LEDGER)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),

              transactionsAsync.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
                error: (err, _) => Center(
                  child: Text('Lỗi: $err', style: const TextStyle(color: AppColors.statusDangerText)),
                ),
                data: (transactions) {
                  if (transactions.isEmpty) {
                    return const EmptyStateWidget(
                      title: 'Chưa có biến động số dư',
                      description: 'Các giao dịch cộng cashback hoặc rút tiền sẽ được ghi nhận sổ cái tại đây.',
                      icon: LucideIcons.bookOpen,
                    );
                  }

                  return AppCard(
                    padding: EdgeInsets.zero,
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: transactions.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final tx = transactions[index];
                        final isCredit = tx.availableDelta != null && !tx.availableDelta!.startsWith('-');

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tx.type,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    FormatUtils.formatDateTime(tx.createdAt),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (tx.availableDelta != null)
                                    Text(
                                      isCredit
                                          ? '+${FormatUtils.formatVnd(tx.availableDelta)}'
                                          : FormatUtils.formatVnd(tx.availableDelta),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: isCredit
                                            ? AppColors.statusSuccessText
                                            : AppColors.statusDangerText,
                                      ),
                                    ),
                                  if (tx.availableAfter != null)
                                    Text(
                                      'Sau GD: ${FormatUtils.formatVnd(tx.availableAfter)}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_skeleton.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../finance/models/dashboard_model.dart';
import '../../finance/models/wallet_transaction_model.dart';
import '../../finance/repositories/finance_repository.dart';
import '../../finance/utils/merge_paged_rows.dart';
import '../../finance/utils/transaction_copy.dart';

final walletDashboardProvider = FutureProvider.autoDispose<DashboardModel>((
  ref,
) {
  final repo = ref.watch(financeRepositoryProvider);
  return repo.getDashboard();
});

const _walletPageSize = 30;

final walletTransactionsProvider = FutureProvider.autoDispose
    .family<List<WalletTransactionModel>, int>((ref, page) {
      final repo = ref.watch(financeRepositoryProvider);
      return repo.getTransactions(page: page, limit: _walletPageSize);
    });

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  int _page = 1;

  @override
  Widget build(BuildContext context) {
    final copy = TransactionCopy(
      isVietnamese: Localizations.localeOf(context).languageCode == 'vi',
    );
    final dashboardAsync = ref.watch(walletDashboardProvider);
    final pageResults = [
      for (var page = 1; page <= _page; page++)
        ref.watch(walletTransactionsProvider(page)),
    ];
    final transactionsAsync = pageResults.first;
    final transactions = mergePagedRows(
      pageResults
          .map((result) => result.asData?.value)
          .whereType<List<WalletTransactionModel>>(),
      (transaction) => transaction.id,
    );
    final lastPage = pageResults.last;
    final canLoadMore = lastPage.asData?.value.length == _walletPageSize;
    final loadingMore = _page > 1 && lastPage.isLoading;
    final loadMoreFailed = _page > 1 && lastPage.hasError;

    return Scaffold(
      backgroundColor: AppColors.pageTint,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          setState(() => _page = 1);
          ref.invalidate(walletDashboardProvider);
          ref.invalidate(walletTransactionsProvider(1));
          try {
            await Future.wait([
              ref.read(walletDashboardProvider.future),
              ref.read(walletTransactionsProvider(1).future),
            ]);
          } catch (_) {
            // The screen shows the localized error state.
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Page Heading matching Web 1:1
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          copy.text('Ví của bạn', 'Your wallet'),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          copy.text(
                            'Số dư và lịch sử giao dịch của bạn.',
                            'Your balance and transaction history.',
                          ),
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  AppButton(
                    text: copy.text('Yêu cầu rút', 'Withdraw'),
                    icon: const Icon(
                      LucideIcons.arrowDownToLine,
                      size: 14,
                      color: Colors.white,
                    ),
                    height: 38,
                    onPressed: () => context.push('/app/withdrawals/new'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Balances Overview
              dashboardAsync.when(
                loading: () => const AppSkeletonCard(
                  children: [
                    Row(
                      children: [
                        AppSkeletonBlock(height: 46, width: 46, radius: 13),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppSkeletonBlock(height: 12, width: 96),
                              SizedBox(height: 8),
                              AppSkeletonBlock(height: 26, width: 140),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 18),
                    AppSkeletonBlock(height: 13, width: 190),
                    SizedBox(height: 10),
                    AppSkeletonBlock(height: 13, width: 160),
                  ],
                ),
                error: (_, _) => AppCard(
                  child: Text(
                    copy.text(
                      'Không tải được số dư. Kéo xuống để thử lại.',
                      'Could not load your balance. Pull down to retry.',
                    ),
                    style: const TextStyle(color: AppColors.statusDangerText),
                  ),
                ),
                data: (dashboard) {
                  return AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: AppColors.softSurface,
                                borderRadius: BorderRadius.circular(13),
                              ),
                              child: const Icon(
                                LucideIcons.walletCards,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    copy.text(
                                      'Bạn có thể rút',
                                      'Available to withdraw',
                                    ),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    FormatUtils.formatVnd(
                                      dashboard.wallet.available,
                                    ),
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        const Divider(height: 1, color: Color(0xFFF5E7EB)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(
                              LucideIcons.clock3,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                copy.text('Chờ xác nhận', 'Pending cashback'),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            Text(
                              FormatUtils.formatVnd(
                                dashboard.pendingCashback.toString(),
                              ),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(
                              LucideIcons.lockKeyhole,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                copy.text(
                                  'Đang giữ để rút',
                                  'Held for withdrawal',
                                ),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            Text(
                              FormatUtils.formatVnd(dashboard.wallet.reserved),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Quick Action Shortcuts
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: AppButton(
                      text: copy.text('Lịch sử hoàn tiền', 'Cashback history'),
                      icon: const Icon(
                        LucideIcons.coins,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      variant: AppButtonVariant.outline,
                      height: 44,
                      onPressed: () => context.push('/app/cashback'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: AppButton(
                      text: copy.text('Lịch sử rút tiền', 'Withdrawal history'),
                      icon: const Icon(
                        LucideIcons.history,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      variant: AppButtonVariant.outline,
                      height: 44,
                      onPressed: () => context.push('/app/withdrawals'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Ledger Transactions List
              Text(
                copy.text('LỊCH SỬ GIAO DỊCH', 'TRANSACTION HISTORY'),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),

              transactionsAsync.when(
                loading: () =>
                    const AppListSkeleton(rows: 2, padding: EdgeInsets.zero),
                error: (_, _) => Center(
                  child: Text(
                    copy.text(
                      'Không tải được giao dịch. Kéo xuống để thử lại.',
                      'Could not load transactions. Pull down to retry.',
                    ),
                    style: const TextStyle(color: AppColors.statusDangerText),
                  ),
                ),
                data: (_) {
                  if (transactions.isEmpty) {
                    return EmptyStateWidget(
                      title: copy.text(
                        'Chưa có giao dịch',
                        'No transactions yet',
                      ),
                      description: copy.text(
                        'Tiền hoàn và các lần rút tiền sẽ xuất hiện tại đây.',
                        'Cashback and withdrawals will appear here.',
                      ),
                      icon: LucideIcons.bookOpen,
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppCard(
                        padding: EdgeInsets.zero,
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: transactions.length,
                          separatorBuilder: (_, _) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final tx = transactions[index];
                            final isCredit = copy.walletIsPositive(tx);
                            final contextLabel = copy.sourceContext(tx.source);
                            final icon = switch (tx.type) {
                              'CASHBACK_CREDIT' => LucideIcons.coins,
                              'CASHBACK_REVERSAL' => LucideIcons.rotateCcw,
                              'WITHDRAWAL_RESERVE' || 'WITHDRAWAL_COMPLETE' =>
                                LucideIcons.arrowDownToLine,
                              'WITHDRAWAL_RELEASE' => LucideIcons.undo2,
                              _ => LucideIcons.wallet,
                            };

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 12.0,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: AppColors.softSurface,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      icon,
                                      size: 18,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          copy.walletTitle(tx.type),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          FormatUtils.formatDateTime(
                                            tx.createdAt,
                                          ),
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                        if (contextLabel != null) ...[
                                          const SizedBox(height: 5),
                                          Text(
                                            contextLabel,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                        if (tx.availableAfter != null)
                                          Text(
                                            '${copy.text('Có thể rút sau giao dịch', 'Available after')}: ${FormatUtils.formatVnd(tx.availableAfter)}',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    copy.walletAmount(tx),
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: isCredit
                                          ? AppColors.primary
                                          : AppColors.statusDangerText,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      if (loadingMore)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      if (loadMoreFailed)
                        TextButton.icon(
                          onPressed: () =>
                              ref.invalidate(walletTransactionsProvider(_page)),
                          icon: const Icon(LucideIcons.refreshCw, size: 16),
                          label: Text(
                            copy.text(
                              'Không tải được thêm. Thử lại',
                              'Could not load more. Retry',
                            ),
                          ),
                        ),
                      if (canLoadMore)
                        TextButton.icon(
                          onPressed: () => setState(() => _page++),
                          icon: const Icon(LucideIcons.chevronDown, size: 16),
                          label: Text(
                            copy.text(
                              'Xem thêm giao dịch',
                              'Load more transactions',
                            ),
                          ),
                        ),
                    ],
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

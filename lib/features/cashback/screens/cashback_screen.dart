import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/status_badge.dart';
import '../../finance/models/cashback_model.dart';
import '../../finance/repositories/finance_repository.dart';
import '../../finance/utils/merge_paged_rows.dart';
import '../../finance/utils/transaction_copy.dart';

const _cashbackPageSize = 50;

final cashbacksListProvider = FutureProvider.autoDispose
    .family<List<CashbackModel>, ({String? status, int page})>((ref, query) {
      final repo = ref.watch(financeRepositoryProvider);
      return repo.getCashbacks(
        page: query.page,
        limit: _cashbackPageSize,
        status: query.status,
      );
    });

class CashbackScreen extends ConsumerStatefulWidget {
  const CashbackScreen({super.key});

  @override
  ConsumerState<CashbackScreen> createState() => _CashbackScreenState();
}

class _CashbackScreenState extends ConsumerState<CashbackScreen> {
  String? _selectedStatus;
  int _page = 1;

  static const List<String?> _statusTabs = [
    null,
    'PENDING',
    'VALIDATED',
    'AVAILABLE',
    'REJECTED',
    'REVERSED',
  ];

  @override
  Widget build(BuildContext context) {
    final copy = TransactionCopy(
      isVietnamese: Localizations.localeOf(context).languageCode == 'vi',
    );
    final pageResults = [
      for (var page = 1; page <= _page; page++)
        ref.watch(cashbacksListProvider((status: _selectedStatus, page: page))),
    ];
    final cashbacksAsync = pageResults.first;
    final cashbacks = mergePagedRows(
      pageResults
          .map((result) => result.asData?.value)
          .whereType<List<CashbackModel>>(),
      (cashback) => cashback.id,
    );
    final lastPage = pageResults.last;
    final canLoadMore = lastPage.asData?.value.length == _cashbackPageSize;
    final loadingMore = _page > 1 && lastPage.isLoading;
    final loadMoreFailed = _page > 1 && lastPage.hasError;
    final showFooter = canLoadMore || loadingMore || loadMoreFailed;

    return Scaffold(
      backgroundColor: AppColors.pageTint,
      appBar: AppBar(
        title: Text(copy.text('Lịch sử hoàn tiền', 'Cashback history')),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          setState(() => _page = 1);
          final firstPage = cashbacksListProvider((
            status: _selectedStatus,
            page: 1,
          ));
          ref.invalidate(firstPage);
          try {
            await ref.read(firstPage.future);
          } catch (_) {
            // The screen shows the localized error state.
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 6.0,
              ),
              child: Text(
                copy.text(
                  'Tiền hoàn sẽ có thể rút sau khi đơn hàng được xác nhận và thanh toán hoàn tất.',
                  'Cashback becomes available after your order is confirmed and payment is settled.',
                ),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ),
            // Status Tabs
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 4.0,
                ),
                itemCount: _statusTabs.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final tab = _statusTabs[index];
                  final isSelected = _selectedStatus == tab;

                  return ChoiceChip(
                    label: Text(
                      tab == null
                          ? copy.text('Tất cả', 'All')
                          : copy.cashbackStatus(tab),
                    ),
                    selected: isSelected,
                    selectedColor: AppColors.softSurface,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.borderSubtle,
                        width: 1,
                      ),
                    ),
                    showCheckmark: false,
                    onSelected: (_) {
                      setState(() {
                        _selectedStatus = tab;
                        _page = 1;
                      });
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 8),

            Expanded(
              child: cashbacksAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
                error: (_, _) => SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      copy.text(
                        'Không tải được tiền hoàn. Kéo xuống để thử lại.',
                        'Could not load cashback. Pull down to retry.',
                      ),
                      style: const TextStyle(color: AppColors.statusDangerText),
                    ),
                  ),
                ),
                data: (_) {
                  if (cashbacks.isEmpty) {
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: EmptyStateWidget(
                          title: copy.text(
                            'Chưa có khoản hoàn tiền',
                            'No cashback yet',
                          ),
                          description: copy.text(
                            'Tiền hoàn sẽ xuất hiện khi đơn hàng của bạn được ghi nhận.',
                            'Cashback will appear when your order is recorded.',
                          ),
                          icon: LucideIcons.coins,
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    itemCount: cashbacks.length + (showFooter ? 1 : 0),
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      if (index == cashbacks.length) {
                        if (loadingMore) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                            ),
                          );
                        }
                        return TextButton.icon(
                          onPressed: loadMoreFailed
                              ? () => ref.invalidate(
                                  cashbacksListProvider((
                                    status: _selectedStatus,
                                    page: _page,
                                  )),
                                )
                              : () => setState(() => _page++),
                          icon: Icon(
                            loadMoreFailed
                                ? LucideIcons.refreshCw
                                : LucideIcons.chevronDown,
                            size: 16,
                          ),
                          label: Text(
                            loadMoreFailed
                                ? copy.text(
                                    'Không tải được thêm. Thử lại',
                                    'Could not load more. Retry',
                                  )
                                : copy.text(
                                    'Xem thêm tiền hoàn',
                                    'Load more cashback',
                                  ),
                          ),
                        );
                      }
                      final item = cashbacks[index];
                      final contextLabel = copy.sourceContext(item.source);
                      return AppCard(
                        padding: const EdgeInsets.all(14.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  LucideIcons.coins,
                                  size: 18,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    copy.text(
                                      'Tiền hoàn từ đơn hàng',
                                      'Order cashback',
                                    ),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (contextLabel != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                contextLabel,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                            Text(
                              copy.cashbackAmountLabel(item.state),
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              '${copy.cashbackIsCancelled(item.state) ? '' : '+'}${FormatUtils.formatVnd(item.userAmount)}',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: copy.cashbackIsCancelled(item.state)
                                    ? AppColors.statusDangerText
                                    : AppColors.statusSuccessText,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                StatusBadge(
                                  status: item.state,
                                  domain: StatusDomain.cashback,
                                  labelOverride: copy.cashbackStatus(
                                    item.state,
                                  ),
                                ),
                                Text(
                                  FormatUtils.formatDateTime(item.createdAt),
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
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

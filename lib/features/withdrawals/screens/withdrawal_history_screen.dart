import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/status_badge.dart';
import '../../finance/models/withdrawal_model.dart';
import '../../finance/repositories/finance_repository.dart';

final withdrawalHistoryProvider = FutureProvider.autoDispose<List<WithdrawalModel>>((ref) {
  final repo = ref.watch(financeRepositoryProvider);
  return repo.getWithdrawals(page: 1, limit: 50);
});

class WithdrawalHistoryScreen extends ConsumerWidget {
  const WithdrawalHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final withdrawalsAsync = ref.watch(withdrawalHistoryProvider);

    return Scaffold(
      backgroundColor: AppColors.pageTint,
      appBar: AppBar(
        title: const Text('Lịch sử rút tiền'),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref.invalidate(withdrawalHistoryProvider);
        },
        child: withdrawalsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (err, _) => Center(
            child: Text('Lỗi: $err', style: const TextStyle(color: AppColors.statusDangerText)),
          ),
          data: (withdrawals) {
            if (withdrawals.isEmpty) {
              return const SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: EmptyStateWidget(
                    title: 'Chưa có yêu cầu rút tiền',
                    description: 'Khi bạn tạo yêu cầu rút tiền về tài khoản ngân hàng, thông tin xử lý sẽ hiển thị tại đây.',
                    icon: LucideIcons.history,
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: withdrawals.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = withdrawals[index];
                return AppCard(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            FormatUtils.formatVnd(item.amount),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          StatusBadge(status: item.status, domain: StatusDomain.withdrawal),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(LucideIcons.landmark, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 6),
                          Text(
                            '${item.bankName} (•••• ${item.lastFour})',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Thời gian tạo: ${FormatUtils.formatDateTime(item.createdAt)}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (item.reviewReason != null && item.reviewReason!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.statusDangerBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Lý do từ chối: ${item.reviewReason}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.statusDangerText,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

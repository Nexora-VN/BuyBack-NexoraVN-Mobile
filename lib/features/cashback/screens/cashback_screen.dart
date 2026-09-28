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

final cashbacksListProvider = FutureProvider.autoDispose.family<List<CashbackModel>, String?>((ref, status) {
  final repo = ref.watch(financeRepositoryProvider);
  return repo.getCashbacks(page: 1, limit: 50, status: status);
});

class CashbackScreen extends ConsumerStatefulWidget {
  const CashbackScreen({super.key});

  @override
  ConsumerState<CashbackScreen> createState() => _CashbackScreenState();
}

class _CashbackScreenState extends ConsumerState<CashbackScreen> {
  String? _selectedStatus;

  static const _statusTabs = [
    {'label': 'Tất cả', 'value': null},
    {'label': 'Đang chờ', 'value': 'PENDING'},
    {'label': 'Đã xác nhận', 'value': 'VALIDATED'},
    {'label': 'Khả dụng', 'value': 'AVAILABLE'},
    {'label': 'Từ chối / Thu hồi', 'value': 'REJECTED'},
  ];

  @override
  Widget build(BuildContext context) {
    final cashbacksAsync = ref.watch(cashbacksListProvider(_selectedStatus));

    return Scaffold(
      backgroundColor: AppColors.pageTint,
      appBar: AppBar(
        title: const Text('Cashback của bạn'),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref.invalidate(cashbacksListProvider(_selectedStatus));
        },
        child: Column(
          children: [
            // Status Tabs
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                itemCount: _statusTabs.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final tab = _statusTabs[index];
                  final isSelected = _selectedStatus == tab['value'];

                  return ChoiceChip(
                    label: Text(tab['label']!),
                    selected: isSelected,
                    selectedColor: AppColors.softSurface,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? AppColors.primary : AppColors.borderSubtle,
                        width: 1,
                      ),
                    ),
                    showCheckmark: false,
                    onSelected: (_) {
                      setState(() => _selectedStatus = tab['value']);
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
                error: (err, _) => Center(
                  child: Text('Lỗi: $err', style: const TextStyle(color: AppColors.statusDangerText)),
                ),
                data: (cashbacks) {
                  if (cashbacks.isEmpty) {
                    return const SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: EmptyStateWidget(
                          title: 'Chưa có khoản hoàn tiền',
                          description: 'Hoa hồng và cashback sẽ xuất hiện tại đây khi đơn hàng của bạn được ghi nhận.',
                          icon: LucideIcons.coins,
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    itemCount: cashbacks.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = cashbacks[index];
                      return AppCard(
                        padding: const EdgeInsets.all(14.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Mã hoa hồng: ${item.commissionId}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'monospace',
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '+${FormatUtils.formatVnd(item.userAmount)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.statusSuccessText,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Ghi nhận: ${FormatUtils.formatDateTime(item.createdAt)}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            StatusBadge(status: item.state, domain: StatusDomain.cashback),
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

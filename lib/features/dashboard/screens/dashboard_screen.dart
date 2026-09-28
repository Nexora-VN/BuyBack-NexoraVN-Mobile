import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/product_thumbnail.dart';
import '../../../core/widgets/stat_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../../affiliate/widgets/generate_link_panel.dart';
import '../../finance/models/dashboard_model.dart';
import '../../finance/models/order_model.dart';
import '../../finance/repositories/finance_repository.dart';

final dashboardFutureProvider = FutureProvider.autoDispose<DashboardModel>((ref) {
  final repo = ref.watch(financeRepositoryProvider);
  return repo.getDashboard();
});

final recentOrdersFutureProvider = FutureProvider.autoDispose<List<OrderModel>>((ref) {
  final repo = ref.watch(financeRepositoryProvider);
  return repo.getOrders(page: 1, limit: 3);
});

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardFutureProvider);
    final recentOrdersAsync = ref.watch(recentOrdersFutureProvider);

    return Scaffold(
      backgroundColor: AppColors.pageTint,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref.invalidate(dashboardFutureProvider);
          ref.invalidate(recentOrdersFutureProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Greeting Section
              const Text(
                'Mua sắm hoàn tiền cùng Piggy nào! 👋',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Dán link Shopee, TikTok để biết hoa hồng dự tính và nhận hoàn tiền khi mua sắm.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),

              // Quick Link Generator
              const GenerateLinkPanel(),
              const SizedBox(height: 18),

              // Wallet & Bento Overview
              dashboardAsync.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
                error: (err, _) => AppCard(
                  child: Text(
                    'Không thể tải dữ liệu ví: $err',
                    style: const TextStyle(color: AppColors.statusDangerText),
                  ),
                ),
                data: (dashboard) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Hero Card: Bạn có thể rút
                      StatCard(
                        label: 'Bạn có thể rút',
                        value: FormatUtils.formatVnd(dashboard.wallet.available),
                        backgroundColor: AppColors.softSurface.withValues(alpha: 0.5),
                        valueColor: AppColors.primary,
                        border: const BorderSide(
                          color: AppColors.borderSubtle,
                          width: 1.2,
                        ),
                        action: AppButton(
                          text: 'Rút tiền',
                          icon: const Icon(LucideIcons.arrowDownToLine, size: 16, color: AppColors.primary),
                          variant: AppButtonVariant.outline,
                          height: 42,
                          onPressed: () => context.push('/app/withdrawals/new'),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Two-column Bento Cards
                      Row(
                        children: [
                          Expanded(
                            child: StatCard(
                              label: 'Chờ xác nhận',
                              value: FormatUtils.formatVnd(dashboard.pendingCashback.toString()),
                              helper: 'Chưa tính vào số dư',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: StatCard(
                              label: 'Đang giữ cho rút',
                              value: FormatUtils.formatVnd(dashboard.wallet.reserved),
                              helper: 'Đang chờ xử lý',
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              // Recent Orders Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Đơn hàng gần đây',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/app/orders'),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(50, 30),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Xem tất cả',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              recentOrdersAsync.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
                error: (err, _) => AppCard(
                  child: Text(
                    'Không thể tải đơn hàng gần đây: $err',
                    style: const TextStyle(color: AppColors.statusDangerText),
                  ),
                ),
                data: (orders) {
                  if (orders.isEmpty) {
                    return AppCard(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      child: Center(
                        child: Text(
                          'Bạn chưa có đơn hàng nào. Hãy tạo link và mua sắm ngay nha!',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  return AppCard(
                    padding: EdgeInsets.zero,
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: orders.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        return InkWell(
                          onTap: () => context.push('/app/orders/${order.id}'),
                          borderRadius: index == 0
                              ? const BorderRadius.vertical(top: Radius.circular(16))
                              : index == orders.length - 1
                                  ? const BorderRadius.vertical(bottom: Radius.circular(16))
                                  : BorderRadius.zero,
                          child: Padding(
                            padding: const EdgeInsets.all(14.0),
                            child: Row(
                              children: [
                                ProductThumbnail(
                                  imageUrl: order.productImageUrl,
                                  name: order.productName,
                                  size: 52,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.orange.shade50,
                                              borderRadius: BorderRadius.circular(4),
                                              border: Border.all(
                                                color: Colors.orange.shade200,
                                                width: 0.5,
                                              ),
                                            ),
                                            child: Text(
                                              order.platform.toUpperCase(),
                                              style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.w800,
                                                color: Colors.orange.shade800,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              order.orderSn,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.textSecondary,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        order.productName,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Text(
                                            '${order.itemCount} sản phẩm',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                          if (order.cashbackAmount != null) ...[
                                            const SizedBox(width: 8),
                                            Text(
                                              '+${FormatUtils.formatVnd(order.cashbackAmount)}',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.statusSuccessText,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                StatusBadge(
                                  status: order.status,
                                  domain: StatusDomain.order,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

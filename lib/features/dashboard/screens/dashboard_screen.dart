import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_skeleton.dart';
import '../../../core/widgets/product_thumbnail.dart';
import '../../../core/widgets/status_badge.dart';
import '../../affiliate/widgets/generate_link_notes.dart';
import '../../affiliate/widgets/generate_link_panel.dart';
import '../../finance/models/dashboard_model.dart';
import '../../finance/models/order_model.dart';
import '../../finance/repositories/finance_repository.dart';
import '../../../l10n/generated/app_localizations.dart';

final dashboardFutureProvider = FutureProvider.autoDispose<DashboardModel>((
  ref,
) {
  final repo = ref.watch(financeRepositoryProvider);
  return repo.getDashboard();
});

final recentOrdersFutureProvider = FutureProvider.autoDispose<List<OrderModel>>(
  (ref) {
    final repo = ref.watch(financeRepositoryProvider);
    return repo.getOrders(page: 1, limit: 3);
  },
);

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final copy = AppLocalizations.of(context)!;
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
              Text(
                copy.homeTitle,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                copy.homeDescription,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),

              // Wallet & Bento Overview
              dashboardAsync.when(
                loading: () => const AppSkeletonCard(
                  children: [
                    Row(
                      children: [
                        AppSkeletonBlock(height: 48, width: 48, radius: 14),
                        SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppSkeletonBlock(height: 12, width: 100),
                              SizedBox(height: 8),
                              AppSkeletonBlock(height: 27, width: 144),
                            ],
                          ),
                        ),
                        AppSkeletonBlock(height: 42, width: 82),
                      ],
                    ),
                    SizedBox(height: 17),
                    Divider(height: 1, color: AppColors.borderSubtle),
                    SizedBox(height: 16),
                    AppSkeletonBlock(height: 14, width: 198),
                  ],
                ),
                error: (err, _) => AppCard(
                  child: const Text(
                    'Không thể tải số dư. Kéo xuống để thử lại.',
                    style: TextStyle(color: AppColors.statusDangerText),
                  ),
                ),
                data: (dashboard) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: AppColors.softSurface.withValues(
                                      alpha: .65,
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(
                                    LucideIcons.walletCards,
                                    color: AppColors.primary,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        copy.walletAvailable,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
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
                                AppButton(
                                  text: copy.withdraw,
                                  height: 42,
                                  onPressed: () =>
                                      context.push('/app/withdrawals/new'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Divider(height: 1, color: Color(0xFFF5E7EB)),
                            const SizedBox(height: 14),
                            InkWell(
                              onTap: () => context.go('/app/wallet'),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  minHeight: 44,
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      LucideIcons.clock3,
                                      size: 16,
                                      color: AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 7),
                                    Expanded(
                                      child: Text.rich(
                                        TextSpan(
                                          children: [
                                            TextSpan(
                                              text: '${copy.walletPending} ',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                            TextSpan(
                                              text: FormatUtils.formatVnd(
                                                dashboard.pendingCashback
                                                    .toString(),
                                              ),
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                          ],
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 36,
                                      height: 44,
                                      child: Center(
                                        child: Transform.translate(
                                          offset: const Offset(14, 0),
                                          child: const Icon(
                                            LucideIcons.chevronRight,
                                            size: 16,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (dashboard.wallet.reserved != '0') ...[
                              const SizedBox(height: 8),
                              Text(
                                '${copy.walletReserved}: ${FormatUtils.formatVnd(dashboard.wallet.reserved)}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 18),

              // Quick Link Generator
              const GenerateLinkPanel(),
              const SizedBox(height: 18),

              // Recent Orders Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    copy.recentOrders,
                    style: const TextStyle(
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
                    child: Text(
                      copy.viewAll,
                      style: const TextStyle(
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
                loading: () => const AppSkeletonCard(
                  children: [
                    Row(
                      children: [
                        AppSkeletonBlock(height: 54, width: 54, radius: 10),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppSkeletonBlock(height: 12),
                              SizedBox(height: 8),
                              AppSkeletonBlock(height: 12, width: 138),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                error: (err, _) => AppCard(
                  child: const Text(
                    'Không thể tải đơn hàng. Kéo xuống để thử lại.',
                    style: TextStyle(color: AppColors.statusDangerText),
                  ),
                ),
                data: (orders) {
                  if (orders.isEmpty) {
                    return AppCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 20,
                      ),
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
                              ? const BorderRadius.vertical(
                                  top: Radius.circular(16),
                                )
                              : index == orders.length - 1
                              ? const BorderRadius.vertical(
                                  bottom: Radius.circular(16),
                                )
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                              borderRadius:
                                                  BorderRadius.circular(4),
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
                                        maxLines: 2,
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
                                                color: AppColors.primary,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 7),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: StatusBadge(
                                          status: order.status,
                                          domain: StatusDomain.order,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  LucideIcons.chevronRight,
                                  size: 16,
                                  color: AppColors.textSecondary,
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
              const SizedBox(height: 16),
              const GenerateLinkNotes(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

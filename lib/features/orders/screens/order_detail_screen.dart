import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/cashback_progress_stepper.dart';
import '../../../core/widgets/product_thumbnail.dart';
import '../../../core/widgets/status_badge.dart';
import '../../finance/models/order_model.dart';
import '../../finance/repositories/finance_repository.dart';

final orderDetailFutureProvider = FutureProvider.autoDispose.family<OrderModel, String>((ref, id) {
  final repo = ref.watch(financeRepositoryProvider);
  return repo.getOrderDetail(id);
});

class OrderDetailScreen extends ConsumerWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  Future<void> _copyText(BuildContext context, String text, String message) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderDetailFutureProvider(orderId));

    return Scaffold(
      backgroundColor: AppColors.pageTint,
      appBar: AppBar(
        title: const Text('Chi tiết đơn hàng'),
      ),
      body: orderAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              'Lỗi tải chi tiết đơn hàng: $err',
              style: const TextStyle(color: AppColors.statusDangerText),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (order) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Order SN & Platform Header Card
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.orange.shade200, width: 0.5),
                            ),
                            child: Text(
                              order.platform.toUpperCase(),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Colors.orange.shade800,
                              ),
                            ),
                          ),
                          StatusBadge(status: order.status, domain: StatusDomain.order),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Mã đơn: ${order.orderSn}',
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () => _copyText(context, order.orderSn, 'Đã sao chép mã đơn hàng'),
                            borderRadius: BorderRadius.circular(6),
                            child: const Padding(
                              padding: EdgeInsets.all(6.0),
                              child: Icon(LucideIcons.copy, size: 16, color: AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                      if (order.purchasedAt != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Thời gian đặt hàng: ${FormatUtils.formatDateTime(order.purchasedAt)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Cashback Stepper Progress
                CashbackProgressStepper(
                  orderStatus: order.status,
                  commissionState: order.commissionState,
                  cashbackState: order.cashbackState,
                  purchasedAt: order.purchasedAt,
                ),
                const SizedBox(height: 14),

                // Financial Breakdown Card
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'THÔNG TIN TÀI CHÍNH',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _buildRow('Tổng giá trị đơn hàng', FormatUtils.formatVnd(order.totalAmountVnd)),
                      const Divider(height: 18),
                      _buildRow('Trạng thái hoa hồng', order.commissionState, isBadge: true, domain: StatusDomain.commission),
                      const Divider(height: 18),
                      _buildRow(
                        'Cashback nhận về (85%)',
                        FormatUtils.formatVnd(order.cashbackAmount),
                        isHighlight: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Items in Order
                if (order.items.isNotEmpty) ...[
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SẢN PHẨM TRONG ĐƠN (${order.items.length})',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: order.items.length,
                          separatorBuilder: (_, _) => const Divider(height: 18),
                          itemBuilder: (context, index) {
                            final item = order.items[index];
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ProductThumbnail(
                                  imageUrl: item.imageUrl,
                                  name: item.name,
                                  size: 52,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name ?? 'Sản phẩm Shopee',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (item.variation != null) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          'Phân loại: ${item.variation}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Số lượng: x${item.quantity}',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                          Text(
                                            FormatUtils.formatVnd(item.priceVnd),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRow(
    String label,
    String value, {
    bool isHighlight = false,
    bool isBadge = false,
    StatusDomain domain = StatusDomain.general,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        if (isBadge)
          StatusBadge(status: value, domain: domain)
        else
          Text(
            value,
            style: TextStyle(
              fontSize: isHighlight ? 15 : 13,
              fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w600,
              color: isHighlight ? AppColors.statusSuccessText : AppColors.textPrimary,
            ),
          ),
      ],
    );
  }
}

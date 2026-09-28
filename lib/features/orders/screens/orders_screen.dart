import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/product_thumbnail.dart';
import '../../../core/widgets/status_badge.dart';
import '../../finance/models/order_model.dart';
import '../../finance/repositories/finance_repository.dart';

final ordersListProvider = FutureProvider.autoDispose.family<List<OrderModel>, ({String? status, String? query})>((ref, filter) {
  final repo = ref.watch(financeRepositoryProvider);
  return repo.getOrders(
    page: 1,
    limit: 50,
    status: filter.status,
    query: filter.query,
  );
});

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  final _searchController = TextEditingController();
  String? _selectedStatus;
  String? _searchQuery;

  static const _statusOptions = [
    {'label': 'Tất cả', 'value': null},
    {'label': 'Hoàn thành', 'value': 'VALIDATED'},
    {'label': 'Đang xử lý', 'value': 'PENDING'},
    {'label': 'Cần đối chiếu', 'value': 'MANUAL_REVIEW'},
    {'label': 'Đã hủy', 'value': 'REJECTED'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filter = (status: _selectedStatus, query: _searchQuery);
    final ordersAsync = ref.watch(ordersListProvider(filter));

    return Scaffold(
      backgroundColor: AppColors.pageTint,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref.invalidate(ordersListProvider(filter));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Page Heading matching Web 1:1
            const Padding(
              padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Đơn hàng của bạn',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.4,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Các đơn hàng của bạn mua qua Piggy sẽ được hiển thị dưới đây nè.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            // Search Input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: AppTextField(
                controller: _searchController,
                hintText: 'Tìm kiếm mã đơn Shopee, TikTok...',
                prefixIcon: const Icon(LucideIcons.search, size: 18, color: AppColors.textSecondary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(LucideIcons.xCircle, size: 16, color: AppColors.textDisabled),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = null);
                        },
                      )
                    : null,
                onSubmitted: (val) => setState(() => _searchQuery = val.trim().isEmpty ? null : val.trim()),
              ),
            ),

            // Horizontal Status Filter Chips
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: _statusOptions.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final option = _statusOptions[index];
                  final isSelected = _selectedStatus == option['value'];

                  return ChoiceChip(
                    label: Text(option['label']!),
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
                      setState(() => _selectedStatus = option['value']);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 10),

            // Orders List
            Expanded(
              child: ordersAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
                error: (err, _) => Center(
                  child: Text('Lỗi tải đơn hàng: $err', style: const TextStyle(color: AppColors.statusDangerText)),
                ),
                data: (orders) {
                  if (orders.isEmpty) {
                    return const SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: EmptyStateWidget(
                          title: 'Không có đơn hàng',
                          description: 'Các đơn hàng mua qua link của bạn sẽ tự động xuất hiện tại đây sau khi hoàn tất.',
                          icon: LucideIcons.shoppingBag,
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    itemCount: orders.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return AppCard(
                        padding: const EdgeInsets.all(14.0),
                        onTap: () => context.push('/app/orders/${order.id}'),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade50,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: Colors.orange.shade200, width: 0.5),
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
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    order.orderSn,
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                StatusBadge(status: order.status, domain: StatusDomain.order),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ProductThumbnail(
                                  imageUrl: order.productImageUrl,
                                  name: order.productName,
                                  size: 60,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        order.productName,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Giá mua: ${FormatUtils.formatVnd(order.totalAmountVnd)}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                          if (order.cashbackAmount != null)
                                            Text(
                                              '+${FormatUtils.formatVnd(order.cashbackAmount)}',
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w800,
                                                color: AppColors.statusSuccessText,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
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

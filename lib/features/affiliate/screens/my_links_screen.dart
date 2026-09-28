import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../repositories/affiliate_repository.dart';

final myLinksFutureProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  final repo = ref.watch(affiliateRepositoryProvider);
  return repo.getMyLinks();
});

class MyLinksScreen extends ConsumerStatefulWidget {
  const MyLinksScreen({super.key});

  @override
  ConsumerState<MyLinksScreen> createState() => _MyLinksScreenState();
}

class _MyLinksScreenState extends ConsumerState<MyLinksScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _copyLink(String link) async {
    await Clipboard.setData(ClipboardData(text: link));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã sao chép link vào bộ nhớ tạm'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final linksAsync = ref.watch(myLinksFutureProvider);

    return Scaffold(
      backgroundColor: AppColors.pageTint,
      appBar: AppBar(
        title: const Text('Link của tôi'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: TextButton.icon(
              onPressed: () => context.push('/app/links/new'),
              icon: const Icon(LucideIcons.plus, size: 16, color: AppColors.primary),
              label: const Text(
                'Tạo link mới',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref.invalidate(myLinksFutureProvider);
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: AppTextField(
                controller: _searchController,
                hintText: 'Tìm kiếm link theo tên sản phẩm...',
                prefixIcon: const Icon(LucideIcons.search, size: 18, color: AppColors.textSecondary),
                onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
              ),
            ),
            Expanded(
              child: linksAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
                error: (err, _) => Center(
                  child: Text('Lỗi: $err', style: const TextStyle(color: AppColors.statusDangerText)),
                ),
                data: (links) {
                  final filtered = links.where((item) {
                    if (_searchQuery.isEmpty) return true;
                    final name = item['product']?['productName']?.toString().toLowerCase() ?? '';
                    final url = item['originUrl']?.toString().toLowerCase() ?? '';
                    return name.contains(_searchQuery) || url.contains(_searchQuery);
                  }).toList();

                  if (filtered.isEmpty) {
                    return const SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: EmptyStateWidget(
                          title: 'Chưa có link nào',
                          description: 'Các link bạn tạo sẽ hiển thị tại đây để bạn tiện theo dõi và chia sẻ.',
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      final product = item['product'] as Map<String, dynamic>?;
                      final productName = product?['productName']?.toString() ?? 'Sản phẩm Shopee';
                      final imageUrl = product?['imageUrl']?.toString();
                      final shortUrl = item['shortUrl']?.toString() ?? item['affiliateUrl']?.toString() ?? '';
                      final status = item['status']?.toString() ?? 'WORKING';
                      final createdAt = item['createdAt']?.toString();

                      return AppCard(
                        padding: const EdgeInsets.all(14.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ProductThumbnail(imageUrl: imageUrl, name: productName, size: 56),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        productName,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      if (createdAt != null)
                                        Text(
                                          'Tạo ngày: ${FormatUtils.formatDate(createdAt)}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                StatusBadge(status: status, domain: StatusDomain.affiliate),
                              ],
                            ),
                            if (shortUrl.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.pageTint,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.borderSubtle, width: 1),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        shortUrl,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                          fontFamily: 'monospace',
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    InkWell(
                                      onTap: () => _copyLink(shortUrl),
                                      borderRadius: BorderRadius.circular(6),
                                      child: const Padding(
                                        padding: EdgeInsets.all(4.0),
                                        child: Icon(
                                          LucideIcons.copy,
                                          size: 16,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                  ],
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
          ],
        ),
      ),
    );
  }
}

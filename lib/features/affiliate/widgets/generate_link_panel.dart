import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/format_utils.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_feedback.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/product_thumbnail.dart';
import '../models/generate_link_model.dart';
import '../repositories/affiliate_repository.dart';
import '../../../l10n/generated/app_localizations.dart';

class GenerateLinkPanel extends ConsumerStatefulWidget {
  const GenerateLinkPanel({super.key});

  @override
  ConsumerState<GenerateLinkPanel> createState() => _GenerateLinkPanelState();
}

class _GenerateLinkPanelState extends ConsumerState<GenerateLinkPanel> {
  final _urlController = TextEditingController();
  bool _isLoading = false;
  String? _formError;
  String? _apiError;
  GenerateLinkResponse? _result;

  static const _shopeeHosts = [
    'shopee.vn',
    's.shopee.vn',
    'vn.shp.ee',
    'shp.ee',
    'shope.ee',
    'www.shopee.vn',
  ];

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _handlePaste() async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      if (!mounted) return;
      final text = data?.text?.trim();
      if (text == null || text.isEmpty) {
        AppFeedback.failure('Bộ nhớ tạm đang trống');
        return;
      }
      _urlController.text = text;
      setState(() {
        _formError = null;
        _apiError = null;
      });
      AppFeedback.success('Đã dán từ clipboard');
    } catch (error) {
      AppFeedback.error(error, fallback: 'Không thể truy cập bộ nhớ tạm');
    }
  }

  void _handleClear() {
    _urlController.clear();
    setState(() {
      _result = null;
      _formError = null;
      _apiError = null;
    });
  }

  bool _validate(String input) {
    if (input.isEmpty) {
      setState(() => _formError = 'Vui lòng nhập link sản phẩm');
      return false;
    }

    try {
      final uri = Uri.parse(input);
      if (uri.scheme != 'https' || uri.userInfo.isNotEmpty || uri.hasPort) {
        setState(() => _formError = 'Link không hợp lệ');
        return false;
      }

      final host = uri.host.toLowerCase();
      final isShopee = _shopeeHosts.contains(host);
      if (!isShopee) {
        setState(() => _formError = AppLocalizations.of(context)!.shopeeOnly);
        return false;
      }
    } catch (_) {
      setState(() => _formError = 'Link không đúng định dạng');
      return false;
    }

    setState(() => _formError = null);
    return true;
  }

  Future<void> _generate() async {
    if (_isLoading) return;
    final input = _urlController.text.trim();
    if (!_validate(input)) return;

    setState(() {
      _isLoading = true;
      _apiError = null;
      _result = null;
    });

    try {
      final response = await ref
          .read(affiliateRepositoryProvider)
          .generate(input);
      if (!mounted) return;
      setState(() {
        _result = response;
        _isLoading = false;
      });
      AppFeedback.success(AppLocalizations.of(context)!.linkSuccess);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _apiError = AppFeedback.messageFor(
          e,
          fallback: 'Tạo link thất bại. Vui lòng thử lại.',
        );
        _isLoading = false;
      });
    }
  }

  Future<void> _copyLink(String link) async {
    try {
      await Clipboard.setData(ClipboardData(text: link));
      AppFeedback.success('Đã sao chép link chia sẻ');
    } catch (error) {
      AppFeedback.error(
        error,
        fallback: 'Không thể sao chép link. Vui lòng thử lại.',
      );
    }
  }

  Future<void> _openLink(String link) async {
    final uri = Uri.tryParse(link);
    if (uri == null) {
      AppFeedback.failure('Đường dẫn mua hàng không hợp lệ');
      return;
    }

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        AppFeedback.failure('Không thể mở liên kết mua sắm');
      }
    } catch (e) {
      AppFeedback.error(e, fallback: 'Không thể mở liên kết mua sắm');
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = _result?.product;
    final copy = AppLocalizations.of(context)!;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.softSurface,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  LucideIcons.link2,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      copy.linkCardTitle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      copy.linkCardHint,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Guide link button (mimicking Web)
          Align(
            alignment: Alignment.centerLeft,
            child: InkWell(
              onTap: () => _showGuideSliderSheet(context),
              borderRadius: BorderRadius.circular(6),
              child: const Padding(
                padding: EdgeInsets.only(bottom: 8, top: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      LucideIcons.helpCircle,
                      size: 15,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'Cách lấy link?',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Input field
          AppTextField(
            controller: _urlController,
            prefixIcon: const Icon(
              LucideIcons.link2,
              size: 18,
              color: AppColors.textSecondary,
            ),
            hintText: copy.linkPlaceholder,
            keyboardType: TextInputType.url,
            errorText: _formError,
            onSubmitted: (_) => _generate(),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_urlController.text.isNotEmpty)
                  IconButton(
                    tooltip: copy.clearLink,
                    icon: const Icon(
                      LucideIcons.xCircle,
                      size: 18,
                      color: AppColors.textDisabled,
                    ),
                    onPressed: _handleClear,
                  ),
                Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: Semantics(
                    label: copy.pasteLink,
                    button: true,
                    child: InkWell(
                      onTap: _handlePaste,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 40),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.softSurface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              LucideIcons.clipboardPaste,
                              size: 14,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Dán',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Submit CTA Button
          AppButton(
            text: _isLoading
                ? copy.creatingCashbackLink
                : copy.createCashbackLink,
            icon: const Icon(LucideIcons.link, size: 18, color: Colors.white),
            isLoading: _isLoading,
            onPressed: _generate,
          ),

          // Error display
          if (_apiError != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.statusDangerBg,
                borderRadius: AppDimensions.roundedControl,
              ),
              child: Text(
                _apiError!,
                style: const TextStyle(
                  color: AppColors.statusDangerText,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],

          // Result Card Preview (Matching FE generate-link-result.tsx)
          if (_result?.link != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.statusSuccessBg,
                borderRadius: AppDimensions.roundedCard,
                border: Border.all(
                  color: AppColors.statusSuccessText.withValues(alpha: 0.25),
                  width: 1.0,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Row(
                    children: [
                      Icon(
                        LucideIcons.checkCircle2,
                        size: 18,
                        color: AppColors.statusSuccessText,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Piggy mang tới tin tốt cho bạn',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.statusSuccessText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Product info
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ProductThumbnail(
                        imageUrl: product?.imageUrl,
                        name: product?.productName,
                        size: 72,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product?.productName ?? 'Sản phẩm mua sắm',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (product?.shopName != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                product!.shopName!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            const SizedBox(height: 4),
                            Text(
                              FormatUtils.formatVnd(product?.price),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Estimated Cashback banner
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          copy.estimatedCashback,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _result?.estimatedUserCashbackVnd == null && product?.commission == null
                              ? copy.estimateUnavailable
                              : FormatUtils.formatVnd(
                                  _result?.estimatedUserCashbackVnd ?? product?.commission,
                                ),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () => _showPriceExplainerSheet(context, product),
                          borderRadius: BorderRadius.circular(6),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                Text(
                                  'Shopee hoàn: ${_formatRate(_getShopeeRatePercent(product))} • Shopee Extra hoàn: ${_formatRate(_getSellerRatePercent(product))}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  LucideIcons.helpCircle,
                                  size: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          copy.estimateNote,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Actions matching Web 1:1
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppButton(
                        text: 'Mua ngay',
                        icon: const Icon(
                          LucideIcons.externalLink,
                          size: 16,
                          color: Colors.white,
                        ),
                        onPressed: () => _openLink(_result!.link!),
                      ),
                      const SizedBox(height: 10),
                      AppButton(
                        text: 'Copy link chia sẻ cho bạn bè',
                        icon: const Icon(
                          LucideIcons.copy,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        variant: AppButtonVariant.outline,
                        onPressed: () => _copyLink(_result!.link!),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatRate(dynamic rate) {
    if (rate == null) return '0%';
    final num? val = num.tryParse(rate.toString());
    if (val == null) return '0%';
    final clean = val % 1 == 0 ? val.toInt().toString() : val.toString();
    return '$clean%';
  }

  num _getShopeeRatePercent(ProductPreview? product) {
    if (product?.shopeeRatePercent != null) {
      final num? val = num.tryParse(product!.shopeeRatePercent.toString());
      if (val != null) return val;
    }
    if (product?.shopeeRate != null) {
      final num? r = num.tryParse(product!.shopeeRate.toString());
      if (r != null) return r * 100;
    }
    return 0;
  }

  num _getSellerRatePercent(ProductPreview? product) {
    if (product?.sellerRatePercent != null) {
      final num? val = num.tryParse(product!.sellerRatePercent.toString());
      if (val != null) return val;
    }
    if (product?.sellerRate != null) {
      final num? r = num.tryParse(product!.sellerRate.toString());
      if (r != null) return r * 100;
    }
    return 0;
  }

  void _showPriceExplainerSheet(BuildContext context, ProductPreview? product) {
    final shopeeRate = _formatRate(_getShopeeRatePercent(product));
    final sellerRate = _formatRate(_getSellerRatePercent(product));
    final totalRate = _formatRate(_getShopeeRatePercent(product) + _getSellerRatePercent(product));
    final cashback = FormatUtils.formatVnd(
      _result?.estimatedUserCashbackVnd ?? product?.commission,
    );

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Giải thích các loại giá & hoàn tiền',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.x, size: 20),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (product != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'THÔNG SỐ ĐƠN HÀNG NÀY',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _infoCell('Giá niêm yết', FormatUtils.formatVnd(product.price)),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _infoCell('Tổng hoàn sàn', totalRate),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _infoCell('Shopee hoàn', shopeeRate),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _infoCell('Shopee Extra', sellerRate),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _infoCell('Bạn nhận ước tính', cashback, isPrimary: true),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            _explainerItem(
              icon: LucideIcons.tag,
              title: '1. Giá sản phẩm (Giá niêm yết)',
              content:
                  'Là giá bán trên Shopee lúc tạo link. Tiền hoàn thực tế sẽ tính trên số tiền bạn thực thanh toán (sau khi áp mã giảm giá, voucher, xu và không tính phí vận chuyển).',
            ),
            _explainerItem(
              icon: LucideIcons.store,
              title: '2. Shopee hoàn (%)',
              content:
                  'Là tỷ lệ hoàn tiền cơ bản do sàn Shopee chi trả cố định theo từng ngành hàng. Mọi đơn hàng hợp lệ qua link đều được nhận mức hoàn này.',
            ),
            _explainerItem(
              icon: LucideIcons.sparkles,
              title: '3. Shopee Extra hoàn (%)',
              content:
                  'Là tỷ lệ hoàn tiền thưởng thêm do chính Người bán (Shop) tài trợ khi tham gia chương trình Shopee Extra. Sản phẩm có nhãn Extra sẽ có mức hoàn cao vượt trội.',
            ),
            _explainerItem(
              icon: LucideIcons.coins,
              title: '4. Tiền hoàn ước tính (Cashback nhận về)',
              content:
                  'Là số tiền Piggy chia sẻ và hoàn lại vào tài khoản của bạn. Sau khi đơn giao thành công và hoàn tất đối soát định kỳ của sàn (thường 15–30 ngày), tiền sẽ vào Ví để bạn rút về tài khoản ngân hàng.',
            ),
            _explainerItem(
              icon: LucideIcons.clock,
              title: '5. Thời gian đối soát',
              content:
                  'Sau khi đặt hàng, đơn sẽ ở trạng thái “Chờ đối soát”. Khi đơn giao thành công và hoàn tất kỳ đối soát định kỳ của sàn, tiền sẽ vào Ví để bạn rút về tài khoản ngân hàng.',
            ),
            const SizedBox(height: 16),
            AppButton(
              text: 'Đã hiểu',
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCell(String label, String value, {bool isPrimary = false}) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isPrimary ? AppColors.softSurface : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isPrimary ? AppColors.primaryContainer : AppColors.borderSubtle,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isPrimary ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isPrimary ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _explainerItem({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.softSurface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showGuideSliderSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => const _GuideSliderBottomSheet(),
    );
  }
}

class _GuideSliderBottomSheet extends StatefulWidget {
  const _GuideSliderBottomSheet();

  @override
  State<_GuideSliderBottomSheet> createState() => _GuideSliderBottomSheetState();
}

class _GuideSliderBottomSheetState extends State<_GuideSliderBottomSheet> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const _slides = [
    (
      step: 'Bước 1-2',
      title: 'Xóa giỏ hàng & Lấy link Shopee',
      image: 'assets/images/guide/1.png',
      desc:
          '1. Vào giỏ hàng Shopee xóa sản phẩm cần mua.\n2. Vào lại trang sản phẩm, bấm nút “Chia sẻ” (mũi tên cong) và chọn “Sao chép đường dẫn”.',
    ),
    (
      step: 'Bước 3-4',
      title: 'Dán link vào Piggy & Bấm Mua ngay',
      image: 'assets/images/guide/2.png',
      desc:
          '3. Mở Piggy Back, dán liên kết vừa sao chép vào ô dán link rồi bấm “Tạo link hoàn tiền”.\n4. Xem tiền hoàn ước tính rồi bấm “Mua ngay”.',
    ),
    (
      step: 'Bước 5-6',
      title: 'Chuyển sang Shopee & Đặt hàng',
      image: 'assets/images/guide/3.png',
      desc:
          '5. Piggy tự động chuyển bạn sang Shopee, bấm “Mua ngay” hoặc thêm vào giỏ.\n6. Áp dụng các voucher giảm giá và bấm “Đặt hàng”.',
    ),
    (
      step: 'Tổng kết',
      title: 'Quy trình trọn gói & Lưu ý',
      image: 'assets/images/guide/4.png',
      desc:
          'Tóm tắt toàn bộ quy trình mua sắm hoàn tiền. Luôn xóa sản phẩm khỏi giỏ trước khi tạo link để đảm bảo nhận trọn vẹn tiền hoàn.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) => Column(
        children: [
          const SizedBox(height: 10),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Hướng dẫn lấy link & mua sắm',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.x, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: List.generate(_slides.length, (index) {
                final isActive = index == _currentPage;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: InkWell(
                      onTap: () {
                        _pageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.primary : AppColors.softSurface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            _slides[index].step,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                              color: isActive ? Colors.white : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _slides.length,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder: (context, index) {
                final slide = _slides[index];
                return SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        slide.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        slide.desc,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          slide.image,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                if (_currentPage > 0)
                  Expanded(
                    child: AppButton(
                      text: 'Trước',
                      variant: AppButtonVariant.outline,
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                  )
                else
                  const Spacer(),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    text: _currentPage == _slides.length - 1 ? 'Đã hiểu' : 'Tiếp theo',
                    onPressed: () {
                      if (_currentPage < _slides.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        Navigator.pop(context);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

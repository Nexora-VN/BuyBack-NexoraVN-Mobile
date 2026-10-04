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
                          _result?.estimatedUserCashbackVnd == null
                              ? copy.estimateUnavailable
                              : FormatUtils.formatVnd(
                                  _result!.estimatedUserCashbackVnd,
                                ),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
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
}

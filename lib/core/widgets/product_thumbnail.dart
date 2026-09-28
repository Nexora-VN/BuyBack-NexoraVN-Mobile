import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../utils/format_utils.dart';

class ProductThumbnail extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final double size;
  final double borderRadius;

  const ProductThumbnail({
    super.key,
    this.imageUrl,
    this.name,
    this.size = 56.0,
    this.borderRadius = 10.0,
  });

  @override
  Widget build(BuildContext context) {
    final cleanUrl = FormatUtils.normalizeImageUrl(imageUrl);
    final validUrl = cleanUrl != null &&
        cleanUrl.isNotEmpty &&
        (cleanUrl.startsWith('http://') || cleanUrl.startsWith('https://'));

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: AppColors.borderSubtle, width: 1.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: validUrl
          ? CachedNetworkImage(
              imageUrl: cleanUrl,
              httpHeaders: const {
                'User-Agent':
                    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
                'Referer': 'https://shopee.vn/',
              },
              fit: BoxFit.cover,
              // Downsample image in RAM to prevent memory spikes & scrolling jank
              memCacheWidth: (size * 2).toInt(),
              memCacheHeight: (size * 2).toInt(),
              placeholder: (context, url) => Container(
                color: AppColors.pageTint,
                child: const Center(
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                ),
              ),
              errorWidget: (context, url, error) => _buildFallback(),
            )
          : _buildFallback(),
    );
  }

  Widget _buildFallback() {
    return Container(
      color: AppColors.pageTint,
      child: const Center(
        child: Icon(
          LucideIcons.imageOff,
          size: 20,
          color: AppColors.textDisabled,
        ),
      ),
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../constants/app_colors.dart';

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
    final validUrl = imageUrl != null &&
        imageUrl!.trim().isNotEmpty &&
        (imageUrl!.startsWith('http://') || imageUrl!.startsWith('https://'));

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
              imageUrl: imageUrl!.trim(),
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

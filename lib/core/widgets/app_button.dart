import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

enum AppButtonVariant { primary, secondary, outline, text }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? icon;
  final AppButtonVariant variant;
  final double? width;
  final double height;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.variant = AppButtonVariant.primary,
    this.width,
    this.height = 48.0,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    BorderSide borderSide = BorderSide.none;

    switch (variant) {
      case AppButtonVariant.primary:
        backgroundColor = AppColors.primary;
        textColor = Colors.white;
        break;
      case AppButtonVariant.secondary:
        backgroundColor = AppColors.softSurface;
        textColor = AppColors.primary;
        break;
      case AppButtonVariant.outline:
        backgroundColor = Colors.white;
        textColor = AppColors.primary;
        borderSide = const BorderSide(color: AppColors.borderSubtle, width: 1.5);
        break;
      case AppButtonVariant.text:
        backgroundColor = Colors.transparent;
        textColor = AppColors.primary;
        break;
    }

    final isInteractive = onPressed != null && !isLoading;

    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: isInteractive ? backgroundColor : backgroundColor.withValues(alpha: 0.5),
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.roundedControl,
          side: borderSide,
        ),
        child: InkWell(
          onTap: isInteractive ? onPressed : null,
          borderRadius: AppDimensions.roundedControl,
          splashColor: variant == AppButtonVariant.primary
              ? AppColors.brandPressed.withValues(alpha: 0.3)
              : AppColors.primary.withValues(alpha: 0.1),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisSize: width == null ? MainAxisSize.min : MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading) ...[
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation<Color>(textColor),
                    ),
                  ),
                  const SizedBox(width: 8),
                ] else if (icon != null) ...[
                  icon!,
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    text,
                    style: TextStyle(
                      color: isInteractive ? textColor : textColor.withValues(alpha: 0.6),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

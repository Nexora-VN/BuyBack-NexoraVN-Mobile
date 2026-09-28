import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final BorderSide? border;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.onTap,
    this.backgroundColor,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final cardContent = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surfaceContainerLowest,
        borderRadius: AppDimensions.roundedCard,
        border: Border.fromBorderSide(
          border ?? const BorderSide(color: AppColors.borderSubtle, width: 1.0),
        ),
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        borderRadius: AppDimensions.roundedCard,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppDimensions.roundedCard,
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }
}

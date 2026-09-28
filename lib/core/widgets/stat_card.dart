import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'app_card.dart';

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? helper;
  final Widget? icon;
  final Widget? action;
  final Color? backgroundColor;
  final Color? valueColor;
  final BorderSide? border;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.helper,
    this.icon,
    this.action,
    this.backgroundColor,
    this.valueColor,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      backgroundColor: backgroundColor,
      border: border,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                icon!,
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: valueColor ?? AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          if (helper != null) ...[
            const SizedBox(height: 4),
            Text(
              helper!,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          if (action != null) ...[
            const SizedBox(height: 12),
            action!,
          ],
        ],
      ),
    );
  }
}

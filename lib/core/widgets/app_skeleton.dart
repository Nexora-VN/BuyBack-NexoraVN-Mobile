import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import 'app_card.dart';

/// Static placeholders avoid movement for users who prefer reduced motion.
class AppSkeletonBlock extends StatelessWidget {
  final double height;
  final double? width;
  final double radius;

  const AppSkeletonBlock({
    super.key,
    required this.height,
    this.width,
    this.radius = 9,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: AppColors.softSurface.withValues(alpha: .82),
      borderRadius: BorderRadius.circular(radius),
    ),
  );
}

class AppSkeletonCard extends StatelessWidget {
  final List<Widget> children;

  const AppSkeletonCard({super.key, required this.children});

  @override
  Widget build(BuildContext context) => AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    ),
  );
}

class AppListSkeleton extends StatelessWidget {
  final int rows;
  final EdgeInsetsGeometry padding;

  const AppListSkeleton({
    super.key,
    this.rows = 3,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Đang tải danh sách',
    liveRegion: true,
    child: ExcludeSemantics(
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: List.generate(
            rows,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppSkeletonCard(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppSkeletonBlock(height: 21, width: 70),
                      AppSkeletonBlock(height: 21, width: 94),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Row(
                    children: [
                      AppSkeletonBlock(height: 52, width: 52, radius: 10),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppSkeletonBlock(height: 13),
                            SizedBox(height: 9),
                            AppSkeletonBlock(height: 12, width: 135),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class OrderDetailSkeleton extends StatelessWidget {
  const OrderDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Đang tải chi tiết đơn hàng',
    liveRegion: true,
    child: ExcludeSemantics(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppSkeletonCard(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppSkeletonBlock(height: 24, width: 72),
                    AppSkeletonBlock(height: 24, width: 104),
                  ],
                ),
                const SizedBox(height: 20),
                const AppSkeletonBlock(height: 12, width: 130),
                const SizedBox(height: 8),
                const AppSkeletonBlock(height: 32, width: 158),
                const SizedBox(height: 16),
                const Divider(height: 1, color: AppColors.borderSubtle),
                const SizedBox(height: 14),
                const AppSkeletonBlock(height: 12, width: 195),
              ],
            ),
            const SizedBox(height: 14),
            AppSkeletonCard(
              children: [
                const AppSkeletonBlock(height: 13, width: 192),
                const SizedBox(height: 20),
                ...List.generate(
                  3,
                  (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: Row(
                      children: [
                        const AppSkeletonBlock(
                          height: 28,
                          width: 28,
                          radius: 14,
                        ),
                        const SizedBox(width: 12),
                        AppSkeletonBlock(
                          height: 12,
                          width: index == 1 ? 168 : 122,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            AppSkeletonCard(
              children: [
                const AppSkeletonBlock(height: 13, width: 170),
                const SizedBox(height: 20),
                ...List.generate(
                  3,
                  (_) => const Padding(
                    padding: EdgeInsets.only(bottom: 18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AppSkeletonBlock(height: 12, width: 130),
                        AppSkeletonBlock(height: 15, width: 72),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            AppSkeletonCard(
              children: [
                const AppSkeletonBlock(height: 13, width: 152),
                const SizedBox(height: 18),
                Row(
                  children: [
                    const AppSkeletonBlock(height: 52, width: 52, radius: 10),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppSkeletonBlock(height: 12),
                          SizedBox(height: 8),
                          AppSkeletonBlock(height: 12, width: 125),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

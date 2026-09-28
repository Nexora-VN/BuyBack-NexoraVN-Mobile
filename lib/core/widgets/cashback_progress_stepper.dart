import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../utils/format_utils.dart';
import 'app_card.dart';

class CashbackProgressStepper extends StatelessWidget {
  final String orderStatus;
  final String commissionState;
  final String? cashbackState;
  final String? purchasedAt;

  const CashbackProgressStepper({
    super.key,
    required this.orderStatus,
    required this.commissionState,
    this.cashbackState,
    this.purchasedAt,
  });

  @override
  Widget build(BuildContext context) {
    final isCancelled = [
          'REJECTED',
          'FAILED',
          'CANCELLED',
          'cancelled',
        ].contains(orderStatus) ||
        ['REJECTED', 'REVERSED'].contains(commissionState) ||
        ['REJECTED', 'REVERSED'].contains(cashbackState ?? '');

    final isWithdrawn = ['PAID', 'WITHDRAWN'].contains(cashbackState ?? '') ||
        commissionState == 'PAID';

    final isAvailable = isWithdrawn || cashbackState == 'AVAILABLE';

    final isOrderCompleted = isAvailable ||
        [
          'VALIDATED',
          'COMPLETED',
          'completed',
          'APPROVED',
        ].contains(orderStatus);

    if (isCancelled) {
      return Container(
        padding: const EdgeInsets.all(14.0),
        decoration: BoxDecoration(
          color: AppColors.statusDangerBg,
          borderRadius: AppDimensions.roundedCard,
          border: Border.all(
            color: AppColors.statusDangerText.withValues(alpha: 0.3),
            width: 1.0,
          ),
        ),
        child: const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(LucideIcons.alertCircle, size: 20, color: AppColors.statusDangerText),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Đơn hàng hoặc hoa hồng không hợp lệ',
                    style: TextStyle(
                      color: AppColors.statusDangerText,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Đơn hàng này đã bị hủy, đổi trả hoặc không thỏa mãn điều kiện tích lũy của sàn thương mại điện tử.',
                    style: TextStyle(
                      color: AppColors.statusDangerText,
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final steps = [
      _StepData(
        title: 'Đã ghi nhận',
        desc: purchasedAt != null
            ? FormatUtils.formatDateTime(purchasedAt)
            : 'Ghi nhận qua Piggy',
        done: true,
        current: false,
      ),
      _StepData(
        title: 'Đơn hoàn tất',
        desc: isOrderCompleted ? 'Giao thành công' : 'Đang giao hàng',
        done: isOrderCompleted,
        current: !isOrderCompleted && !isCancelled,
      ),
      _StepData(
        title: 'Đối soát hoa hồng',
        desc: isAvailable ? 'Đã đối soát xong' : 'Sàn đang đối soát',
        done: isAvailable,
        current: isOrderCompleted && !isAvailable && !isCancelled,
      ),
      _StepData(
        title: isWithdrawn ? 'Đã rút tiền' : 'Tiền vào ví',
        desc: isWithdrawn
            ? 'Đã chuyển về ngân hàng'
            : isAvailable
                ? 'Sẵn sàng rút tiền'
                : 'Chờ hoàn tất đối soát',
        done: isWithdrawn || isAvailable,
        current: isAvailable && !isWithdrawn && !isCancelled,
      ),
    ];

    return AppCard(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'TIẾN TRÌNH TÍCH LŨY HOÀN TIỀN',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              if (isWithdrawn)
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.arrowDownToLine, size: 13, color: AppColors.statusInfoText),
                    SizedBox(width: 4),
                    Text(
                      'Đã rút tiền',
                      style: TextStyle(
                        color: AppColors.statusInfoText,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                )
              else if (isAvailable)
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.check, size: 13, color: AppColors.statusSuccessText),
                    SizedBox(width: 4),
                    Text(
                      'Sẵn sàng rút',
                      style: TextStyle(
                        color: AppColors.statusSuccessText,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                )
              else
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.clock3, size: 13, color: AppColors.statusPendingText),
                    SizedBox(width: 4),
                    Text(
                      'Đang đối soát',
                      style: TextStyle(
                        color: AppColors.statusPendingText,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            children: List.generate(steps.length, (index) {
              final step = steps[index];
              final isLast = index == steps.length - 1;

              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: step.done
                                ? (isWithdrawn && index == 3
                                    ? AppColors.statusInfoText
                                    : AppColors.statusSuccessText)
                                : step.current
                                    ? AppColors.statusPendingBg
                                    : AppColors.pageTint,
                            border: Border.all(
                              color: step.done
                                  ? Colors.transparent
                                  : step.current
                                      ? AppColors.statusPendingText
                                      : AppColors.borderSubtle,
                              width: step.current ? 2.0 : 1.0,
                            ),
                          ),
                          child: Center(
                            child: step.done
                                ? Icon(
                                    isWithdrawn && index == 3
                                        ? LucideIcons.arrowDownToLine
                                        : LucideIcons.check,
                                    size: 13,
                                    color: Colors.white,
                                  )
                                : step.current
                                    ? const Icon(
                                        LucideIcons.clock3,
                                        size: 12,
                                        color: AppColors.statusPendingText,
                                      )
                                    : Text(
                                        '${index + 1}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textDisabled,
                                        ),
                                      ),
                          ),
                        ),
                        if (!isLast)
                          Expanded(
                            child: Container(
                              width: 2,
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              color: step.done
                                  ? AppColors.statusSuccessText.withValues(alpha: 0.3)
                                  : AppColors.borderSubtle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: isLast ? 0 : 18.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              step.title,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: step.done
                                    ? (isWithdrawn && index == 3
                                        ? AppColors.statusInfoText
                                        : AppColors.statusSuccessText)
                                    : step.current
                                        ? AppColors.statusPendingText
                                        : AppColors.textDisabled,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              step.desc,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _StepData {
  final String title;
  final String desc;
  final bool done;
  final bool current;

  _StepData({
    required this.title,
    required this.desc,
    required this.done,
    required this.current,
  });
}

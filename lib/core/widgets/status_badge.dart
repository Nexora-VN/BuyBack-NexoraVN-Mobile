import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

enum StatusDomain {
  general,
  order,
  commission,
  cashback,
  withdrawal,
  bank,
  affiliate,
}

class StatusBadge extends StatelessWidget {
  final String status;
  final StatusDomain domain;
  final String? labelOverride;

  const StatusBadge({
    super.key,
    required this.status,
    this.domain = StatusDomain.general,
    this.labelOverride,
  });

  static const Map<String, String> _labels = {
    'ACTIVE': 'Hoạt động',
    'WORKING': 'Hoạt động',
    'COMPLETED': 'Hoàn thành',
    'AVAILABLE': 'Có thể rút',
    'VALIDATED': 'Hoàn thành',
    'PENDING': 'Chờ xử lý',
    'PROCESSING': 'Đang xử lý',
    'REJECTED': 'Từ chối',
    'FAILED': 'Thất bại',
    'DISABLED': 'Đã khóa',
    'DELETED': 'Đã xóa',
    'ESTIMATED': 'Hoa hồng dự kiến',
    'MANUAL_REVIEW': 'Cần đối chiếu',
    'PARTIALLY_VALIDATED': 'Hoàn thành một phần',
    'PAID': 'Đã rút tiền',
    'REVERSED': 'Đã thu hồi',
    'APPROVED': 'Đã duyệt',
    'CANCELLED': 'Đã hủy',
    'cancelled': 'Đã hủy',
    'EXPIRED': 'Hết hạn',
    'WITHDRAWN': 'Đã rút tiền',
  };

  static const Map<StatusDomain, Map<String, String>> _contextual = {
    StatusDomain.order: {
      'VALIDATED': 'Hoàn thành',
      'COMPLETED': 'Hoàn thành',
      'PENDING': 'Đang xử lý',
      'PROCESSING': 'Đang xử lý',
      'REJECTED': 'Đã hủy',
      'cancelled': 'Đã hủy',
    },
    StatusDomain.commission: {
      'ESTIMATED': 'Hoa hồng dự kiến',
      'VALIDATED': 'Hoa hồng đã xác thực',
      'PAID': 'Đã quyết toán',
      'REJECTED': 'Đã hủy',
    },
    StatusDomain.cashback: {
      'PENDING': 'Chờ xác nhận',
      'VALIDATED': 'Chờ đối soát',
      'AVAILABLE': 'Có thể rút',
      'PAID': 'Đã rút tiền',
      'WITHDRAWN': 'Đã rút tiền',
    },
    StatusDomain.withdrawal: {
      'PENDING': 'Chờ xử lý',
      'PROCESSING': 'Đang chuyển tiền',
      'COMPLETED': 'Đã chuyển tiền',
      'FAILED': 'Chuyển thất bại',
      'REJECTED': 'Từ chối rút',
    },
    StatusDomain.bank: {
      'PENDING': 'Chờ duyệt',
      'APPROVED': 'Đã duyệt',
      'REJECTED': 'Từ chối',
    },
  };

  String get label {
    return _contextual[domain]?[status] ?? _labels[status] ?? status;
  }

  @override
  Widget build(BuildContext context) {
    final text = labelOverride ?? label;

    Color textColor;
    Color bgColor;
    IconData icon;

    // 1. Blue (info): Withdrawn / Paid
    final isWithdrawn =
        ['PAID', 'WITHDRAWN'].contains(status) ||
        text == 'Đã rút tiền' ||
        text == 'Đã chuyển tiền' ||
        text == 'Đã quyết toán' ||
        (domain == StatusDomain.withdrawal && status == 'COMPLETED');

    // 2. Red (danger): Failed / Rejected / Cancelled
    final isFailed =
        [
          'REJECTED',
          'FAILED',
          'REVERSED',
          'CANCELLED',
          'cancelled',
          'DISABLED',
          'EXPIRED',
        ].contains(status) ||
        text == 'Đã hủy' ||
        text == 'Thất bại' ||
        text == 'Từ chối' ||
        text == 'Chuyển thất bại';

    // 3. Green (success): Validated / Available / Approved
    final isSuccess =
        !isWithdrawn &&
        ([
              'ACTIVE',
              'WORKING',
              'AVAILABLE',
              'COMPLETED',
              'VALIDATED',
              'APPROVED',
            ].contains(status) ||
            text == 'Hoàn thành' ||
            text == 'Có thể rút' ||
            text == 'Đã duyệt' ||
            text == 'Hoa hồng đã xác thực');

    // 4. Purple (Review / Mismatch)
    final isReview =
        ['MANUAL_REVIEW', 'MISMATCH'].contains(status) ||
        text == 'Cần đối chiếu';

    if (isWithdrawn) {
      textColor = AppColors.statusInfoText;
      bgColor = AppColors.statusInfoBg;
      icon = LucideIcons.arrowDownToLine;
    } else if (isFailed) {
      textColor = AppColors.statusDangerText;
      bgColor = AppColors.statusDangerBg;
      icon = LucideIcons.xCircle;
    } else if (isSuccess) {
      textColor = AppColors.statusSuccessText;
      bgColor = AppColors.statusSuccessBg;
      icon = LucideIcons.checkCircle2;
    } else if (isReview) {
      textColor = AppColors.statusReviewText;
      bgColor = AppColors.statusReviewBg;
      icon = LucideIcons.helpCircle;
    } else {
      // Pending / Warning
      textColor = AppColors.statusPendingText;
      bgColor = AppColors.statusPendingBg;
      icon = LucideIcons.clock3;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9.0, vertical: 3.5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppDimensions.roundedPill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

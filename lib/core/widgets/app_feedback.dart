import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../network/api_error.dart';

final appMessengerKey = GlobalKey<ScaffoldMessengerState>();

class AppFeedback {
  static const _apiMessages = {
    'SHOPEE_LINK_INVALID':
        'Link Shopee không hợp lệ. Vui lòng kiểm tra và thử lại.',
    'PROVIDER_PRODUCT_INVALID': 'Chưa đọc được sản phẩm. Vui lòng thử lại.',
    'INSUFFICIENT_BALANCE': 'Số dư khả dụng không đủ.',
    'WITHDRAWALS_DISABLED': 'Tính năng rút tiền đang tạm dừng.',
    'BANK_NOT_APPROVED': 'Tài khoản ngân hàng chưa được duyệt.',
  };

  static String messageFor(
    Object error, {
    String fallback = 'Không thể hoàn tất yêu cầu. Vui lòng thử lại.',
  }) {
    if (error is ApiError) {
      final translated = _apiMessages[error.code];
      if (translated != null) return translated;
      if ([
        'Invalid credentials',
        'Invalid email or password',
      ].contains(error.message)) {
        return 'Email hoặc mật khẩu không đúng.';
      }
      if (error.statusCode == 401) {
        return 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.';
      }
      if (error.statusCode == 403) {
        return 'Bạn không có quyền thực hiện thao tác này.';
      }
      if (error.statusCode == 0) {
        return 'Không thể kết nối. Vui lòng kiểm tra mạng và thử lại.';
      }
      // Avoid exposing raw backend codes or English diagnostics in the VI-only release.
      if (RegExp(r'[À-ỹ]').hasMatch(error.message)) return error.message;
    }
    return fallback;
  }

  static void success(String message) => _show(message, isError: false);

  static void failure(String message) => _show(message, isError: true);

  static void error(
    Object error, {
    String fallback = 'Không thể hoàn tất yêu cầu. Vui lòng thử lại.',
  }) {
    _show(messageFor(error, fallback: fallback), isError: true);
  }

  static void _show(String message, {required bool isError}) {
    final messenger = appMessengerKey.currentState;
    if (messenger == null) return;
    messenger.hideCurrentSnackBar();
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: isError ? 5 : 3),
        backgroundColor: isError
            ? AppColors.statusDangerText
            : AppColors.statusSuccessText,
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

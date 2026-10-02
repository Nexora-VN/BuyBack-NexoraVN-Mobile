import '../../../core/utils/format_utils.dart';
import '../models/transaction_source_model.dart';
import '../models/wallet_transaction_model.dart';

/// Copy used only by the wallet and cashback screens until app-wide i18n exists.
class TransactionCopy {
  final bool isVietnamese;

  const TransactionCopy({required this.isVietnamese});

  String text(String vi, String en) => isVietnamese ? vi : en;

  String walletTitle(String type) => switch (type.toUpperCase()) {
    'CASHBACK_CREDIT' => text(
      'Hoàn tiền đã cộng vào ví',
      'Cashback added to wallet',
    ),
    'CASHBACK_REVERSAL' => text('Thu hồi tiền hoàn', 'Cashback reversed'),
    'WITHDRAWAL_RESERVE' => text(
      'Đã giữ tiền để rút',
      'Money held for withdrawal',
    ),
    'WITHDRAWAL_COMPLETE' => text('Rút tiền hoàn tất', 'Withdrawal completed'),
    'WITHDRAWAL_RELEASE' => text(
      'Hoàn lại tiền rút',
      'Withdrawal funds returned',
    ),
    'MANUAL_ADJUSTMENT' => text('Điều chỉnh số dư', 'Balance adjustment'),
    _ => text('Biến động số dư', 'Balance activity'),
  };

  String cashbackStatus(String state) => switch (state.toUpperCase()) {
    'PENDING' => text('Chờ xác nhận', 'Pending'),
    'VALIDATED' => text('Chờ đối soát', 'Validated'),
    'AVAILABLE' => text('Có thể rút', 'Available'),
    'REJECTED' => text('Đã từ chối', 'Rejected'),
    'REVERSED' => text('Đã thu hồi', 'Reversed'),
    _ => text('Đang cập nhật', 'Updating'),
  };

  String? sourceContext(TransactionSourceModel? source) {
    final orders = source?.orders ?? const <TransactionOrderSource>[];
    if (orders.length > 1) {
      final count = text(
        '${orders.length} đơn hàng',
        '${orders.length} orders',
      );
      final platforms = orders
          .map((order) => order.platform.trim())
          .where((platform) => platform.isNotEmpty)
          .toSet();
      final numbers = orders
          .map((order) => _readableOrderSn(order.orderSn))
          .where((number) => number.isNotEmpty)
          .toSet();
      return [
        count,
        if (platforms.isNotEmpty) platforms.join(', '),
        if (numbers.isNotEmpty) numbers.join(', '),
      ].join(' · ');
    }

    final order = orders.isNotEmpty ? orders.first : source?.order;
    if (order != null) {
      final name = order.productName?.trim();
      final platform = order.platform.trim();
      final readableOrderSn = _readableOrderSn(order.orderSn);
      if (name != null && name.isNotEmpty) {
        return [
          name,
          if (platform.isNotEmpty) platform,
          if (readableOrderSn.isNotEmpty) readableOrderSn,
        ].join(' · ');
      }
      if (readableOrderSn.isNotEmpty) {
        return platform.isEmpty
            ? '${text('Đơn', 'Order')} $readableOrderSn'
            : '$platform · $readableOrderSn';
      }
      return platform.isEmpty
          ? text('Đơn hàng', 'Order')
          : '${text('Đơn hàng', 'Order')} · $platform';
    }

    final withdrawal = source?.withdrawal;
    if (withdrawal != null) {
      final bank = withdrawal.bankName?.trim();
      final lastFour = withdrawal.lastFour?.trim();
      if (bank != null &&
          bank.isNotEmpty &&
          lastFour != null &&
          lastFour.isNotEmpty) {
        return '$bank · •••• $lastFour';
      }
      if (bank != null && bank.isNotEmpty) return bank;
      if (lastFour != null && lastFour.isNotEmpty) {
        return '${text('Tài khoản', 'Account')} •••• $lastFour';
      }
      return text('Yêu cầu rút tiền', 'Withdrawal request');
    }
    return null;
  }

  String walletAmountLabel(WalletTransactionModel transaction) =>
      _usesReserved(transaction)
      ? text('Tiền đang giữ', 'Held funds')
      : text('Số dư có thể rút', 'Available balance');

  bool cashbackIsCancelled(String state) =>
      state == 'REJECTED' || state == 'REVERSED';

  String cashbackAmountLabel(String state) => cashbackIsCancelled(state)
      ? text('Tiền hoàn không khả dụng', 'Cashback unavailable')
      : state == 'AVAILABLE'
      ? text('Tiền hoàn có thể rút', 'Available cashback')
      : text('Tiền hoàn dự kiến', 'Estimated cashback');

  String walletAmount(WalletTransactionModel transaction) {
    final value = _usesReserved(transaction)
        ? transaction.reservedDelta
        : transaction.availableDelta;
    final amount = _amount(value);
    if (amount == null) return '—';
    final formatted = FormatUtils.formatVnd(value);
    return amount > 0 ? '+$formatted' : formatted;
  }

  bool walletIsPositive(WalletTransactionModel transaction) {
    final value = _usesReserved(transaction)
        ? transaction.reservedDelta
        : transaction.availableDelta;
    return (_amount(value) ?? 0) > 0;
  }

  static bool _usesReserved(WalletTransactionModel transaction) =>
      transaction.type == 'WITHDRAWAL_COMPLETE' ||
      (_amount(transaction.availableDelta) == 0 &&
          _amount(transaction.reservedDelta) != 0);

  static num? _amount(String? value) =>
      value == null ? null : num.tryParse(value);

  static String _readableOrderSn(String orderSn) {
    final trimmed = orderSn.trim();
    return RegExp(
          r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
        ).hasMatch(trimmed)
        ? ''
        : trimmed;
  }
}

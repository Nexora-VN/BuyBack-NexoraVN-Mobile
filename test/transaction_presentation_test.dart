import 'package:buyback_mobile/features/finance/models/cashback_model.dart';
import 'package:buyback_mobile/features/finance/models/wallet_transaction_model.dart';
import 'package:buyback_mobile/features/finance/utils/transaction_copy.dart';
import 'package:buyback_mobile/features/finance/utils/merge_paged_rows.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses optional source and keeps older responses valid', () {
    final cashback = CashbackModel.fromJson({
      'id': 'cashback-uuid',
      'userAmount': '20000',
      'state': 'AVAILABLE',
      'source': {
        'order': {
          'id': 'order-uuid',
          'orderSn': 'ORD-123',
          'platform': 'Shopee',
          'productName': 'Tai nghe',
        },
        'withdrawal': null,
      },
    });
    expect(cashback.source?.order?.orderSn, 'ORD-123');
    expect(cashback.source?.order?.productName, 'Tai nghe');

    final oldTransaction = WalletTransactionModel.fromJson({
      'id': 'ledger-uuid',
      'type': 'CASHBACK_CREDIT',
      'createdAt': '2026-10-01T00:00:00Z',
    });
    expect(oldTransaction.source, isNull);
  });

  test('wallet labels and amounts describe the actual balance movement', () {
    final copy = TransactionCopy(isVietnamese: true);
    final complete = WalletTransactionModel.fromJson({
      'id': 'ledger-uuid',
      'type': 'WITHDRAWAL_COMPLETE',
      'availableDelta': '0',
      'reservedDelta': '-100000',
      'createdAt': '2026-10-01T00:00:00Z',
    });
    expect(copy.walletTitle(complete.type), 'Rút tiền hoàn tất');
    expect(copy.walletAmount(complete), startsWith('-100.000'));
    expect(copy.walletAmountLabel(complete), 'Tiền đang giữ');
    expect(copy.walletTitle('SOME_FUTURE_ENUM'), 'Biến động số dư');
    expect(copy.cashbackStatus('SOME_FUTURE_ENUM'), 'Đang cập nhật');
  });

  test('context falls back without showing internal ids', () {
    final copy = TransactionCopy(isVietnamese: false);
    final transaction = WalletTransactionModel.fromJson({
      'id': 'ledger-uuid',
      'type': 'CASHBACK_CREDIT',
      'source': {
        'order': {
          'id': 'order-uuid',
          'orderSn': '',
          'platform': '',
          'productName': null,
        },
      },
    });
    expect(copy.sourceContext(transaction.source), 'Order');
    final uuidOrder = WalletTransactionModel.fromJson({
      'id': 'ledger-uuid',
      'type': 'CASHBACK_CREDIT',
      'source': {
        'order': {
          'id': 'order-uuid',
          'orderSn': 'aa5ff759-08b7-4c9f-b151-61298c00fd7c',
          'platform': 'Shopee',
        },
      },
    });
    expect(copy.sourceContext(uuidOrder.source), 'Order · Shopee');
    final namedOrder = WalletTransactionModel.fromJson({
      'id': 'ledger-uuid',
      'type': 'CASHBACK_CREDIT',
      'source': {
        'order': {
          'id': 'order-uuid',
          'orderSn': 'SP-123',
          'platform': 'Shopee',
          'productName': 'Blue jacket',
        },
      },
    });
    expect(
      copy.sourceContext(namedOrder.source),
      'Blue jacket · Shopee · SP-123',
    );
    expect(copy.sourceContext(null), isNull);
  });

  test(
    'multi-order context shows the count and every readable order number',
    () {
      final transaction = WalletTransactionModel.fromJson({
        'id': 'ledger-uuid',
        'type': 'CASHBACK_CREDIT',
        'source': {
          'order': {'id': 'first', 'orderSn': 'ORD-1', 'platform': 'Shopee'},
          'orders': [
            {'id': 'first', 'orderSn': 'ORD-1', 'platform': 'Shopee'},
            {'id': 'second', 'orderSn': 'ORD-2', 'platform': 'Shopee'},
            {
              'id': 'third',
              'orderSn': 'aa5ff759-08b7-4c9f-b151-61298c00fd7c',
              'platform': 'TikTok Shop',
            },
          ],
        },
      });
      expect(transaction.source?.orders.length, 3);
      expect(
        TransactionCopy(isVietnamese: true).sourceContext(transaction.source),
        '3 đơn hàng · Shopee, TikTok Shop · ORD-1, ORD-2',
      );
      expect(
        TransactionCopy(isVietnamese: false).sourceContext(transaction.source),
        '3 orders · Shopee, TikTok Shop · ORD-1, ORD-2',
      );
    },
  );

  test('page merge retains order and removes repeated boundary rows', () {
    expect(
      mergePagedRows([
        ['a', 'b'],
        ['b', 'c'],
      ], (row) => row),
      ['a', 'b', 'c'],
    );
  });
}

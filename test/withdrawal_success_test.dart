import 'package:buyback_mobile/core/widgets/app_text_field.dart';
import 'package:buyback_mobile/features/finance/models/bank_account_model.dart';
import 'package:buyback_mobile/features/finance/models/dashboard_model.dart';
import 'package:buyback_mobile/features/finance/repositories/finance_repository.dart';
import 'package:buyback_mobile/features/withdrawals/screens/new_withdrawal_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _WithdrawalRepository extends Fake implements FinanceRepository {
  int walletReads = 0;
  bool submitted = false;

  @override
  Future<DashboardWallet> getWallet() async {
    walletReads++;
    if (walletReads > 1) throw Exception('Wallet refresh failed');
    return DashboardWallet(available: '100000', reserved: '0');
  }

  @override
  Future<List<BankAccountModel>> getBankAccounts({String? status}) async => [
    BankAccountModel(
      id: 'bank-1',
      bankCode: 'VCB',
      bankName: 'Vietcombank',
      accountHolder: 'NGUYEN VAN A',
      lastFour: '1234',
      status: 'APPROVED',
    ),
  ];

  @override
  Future<void> createWithdrawal({
    required String amount,
    required String bankId,
    required String idempotencyKey,
  }) async {
    submitted = true;
  }
}

void main() {
  testWidgets('confirmation remains visible when wallet refresh fails', (
    tester,
  ) async {
    final repository = _WithdrawalRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [financeRepositoryProvider.overrideWithValue(repository)],
        child: const MaterialApp(home: NewWithdrawalScreen()),
      ),
    );
    await tester.pumpAndSettle();

    final amountField = find.byWidgetPredicate(
      (widget) =>
          widget is AppTextField &&
          widget.label!.startsWith('Số tiền muốn rút'),
    );
    await tester.enterText(
      find.descendant(of: amountField, matching: find.byType(TextField)),
      '50000',
    );
    await tester.tap(find.text('Tiếp tục'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Xác nhận rút'));
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(NewWithdrawalScreen)),
    );
    await expectLater(
      container.refresh(withdrawalWalletProvider.future),
      throwsException,
    );
    await tester.pump();

    expect(repository.submitted, isTrue);
    expect(repository.walletReads, greaterThan(1));
    expect(find.text('Đã gửi yêu cầu rút tiền'), findsOneWidget);
    expect(find.textContaining('Wallet refresh failed'), findsNothing);
  });
}

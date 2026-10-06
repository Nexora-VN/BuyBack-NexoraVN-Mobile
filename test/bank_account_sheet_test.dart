import 'dart:async';

import 'package:buyback_mobile/core/widgets/app_feedback.dart';
import 'package:buyback_mobile/core/widgets/app_text_field.dart';
import 'package:buyback_mobile/features/finance/models/bank_account_model.dart';
import 'package:buyback_mobile/features/finance/repositories/finance_repository.dart';
import 'package:buyback_mobile/features/finance/widgets/add_bank_account_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeFinanceRepository extends Fake implements FinanceRepository {
  String? updatedId;
  String? updatedHolder;
  String? updatedNumber;
  String? createdCode;
  Completer<void>? pendingUpdate;

  @override
  Future<List<BankOption>> getSupportedBanks() async => [
    BankOption(code: 'VCB', name: 'Vietcombank'),
    BankOption(code: 'MOMO', name: 'MoMo', kind: 'wallet'),
  ];

  @override
  Future<void> createBankAccount({
    required String bankCode,
    required String bankName,
    required String accountHolder,
    required String accountNumber,
  }) async {
    createdCode = bankCode;
    updatedHolder = accountHolder;
    updatedNumber = accountNumber;
  }

  @override
  Future<void> updateBankAccount(
    String id, {
    required String bankCode,
    required String bankName,
    required String accountHolder,
    required String accountNumber,
  }) async {
    updatedId = id;
    updatedHolder = accountHolder;
    updatedNumber = accountNumber;
    if (pendingUpdate != null) await pendingUpdate!.future;
  }
}

void main() {
  testWidgets('editing a bank account submits the existing account ID', (
    tester,
  ) async {
    final repository = FakeFinanceRepository();
    final bank = BankAccountModel(
      id: 'bank-1',
      bankCode: 'VCB',
      bankName: 'Vietcombank',
      accountHolder: 'NGUYEN VAN A',
      lastFour: '1234',
      status: 'APPROVED',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [financeRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp(
          scaffoldMessengerKey: appMessengerKey,
          home: Consumer(
            builder: (context, ref, _) => Scaffold(
              body: TextButton(
                onPressed: () =>
                    showAddBankAccountSheet(context, ref, bank: bank),
                child: const Text('Sửa'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Sửa'));
    await tester.pumpAndSettle();
    expect(find.text('Sửa nơi nhận tiền'), findsOneWidget);
    expect(find.text('Số tài khoản'), findsOneWidget);
    final numberField = find.byWidgetPredicate(
      (widget) => widget is AppTextField && widget.label == 'Số tài khoản',
    );
    await tester.enterText(
      find.descendant(of: numberField, matching: find.byType(TextField)),
      '0123456789',
    );
    final holderField = find.byWidgetPredicate(
      (widget) => widget is AppTextField && widget.label == 'Tên chủ tài khoản',
    );
    await tester.enterText(
      find.descendant(of: holderField, matching: find.byType(TextField)),
      'TRAN VAN B',
    );
    await tester.tap(find.text('Kiểm tra thông tin'));
    await tester.pumpAndSettle();
    expect(find.text('Kiểm tra thông tin nhận tiền'), findsOneWidget);
    await tester.tap(find.text('Xác nhận lưu'));
    await tester.pumpAndSettle();
    expect(repository.updatedId, 'bank-1');
    expect(repository.updatedHolder, 'TRAN VAN B');
    expect(repository.updatedNumber, '0123456789');
  });

  testWidgets('bank sheet stays open while an update is in progress', (
    tester,
  ) async {
    final repository = FakeFinanceRepository()
      ..pendingUpdate = Completer<void>();
    final bank = BankAccountModel(
      id: 'bank-1',
      bankCode: 'VCB',
      bankName: 'Vietcombank',
      accountHolder: 'NGUYEN VAN A',
      lastFour: '1234',
      status: 'APPROVED',
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [financeRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp(
          scaffoldMessengerKey: appMessengerKey,
          home: Consumer(
            builder: (context, ref, _) => Scaffold(
              body: TextButton(
                onPressed: () =>
                    showAddBankAccountSheet(context, ref, bank: bank),
                child: const Text('Sửa'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Sửa'));
    await tester.pumpAndSettle();
    final numberField = find.byWidgetPredicate(
      (widget) => widget is AppTextField && widget.label == 'Số tài khoản',
    );
    await tester.enterText(
      find.descendant(of: numberField, matching: find.byType(TextField)),
      '0123456789',
    );
    await tester.tap(find.text('Kiểm tra thông tin'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Xác nhận lưu'));
    await tester.pump();
    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(find.text('Kiểm tra thông tin nhận tiền'), findsOneWidget);
    repository.pendingUpdate!.complete();
    await tester.pumpAndSettle();
    expect(find.text('Kiểm tra thông tin nhận tiền'), findsNothing);
  });

  testWidgets('MoMo can be selected and saved with a phone number', (
    tester,
  ) async {
    final repository = FakeFinanceRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [financeRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp(
          scaffoldMessengerKey: appMessengerKey,
          home: Consumer(
            builder: (context, ref, _) => Scaffold(
              body: TextButton(
                onPressed: () => showAddBankAccountSheet(context, ref),
                child: const Text('Thêm'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Thêm'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Chọn ngân hàng hoặc MoMo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('MoMo').last);
    await tester.pumpAndSettle();
    final phone = find.byWidgetPredicate(
      (widget) =>
          widget is AppTextField && widget.label == 'Số điện thoại ví MoMo',
    );
    final holder = find.byWidgetPredicate(
      (widget) => widget is AppTextField && widget.label == 'Tên chủ ví',
    );
    await tester.enterText(
      find.descendant(of: phone, matching: find.byType(TextField)),
      '0901234567',
    );
    await tester.enterText(
      find.descendant(of: holder, matching: find.byType(TextField)),
      'NGUYEN VAN A',
    );
    await tester.tap(find.text('Kiểm tra thông tin'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Xác nhận lưu'));
    await tester.pumpAndSettle();
    expect(repository.createdCode, 'MOMO');
    expect(repository.updatedNumber, '0901234567');
  });
}

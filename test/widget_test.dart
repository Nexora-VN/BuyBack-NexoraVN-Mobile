import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:buyback_mobile/main.dart';
import 'package:buyback_mobile/features/auth/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:buyback_mobile/core/widgets/cashback_progress_stepper.dart';
import 'package:buyback_mobile/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [authProvider.overrideWith((ref) => AuthNotifierMock())],
        child: const BuyBackApp(),
      ),
    );
    await tester.pump();
  });

  testWidgets('Vietnamese device locale loads Material translations', (
    tester,
  ) async {
    tester.binding.platformDispatcher.localeTestValue = const Locale('vi');
    tester.binding.platformDispatcher.localesTestValue = const [Locale('vi')];
    addTearDown(() {
      tester.binding.platformDispatcher.clearLocaleTestValue();
      tester.binding.platformDispatcher.clearLocalesTestValue();
    });
    await tester.pumpWidget(
      ProviderScope(
        overrides: [authProvider.overrideWith((ref) => AuthNotifierMock())],
        child: const BuyBackApp(),
      ),
    );
    await tester.pump();
    final context = tester.element(find.byType(Scaffold).first);
    expect(Localizations.localeOf(context).languageCode, 'vi');
    expect(MaterialLocalizations.of(context).cancelButtonLabel, 'Huỷ');
  });

  testWidgets('English device still sees Vietnamese end-user UI', (
    tester,
  ) async {
    tester.binding.platformDispatcher.localeTestValue = const Locale('en');
    tester.binding.platformDispatcher.localesTestValue = const [Locale('en')];
    addTearDown(() {
      tester.binding.platformDispatcher.clearLocaleTestValue();
      tester.binding.platformDispatcher.clearLocalesTestValue();
    });
    await tester.pumpWidget(
      ProviderScope(
        overrides: [authProvider.overrideWith((ref) => AuthNotifierMock())],
        child: const BuyBackApp(),
      ),
    );
    await tester.pump();
    final context = tester.element(find.byType(Scaffold).first);
    expect(Localizations.localeOf(context).languageCode, 'vi');
  });

  testWidgets('settled commission is credited to wallet, not withdrawn', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('vi'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          body: SingleChildScrollView(
            child: CashbackProgressStepper(
              orderStatus: 'VALIDATED',
              commissionState: 'PAID',
              cashbackState: 'AVAILABLE',
            ),
          ),
        ),
      ),
    );
    expect(find.text('Đã ghi nhận vào ví'), findsOneWidget);
    expect(find.text('Đã rút tiền'), findsNothing);
    expect(find.text('Đã chuyển về ngân hàng'), findsNothing);
  });
}

class AuthNotifierMock extends StateNotifier<AuthState>
    implements AuthNotifier {
  AuthNotifierMock() : super(const AuthState(isInitialChecked: true));

  @override
  Future<void> checkAuth() async {}

  @override
  Future<bool> login(String email, String password) async => true;

  @override
  Future<bool> loginWithGoogle({
    String? idToken,
    String? accessToken,
    String? displayName,
    String? email,
  }) async => true;

  @override
  Future<void> logout() async {}
}

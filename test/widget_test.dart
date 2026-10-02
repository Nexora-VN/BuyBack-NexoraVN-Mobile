import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:buyback_mobile/main.dart';
import 'package:buyback_mobile/features/auth/providers/auth_provider.dart';
import 'package:flutter/material.dart';

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

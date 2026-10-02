import 'package:buyback_mobile/core/widgets/app_text_field.dart';
import 'package:buyback_mobile/features/auth/providers/auth_provider.dart';
import 'package:buyback_mobile/features/auth/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeAuthNotifier extends StateNotifier<AuthState> implements AuthNotifier {
  FakeAuthNotifier() : super(const AuthState(isInitialChecked: true));
  int loginCalls = 0;

  @override
  Future<bool> login(String email, String password) async {
    loginCalls++;
    return false;
  }

  @override
  Future<void> checkAuth() async {}

  @override
  Future<bool> loginWithGoogle({String? idToken, String? accessToken, String? displayName, String? email}) async => false;

  @override
  Future<void> logout() async {}
}

void main() {
  testWidgets('mobile rejects a seven-character password before calling auth', (tester) async {
    final notifier = FakeAuthNotifier();
    await tester.pumpWidget(ProviderScope(
      overrides: [authProvider.overrideWith((ref) => notifier)],
      child: const MaterialApp(home: LoginScreen()),
    ));

    final email = find.descendant(
      of: find.byWidgetPredicate((widget) => widget is AppTextField && widget.label == 'Email'),
      matching: find.byType(TextField),
    );
    final password = find.descendant(
      of: find.byWidgetPredicate((widget) => widget is AppTextField && widget.label == 'Mật khẩu'),
      matching: find.byType(TextField),
    );
    await tester.enterText(email, 'user@example.com');
    await tester.enterText(password, '1234567');
    await tester.ensureVisible(find.text('Đăng nhập').last);
    await tester.tap(find.text('Đăng nhập').last);
    await tester.pump();

    expect(find.text('Mật khẩu phải có ít nhất 8 ký tự'), findsOneWidget);
    expect(notifier.loginCalls, 0);
  });
}

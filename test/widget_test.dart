import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:buyback_mobile/main.dart';
import 'package:buyback_mobile/features/auth/providers/auth_provider.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith((ref) => AuthNotifierMock()),
        ],
        child: const BuyBackApp(),
      ),
    );
    await tester.pump();
  });
}

class AuthNotifierMock extends StateNotifier<AuthState> implements AuthNotifier {
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

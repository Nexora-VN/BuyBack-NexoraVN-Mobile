import 'package:buyback_mobile/core/network/api_error.dart';
import 'package:buyback_mobile/core/widgets/app_feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('feedback turns network failures into a useful next step', () {
    expect(
      AppFeedback.messageFor(
        ApiError(message: 'SocketException', statusCode: 0),
      ),
      'Không thể kết nối. Vui lòng kiểm tra mạng và thử lại.',
    );
  });

  test('backend diagnostics do not leak English or internal codes into Vietnamese UI', () {
    expect(
      AppFeedback.messageFor(
        ApiError(message: 'Invalid credentials', statusCode: 400),
      ),
      'Email hoặc mật khẩu không đúng.',
    );
    expect(
      AppFeedback.messageFor(
        ApiError(
          message: 'Invalid URL',
          statusCode: 400,
          code: 'SHOPEE_LINK_INVALID',
        ),
      ),
      'Link Shopee không hợp lệ. Vui lòng kiểm tra và thử lại.',
    );
  });

  testWidgets('success feedback stays visible after navigation', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        scaffoldMessengerKey: appMessengerKey,
        routes: {'/next': (_) => const Scaffold(body: Text('Màn hình mới'))},
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: TextButton(
                onPressed: () {
                  AppFeedback.success('Đã đăng xuất');
                  Navigator.of(context).pushNamed('/next');
                },
                child: const Text('Tiếp tục'),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Tiếp tục'));
    await tester.pumpAndSettle();
    expect(find.text('Màn hình mới'), findsOneWidget);
    expect(find.text('Đã đăng xuất'), findsOneWidget);
  });

  testWidgets('feedback appears once inside the app shell', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        scaffoldMessengerKey: appMessengerKey,
        home: Scaffold(
          body: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => AppFeedback.success('Đã lưu'),
                child: const Text('Lưu'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Lưu'));
    await tester.pump();
    expect(find.text('Đã lưu'), findsOneWidget);
  });
}

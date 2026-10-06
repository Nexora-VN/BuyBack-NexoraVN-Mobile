import 'package:buyback_mobile/core/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('card supports expanding ListTiles without hiding their ink', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppCard(
            padding: EdgeInsets.zero,
            child: ExpansionTile(
              title: Text('Hướng dẫn'),
              children: [Text('Nội dung hướng dẫn')],
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Hướng dẫn'));
    await tester.pumpAndSettle();
    expect(find.text('Nội dung hướng dẫn').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tappable cards still trigger their action', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppCard(
            onTap: () => taps++,
            child: const Text('Chi tiết đơn hàng'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Chi tiết đơn hàng'));
    expect(taps, 1);
    expect(tester.takeException(), isNull);
  });
}

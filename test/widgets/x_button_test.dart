import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecommerce_mobile/shared/widgets/x_button.dart';

void main() {
  group('XButton Widget', () {
    testWidgets('renders title and triggers onPressed when tapped', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: XButton(
              title: 'Thêm vào giỏ',
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Thêm vào giỏ'), findsOneWidget);
      await tester.tap(find.text('Thêm vào giỏ'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('shows loading spinner and blocks tap when busy is true', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: XButton(
              title: 'Đang lưu...',
              busy: true,
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      // Finds CircularProgressIndicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.tap(find.byType(XButton));
      await tester.pump();

      expect(tapped, isFalse);
    });
  });
}

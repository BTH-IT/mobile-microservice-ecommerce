import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecommerce_mobile/shared/widgets/x_input.dart';

void main() {
  group('XInput Widget', () {
    testWidgets('allows entering text and updates value', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: XInput(
              controller: controller,
              hint: 'Nhập họ và tên',
            ),
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'Nguyễn Văn A');
      await tester.pump();

      expect(controller.text, 'Nguyễn Văn A');
    });

    testWidgets('toggles obscureText when eye icon is pressed on password field', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: XInput(
              value: 'SecretPass123',
              obscureText: true,
              hint: 'Mật khẩu',
            ),
          ),
        ),
      );

      final textFieldFinder = find.byType(TextField);
      expect(textFieldFinder, findsOneWidget);

      TextField textField = tester.widget<TextField>(textFieldFinder);
      expect(textField.obscureText, isTrue);

      // Tap toggle icon to reveal password
      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();

      textField = tester.widget<TextField>(textFieldFinder);
      expect(textField.obscureText, isFalse);
    });
  });
}

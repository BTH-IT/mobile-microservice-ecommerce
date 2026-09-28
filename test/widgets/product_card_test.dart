import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecommerce_mobile/features/product/data/models/product_model.dart';
import 'package:ecommerce_mobile/features/product/presentation/widgets/product_card.dart';

void main() {
  group('ProductCard Widget', () {
    testWidgets('renders product details and triggers onTap', (tester) async {
      bool tapped = false;
      const product = ProductModel(
        id: 'prod-test-1',
        name: 'MacBook Air M2',
        slug: 'macbook-air-m2',
        price: 21600000,
        originalPrice: 24000000,
        brandName: 'Apple',
        stock: 5,
        images: ['https://example.com/macbook.jpg'],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 250,
              height: 380,
              child: ProductCard(
                product: product,
                onTap: () => tapped = true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('MacBook Air M2'), findsOneWidget);
      expect(find.text('-10%'), findsOneWidget);

      await tester.tap(find.text('MacBook Air M2'));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });
}

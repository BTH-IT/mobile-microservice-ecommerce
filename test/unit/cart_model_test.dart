import 'package:flutter_test/flutter_test.dart';
import 'package:ecommerce_mobile/features/cart/data/models/cart_model.dart';

void main() {
  group('CartModel & CartItemModel', () {
    test('calculates item total and cart subtotal correctly', () {
      const item1 = CartItemModel(
        id: 'cart-1',
        productId: 'prod-1',
        productName: 'Dell XPS 13',
        price: 25000000,
        quantity: 2,
      );

      const item2 = CartItemModel(
        id: 'cart-2',
        productId: 'prod-2',
        productName: 'Chuột không dây Logitech',
        price: 500000,
        quantity: 1,
      );

      expect(item1.subtotal, 50000000);
      expect(item2.subtotal, 500000);

      const cart = CartModel(
        id: 'cart-main',
        items: [item1, item2],
      );

      expect(cart.items.length, 2);
      expect(cart.totalQuantity, 3);
      expect(cart.totalPrice, 50500000);
      expect(cart.isEmpty, isFalse);
    });

    test('parses cart from JSON correctly', () {
      final json = {
        'id': 'cart-999',
        'items': [
          {
            'id': 'item-1',
            'productId': 'prod-1',
            'productName': 'Bàn phím cơ',
            'price': 1200000,
            'quantity': 2,
          }
        ]
      };

      final cart = CartModel.fromJson(json);

      expect(cart.id, 'cart-999');
      expect(cart.items.length, 1);
      expect(cart.items.first.productName, 'Bàn phím cơ');
      expect(cart.totalPrice, 2400000);
    });
  });
}

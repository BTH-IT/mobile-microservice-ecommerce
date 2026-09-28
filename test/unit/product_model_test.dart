import 'package:flutter_test/flutter_test.dart';
import 'package:ecommerce_mobile/features/product/data/models/product_model.dart';

void main() {
  group('ProductModel JSON Deserialization', () {
    test('parses standard product response from backend gateway', () {
      final json = {
        'id': 'prod-123',
        'name': 'Laptop Dell Inspiron 15 3530',
        'description': 'Laptop Dell hoc tap van phong',
        'originPrice': 16990000,
        'salePercent': 10,
        'soldNum': 9,
        'images': [
          'https://zmfkjgvvpbwjtxzmdjxd.supabase.co/storage/v1/object/public/ecommerce/seed/products/dell-inspiron-15-3530.jpg'
        ],
        'isActive': true,
        'brandId': '5de85db5-8f85-4e55-85ca-323d212f7b04',
        'brandName': 'Dell',
        'availableQuantity': 21,
        'reservedQuantity': 0,
      };

      final product = ProductModel.fromJson(json);

      expect(product.id, 'prod-123');
      expect(product.name, 'Laptop Dell Inspiron 15 3530');
      expect(product.originalPrice, 16990000);
      expect(product.price, 16990000 * 0.9);
      expect(product.brandName, 'Dell');
      expect(product.hasDiscount, true);
      expect(product.discountPercent, 10);
      expect(product.inStock, true);
      expect(product.images.first, contains('dell-inspiron-15-3530'));
    });

    test('handles zero discount correctly', () {
      final json = {
        'id': 'prod-456',
        'name': 'Lenovo IdeaPad Slim 3',
        'originPrice': 18000000,
        'salePercent': 0,
        'images': [],
        'isActive': true,
        'availableQuantity': 0,
      };

      final product = ProductModel.fromJson(json);

      expect(product.hasDiscount, false);
      expect(product.price, 18000000);
      expect(product.inStock, false);
    });

    test('parses category model correctly', () {
      final json = {
        'id': 'cat-1',
        'name': 'Laptop',
        'slug': 'laptop',
        'image': 'https://example.com/laptop.png',
      };

      final category = CategoryModel.fromJson(json);

      expect(category.id, 'cat-1');
      expect(category.name, 'Laptop');
      expect(category.slug, 'laptop');
      expect(category.image, 'https://example.com/laptop.png');
    });
  });
}

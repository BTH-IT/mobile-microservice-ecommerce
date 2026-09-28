import 'package:ecommerce_mobile/features/product/data/models/product_model.dart';

class CartItemModel {
  final String id;
  final String productId;
  final String productName;
  final String? productSlug;
  final String? thumbnail;
  final String? variantId;
  final String? variantName;
  final num price;
  final int quantity;

  const CartItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    this.productSlug,
    this.thumbnail,
    this.variantId,
    this.variantName,
    required this.price,
    required this.quantity,
  });

  num get subtotal => price * quantity;

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    // Flatten product details if nested
    String pName = json['name']?.toString() ?? json['productName']?.toString() ?? '';
    String? pSlug = json['slug']?.toString();
    String? thumb = json['thumbnail']?.toString() ?? json['image']?.toString();
    num price = json['price'] as num? ?? 0;

    if (json['product'] is Map) {
      final p = json['product'] as Map;
      pName = p['name']?.toString() ?? pName;
      pSlug = p['slug']?.toString() ?? pSlug;

      if (p['images'] is List && (p['images'] as List).isNotEmpty) {
        thumb = (p['images'] as List).first.toString();
      } else {
        thumb = p['thumbnail']?.toString() ?? thumb;
      }

      if (price == 0) {
        final origPrice = p['originPrice'] as num? ?? p['price'] as num?;
        final salePercent = p['salePercent'] as num? ?? 0;
        if (origPrice != null) {
          if (salePercent > 0) {
            price = origPrice * (100 - salePercent) / 100;
          } else {
            price = origPrice;
          }
        }
      }
    }

    thumb = ProductModel.resolveImageUrl(thumb, fallbackQuery: pName);

    return CartItemModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      productId: json['productId']?.toString() ?? (json['product'] is Map ? json['product']['id']?.toString() ?? '' : ''),
      productName: pName,
      productSlug: pSlug,
      thumbnail: thumb,
      variantId: json['variantId']?.toString(),
      variantName: json['variantName']?.toString(),
      price: price,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
    );
  }
}

class CartModel {
  final String? id;
  final List<CartItemModel> items;

  const CartModel({
    this.id,
    this.items = const [],
  });

  int get totalQuantity => items.fold(0, (sum, item) => sum + item.quantity);
  num get totalPrice => items.fold(0, (sum, item) => sum + item.subtotal);
  bool get isEmpty => items.isEmpty;

  factory CartModel.fromJson(Map<String, dynamic> json) {
    List<CartItemModel> parsedItems = [];
    final rawItems = json['items'] ?? json['cartItems'] ?? [];
    if (rawItems is List) {
      parsedItems = rawItems
          .map((i) => CartItemModel.fromJson(i as Map<String, dynamic>))
          .toList();
    }

    return CartModel(
      id: json['id']?.toString() ?? json['_id']?.toString(),
      items: parsedItems,
    );
  }
}

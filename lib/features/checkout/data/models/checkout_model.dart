class CheckoutSessionModel {
  final String id;
  final String? userId;
  final List<CheckoutItemModel> items;
  final num subtotal;
  final num shippingFee;
  final num discount;
  final num total;
  final String? paymentMethod;
  final String? paymentUrl;
  final String? status;

  const CheckoutSessionModel({
    required this.id,
    this.userId,
    this.items = const [],
    this.subtotal = 0,
    this.shippingFee = 0,
    this.discount = 0,
    required this.total,
    this.paymentMethod,
    this.paymentUrl,
    this.status,
  });

  factory CheckoutSessionModel.fromJson(Map<String, dynamic> json) {
    List<CheckoutItemModel> parsedItems = [];
    if (json['items'] is List) {
      parsedItems = (json['items'] as List)
          .map((i) => CheckoutItemModel.fromJson(i as Map<String, dynamic>))
          .toList();
    }

    return CheckoutSessionModel(
      id: json['sessionId']?.toString() ?? json['id']?.toString() ?? json['_id']?.toString() ?? '',
      userId: json['userId']?.toString(),
      items: parsedItems,
      subtotal: json['subtotal'] as num? ?? 0,
      shippingFee: json['shippingFee'] as num? ?? 0,
      discount: json['discount'] as num? ?? 0,
      total: json['total'] as num? ?? json['totalPrice'] as num? ?? json['totalAmount'] as num? ?? 0,
      paymentMethod: json['paymentMethod']?.toString(),
      paymentUrl: json['paymentUrl']?.toString() ?? json['url']?.toString(),
      status: json['status']?.toString(),
    );
  }
}

class CheckoutItemModel {
  final String productId;
  final String name;
  final String? thumbnail;
  final String? variantId;
  final String? variantName;
  final num price;
  final int quantity;

  const CheckoutItemModel({
    required this.productId,
    required this.name,
    this.thumbnail,
    this.variantId,
    this.variantName,
    required this.price,
    required this.quantity,
  });

  num get subtotal => price * quantity;

  factory CheckoutItemModel.fromJson(Map<String, dynamic> json) {
    return CheckoutItemModel(
      productId: json['productId']?.toString() ?? '',
      name: json['name']?.toString() ?? json['productName']?.toString() ?? '',
      thumbnail: json['thumbnail']?.toString() ?? json['image']?.toString(),
      variantId: json['variantId']?.toString(),
      variantName: json['variantName']?.toString(),
      price: json['price'] as num? ?? 0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
    );
  }
}

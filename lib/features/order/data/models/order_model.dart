import 'package:flutter/material.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../product/data/models/product_model.dart';

class OrderItemModel {
  final String id;
  final String productId;
  final String name;
  final String? thumbnail;
  final String? variantId;
  final String? variantName;
  final num price;
  final int quantity;

  const OrderItemModel({
    required this.id,
    required this.productId,
    required this.name,
    this.thumbnail,
    this.variantId,
    this.variantName,
    required this.price,
    required this.quantity,
  });

  num get subtotal => price * quantity;

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    String name = json['name']?.toString() ?? json['productName']?.toString() ?? '';
    String? thumb = json['thumbnail']?.toString() ?? json['image']?.toString();
    num price = json['price'] as num? ?? json['unitPrice'] as num? ?? 0;

    if (json['product'] is Map) {
      final p = json['product'] as Map;
      name = p['name']?.toString() ?? name;
      thumb = p['image']?.toString() ?? p['thumbnail']?.toString() ?? thumb;
      if (price == 0) {
        price = p['unitPrice'] as num? ?? p['price'] as num? ?? price;
      }
    }

    thumb = ProductModel.resolveImageUrl(thumb, fallbackQuery: name);

    return OrderItemModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      productId: json['productId']?.toString() ?? '',
      name: name.isNotEmpty ? name : 'Sản phẩm',
      thumbnail: thumb,
      variantId: json['variantId']?.toString(),
      variantName: json['variantName']?.toString(),
      price: price,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
    );
  }
}

class OrderStatusHistoryModel {
  final String status;
  final String? note;
  final DateTime timestamp;

  const OrderStatusHistoryModel({
    required this.status,
    this.note,
    required this.timestamp,
  });

  factory OrderStatusHistoryModel.fromJson(Map<String, dynamic> json) {
    return OrderStatusHistoryModel(
      status: json['status']?.toString() ?? '',
      note: json['note']?.toString(),
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class OrderModel {
  final String id;
  final String? orderNumber;
  final List<OrderItemModel> items;
  final num subtotal;
  final num shippingFee;
  final num discount;
  final num totalAmount;
  final String status;
  final String paymentStatus;
  final String paymentMethod;
  final String? stripePaymentUrl;
  final String? orderPdfUrl;
  final String? shippingAddress;
  final String? customerName;
  final String? customerPhone;
  final DateTime createdAt;
  final List<OrderStatusHistoryModel> statusHistory;

  const OrderModel({
    required this.id,
    this.orderNumber,
    this.items = const [],
    this.subtotal = 0,
    this.shippingFee = 0,
    this.discount = 0,
    required this.totalAmount,
    required this.status,
    this.paymentStatus = 'PENDING',
    this.paymentMethod = 'COD',
    this.stripePaymentUrl,
    this.orderPdfUrl,
    this.shippingAddress,
    this.customerName,
    this.customerPhone,
    required this.createdAt,
    this.statusHistory = const [],
  });

  String get displayOrderNumber => orderNumber ?? id.substring(0, id.length > 8 ? 8 : id.length).toUpperCase();

  String get statusVietnamese {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 'Chờ xử lý';
      case 'CONFIRMED':
        return 'Đã xác nhận';
      case 'PROCESSING':
        return 'Đang đóng gói';
      case 'SHIPPED':
      case 'SHIPPING':
        return 'Đang giao hàng';
      case 'DELIVERED':
      case 'COMPLETED':
      case 'DONE':
        return 'Giao thành công';
      case 'CANCELLED':
        return 'Đã hủy';
      case 'REFUNDED':
        return 'Đã hoàn tiền';
      default:
        return status;
    }
  }

  Color get statusColor {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return AppColors.warning;
      case 'CONFIRMED':
      case 'PROCESSING':
        return const Color(0xFF3B82F6);
      case 'SHIPPED':
      case 'SHIPPING':
        return const Color(0xFF8B5CF6);
      case 'DELIVERED':
      case 'COMPLETED':
      case 'DONE':
        return AppColors.success;
      case 'CANCELLED':
      case 'REFUNDED':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  int get statusStepIndex {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 0;
      case 'CONFIRMED':
      case 'PROCESSING':
        return 1;
      case 'SHIPPED':
      case 'SHIPPING':
        return 2;
      case 'DELIVERED':
      case 'COMPLETED':
      case 'DONE':
        return 3;
      default:
        return -1;
    }
  }

  String get paymentStatusVietnamese {
    switch (paymentStatus.toUpperCase()) {
      case 'PAID':
        return 'Đã thanh toán';
      case 'PENDING':
        return 'Chờ thanh toán';
      case 'EXPIRED':
        return 'Hết hạn';
      case 'REFUNDED':
        return 'Đã hoàn tiền';
      default:
        return paymentStatus;
    }
  }

  Color get paymentStatusColor {
    switch (paymentStatus.toUpperCase()) {
      case 'PAID':
        return AppColors.success;
      case 'PENDING':
        return AppColors.warning;
      case 'EXPIRED':
      case 'REFUNDED':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  bool get isStripe => paymentMethod.toUpperCase() == 'STRIPE';

  bool get canPayStripe =>
      isStripe &&
      paymentStatus.toUpperCase() == 'PENDING' &&
      stripePaymentUrl != null &&
      stripePaymentUrl!.isNotEmpty &&
      status.toUpperCase() != 'CANCELLED';

  bool get canCancel => status.toUpperCase() == 'PENDING' || status.toUpperCase() == 'CONFIRMED';

  bool get canConfirmReceived => status.toUpperCase() == 'SHIPPING' || status.toUpperCase() == 'SHIPPED';

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    List<OrderItemModel> parsedItems = [];
    if (json['items'] is List) {
      parsedItems = (json['items'] as List)
          .map((i) => OrderItemModel.fromJson(i as Map<String, dynamic>))
          .toList();
    }

    List<OrderStatusHistoryModel> parsedHistory = [];
    if (json['statusHistory'] is List) {
      parsedHistory = (json['statusHistory'] as List)
          .map((h) => OrderStatusHistoryModel.fromJson(h as Map<String, dynamic>))
          .toList();
    }

    final total = json['totalPrice'] as num? ?? json['totalAmount'] as num? ?? json['total'] as num? ?? 0;
    final subtotal = json['subtotal'] as num? ?? total;

    String? address = json['shippingAddress']?.toString();
    if (address == null || address.isEmpty || address == 'null') {
      final parts = [
        json['shippingStreetAddress'],
        json['shippingWardName'],
        json['shippingDistrictName'],
        json['shippingProvinceName'],
      ].where((s) => s != null && s.toString().isNotEmpty && s != 'null').map((s) => s.toString()).toList();
      if (parts.isNotEmpty) {
        address = parts.join(', ');
      }
    }

    final paymentUrl = json['stripePaymentUrl']?.toString() ??
        json['paymentUrl']?.toString() ??
        (json['payment'] is Map ? json['payment']['url']?.toString() : null);

    final pdfUrl = json['orderPdfUrl']?.toString() ??
        json['pdfUrl']?.toString() ??
        json['invoiceUrl']?.toString();

    return OrderModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      orderNumber: json['orderNumber']?.toString(),
      items: parsedItems,
      subtotal: subtotal,
      shippingFee: json['shippingFee'] as num? ?? 0,
      discount: json['discount'] as num? ?? 0,
      totalAmount: total,
      status: json['status']?.toString() ?? 'PENDING',
      paymentStatus: json['paymentStatus']?.toString() ?? 'PENDING',
      paymentMethod: json['paymentMethod']?.toString() ?? (paymentUrl != null ? 'STRIPE' : 'COD'),
      stripePaymentUrl: paymentUrl,
      orderPdfUrl: pdfUrl,
      shippingAddress: address,
      customerName: json['customerName']?.toString() ?? json['recipientName']?.toString() ?? json['shippingFullname']?.toString(),
      customerPhone: json['customerPhone']?.toString() ?? json['phone']?.toString() ?? json['shippingPhone']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      statusHistory: parsedHistory,
    );
  }
}

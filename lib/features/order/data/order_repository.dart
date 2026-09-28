import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/providers/core_providers.dart';
import 'models/order_model.dart';

class OrderRepository {
  final ApiClient _apiClient;

  OrderRepository(this._apiClient);

  Future<PaginatedResponse<OrderModel>> getOrders({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'limit': limit,
      'pageSize': limit,
      if (status != null && status.isNotEmpty && status != 'ALL') 'status': status,
    };

    final response = await _apiClient.get(
      ApiEndpoints.orders,
      queryParameters: query,
    );

    if (response is Map<String, dynamic>) {
      return PaginatedResponse.fromJson(
        response,
        (item) => OrderModel.fromJson(item as Map<String, dynamic>),
      );
    }

    if (response is List) {
      final items = response
          .map((item) => OrderModel.fromJson(item as Map<String, dynamic>))
          .toList();
      return PaginatedResponse(
        items: items,
        total: items.length,
        page: page,
        limit: limit,
        totalPages: 1,
      );
    }

    return PaginatedResponse(items: [], total: 0, page: page, limit: limit, totalPages: 0);
  }

  Future<OrderModel> getOrderById(String orderId) async {
    final response = await _apiClient.get(ApiEndpoints.orderDetail(orderId));
    if (response is Map<String, dynamic>) {
      return OrderModel.fromJson(response);
    }
    throw Exception('Không tìm thấy đơn hàng #$orderId');
  }

  Future<void> cancelOrder(String orderId, [String reason = 'Khách hàng yêu cầu hủy qua mobile']) async {
    try {
      await _apiClient.delete('/orders/$orderId');
    } catch (_) {
      await _apiClient.patch('/orders/$orderId/status', data: {'status': 'CANCELLED'});
    }
  }

  Future<void> completeOrder(String orderId) async {
    await _apiClient.patch('/orders/$orderId/complete');
  }

  Future<Map<String, dynamic>> getPaymentStatus(String orderId) async {
    final res = await _apiClient.get('/orders/$orderId/payment-status');
    if (res is Map<String, dynamic>) return res;
    return {};
  }
}

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return OrderRepository(apiClient);
});

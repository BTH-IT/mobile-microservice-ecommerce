import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/providers/core_providers.dart';
import 'models/checkout_model.dart';

class ConfirmCheckoutResult {
  final String? orderId;
  final String? paymentUrl;

  const ConfirmCheckoutResult({this.orderId, this.paymentUrl});
}

class CheckoutRepository {
  final ApiClient _apiClient;

  CheckoutRepository(this._apiClient);

  Future<CheckoutSessionModel> createSession({
    required List<Map<String, dynamic>> items,
    String? shippingAddressId,
    String paymentMethod = 'COD',
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.checkoutSessions,
      data: {
        'items': items,
      },
    );

    if (response is Map<String, dynamic>) {
      return CheckoutSessionModel.fromJson(response);
    }
    throw Exception('Không thể tạo phiên thanh toán');
  }

  Future<CheckoutSessionModel> getSession(String sessionId) async {
    final response = await _apiClient.get(ApiEndpoints.checkoutSession(sessionId));
    if (response is Map<String, dynamic>) {
      return CheckoutSessionModel.fromJson(response);
    }
    throw Exception('Không tìm thấy phiên thanh toán');
  }

  Future<ConfirmCheckoutResult> confirmSession({
    required String sessionId,
    required String recipientName,
    required String phone,
    required String addressDetail,
    required String province,
    required String district,
    required String ward,
    String? note,
  }) async {
    final shippingAddressString = '$addressDetail, $ward, $district, $province';

    final response = await _apiClient.post(
      ApiEndpoints.confirmCheckout(sessionId),
      data: {
        'shippingFullname': recipientName,
        'shippingPhone': phone,
        'shippingAddress': shippingAddressString,
        'shippingProvinceName': province,
        'shippingDistrictName': district,
        'shippingWardName': ward,
        'shippingStreetAddress': addressDetail,
        if (note != null && note.isNotEmpty) 'shippingNote': note,
      },
    );

    if (response is Map<String, dynamic>) {
      return ConfirmCheckoutResult(
        orderId: response['orderId']?.toString() ?? response['id']?.toString(),
        paymentUrl: response['paymentUrl']?.toString() ?? response['url']?.toString(),
      );
    }

    return const ConfirmCheckoutResult();
  }
}

final checkoutRepositoryProvider = Provider<CheckoutRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return CheckoutRepository(apiClient);
});

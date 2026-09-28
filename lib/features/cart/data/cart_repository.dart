import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/providers/core_providers.dart';
import 'models/cart_model.dart';

class CartRepository {
  final ApiClient _apiClient;

  CartRepository(this._apiClient);

  Future<CartModel> getCart() async {
    final response = await _apiClient.get(ApiEndpoints.cart);
    if (response is Map<String, dynamic>) {
      return CartModel.fromJson(response);
    }
    return const CartModel();
  }

  Future<CartModel> addItem({
    required String productId,
    String? variantId,
    int quantity = 1,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.cartItems,
      data: {
        'productId': productId,
        if (variantId != null && variantId.isNotEmpty) 'variantId': variantId,
        'quantity': quantity,
      },
    );

    if (response is Map<String, dynamic>) {
      return CartModel.fromJson(response);
    }
    return await getCart();
  }

  Future<CartModel> updateItemQuantity({
    required String itemId,
    required int delta,
  }) async {
    final response = await _apiClient.patch(
      ApiEndpoints.cartItem(itemId),
      data: {'delta': delta},
    );

    if (response is Map<String, dynamic>) {
      return CartModel.fromJson(response);
    }
    return await getCart();
  }

  Future<CartModel> removeItem(String itemId) async {
    final response = await _apiClient.delete(ApiEndpoints.cartItem(itemId));
    if (response is Map<String, dynamic>) {
      return CartModel.fromJson(response);
    }
    return await getCart();
  }

  Future<void> clearCart() async {
    await _apiClient.delete(ApiEndpoints.cart);
  }
}

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return CartRepository(apiClient);
});

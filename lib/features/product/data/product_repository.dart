import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ecommerce_mobile/core/constants/api_endpoints.dart';
import 'package:ecommerce_mobile/core/network/api_client.dart';
import 'package:ecommerce_mobile/core/network/api_response.dart';
import 'package:ecommerce_mobile/core/providers/core_providers.dart';
import 'models/product_model.dart';

class ProductRepository {
  final ApiClient _apiClient;

  ProductRepository(this._apiClient);

  Future<PaginatedResponse<ProductModel>> getProducts({
    int page = 1,
    int limit = 10,
    String? search,
    String? categoryId,
    String? brandId,
    String? sortBy,
    String? sortOrder,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (search != null && search.isNotEmpty) 'search': search,
      if (categoryId != null && categoryId.isNotEmpty) 'category': categoryId,
      if (brandId != null && brandId.isNotEmpty) 'brand': brandId,
      'sortBy': ?sortBy,
      'sortOrder': ?sortOrder,
    };

    final response = await _apiClient.get(
      ApiEndpoints.products,
      queryParameters: query,
    );

    if (response is Map<String, dynamic>) {
      return PaginatedResponse.fromJson(
        response,
        (item) => ProductModel.fromJson(item as Map<String, dynamic>),
      );
    }

    if (response is List) {
      final items = response
          .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
          .toList();
      return PaginatedResponse(
        items: items,
        total: items.length,
        page: page,
        limit: limit,
        totalPages: 1,
      );
    }

    return const PaginatedResponse(items: [], total: 0, page: 1, limit: 10, totalPages: 0);
  }

  Future<ProductModel> getProductById(String id) async {
    final response = await _apiClient.get(ApiEndpoints.productDetail(id));
    if (response is Map<String, dynamic>) {
      return ProductModel.fromJson(response);
    }
    throw Exception('Không tìm thấy thông tin sản phẩm');
  }

  Future<ProductModel> getProductBySlug(String slug) async {
    final response = await _apiClient.get(ApiEndpoints.productBySlug(slug));
    if (response is Map<String, dynamic>) {
      return ProductModel.fromJson(response);
    }
    throw Exception('Không tìm thấy sản phẩm với đường dẫn này');
  }

  Future<List<CategoryModel>> getCategories() async {
    final response = await _apiClient.get(ApiEndpoints.brands);
    if (response is List) {
      return response
          .map((c) => CategoryModel.fromJson(c as Map<String, dynamic>))
          .toList();
    } else if (response is Map<String, dynamic> && response['data'] is List) {
      return (response['data'] as List)
          .map((c) => CategoryModel.fromJson(c as Map<String, dynamic>))
          .toList();
    } else if (response is Map<String, dynamic> && response['items'] is List) {
      return (response['items'] as List)
          .map((c) => CategoryModel.fromJson(c as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ProductRepository(apiClient);
});

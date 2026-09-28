import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/providers/core_providers.dart';
import 'models/address_model.dart';

class AddressRepository {
  final ApiClient _apiClient;

  AddressRepository(this._apiClient);

  Future<List<AddressModel>> getAddresses() async {
    final response = await _apiClient.get(ApiEndpoints.userAddresses);
    if (response is List) {
      return response
          .map((a) => AddressModel.fromJson(a as Map<String, dynamic>))
          .toList();
    } else if (response is Map<String, dynamic> && response['items'] is List) {
      return (response['items'] as List)
          .map((a) => AddressModel.fromJson(a as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<AddressModel> addAddress(AddressModel address) async {
    final response = await _apiClient.post(
      ApiEndpoints.userAddresses,
      data: address.toJson(),
    );
    if (response is Map<String, dynamic>) {
      return AddressModel.fromJson(response);
    }
    throw Exception('Không thể lưu địa chỉ');
  }

  Future<AddressModel> updateAddress(String id, AddressModel address) async {
    final response = await _apiClient.patch(
      ApiEndpoints.userAddress(id),
      data: address.toJson(),
    );
    if (response is Map<String, dynamic>) {
      return AddressModel.fromJson(response);
    }
    throw Exception('Không thể cập nhật địa chỉ');
  }

  Future<void> deleteAddress(String id) async {
    await _apiClient.delete(ApiEndpoints.userAddress(id));
  }

  Future<void> setDefaultAddress(String id) async {
    await _apiClient.patch(ApiEndpoints.setDefaultAddress(id));
  }

  Future<List<AdministrativeUnitModel>> getProvinces() async {
    final response = await _apiClient.get(ApiEndpoints.provinces);
    if (response is List) {
      return response
          .map((p) => AdministrativeUnitModel.fromJson(p as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<List<AdministrativeUnitModel>> getDistricts(String provinceCode) async {
    final response = await _apiClient.get(ApiEndpoints.districts(provinceCode));
    if (response is List) {
      return response
          .map((d) => AdministrativeUnitModel.fromJson(d as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<List<AdministrativeUnitModel>> getWards(String districtCode) async {
    final response = await _apiClient.get(ApiEndpoints.wards(districtCode));
    if (response is List) {
      return response
          .map((w) => AdministrativeUnitModel.fromJson(w as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}

final addressRepositoryProvider = Provider<AddressRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AddressRepository(apiClient);
});

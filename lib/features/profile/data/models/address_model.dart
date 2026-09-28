class AddressModel {
  final String id;
  final String recipientName;
  final String phone;
  final String province;
  final String? provinceCode;
  final String district;
  final String? districtCode;
  final String ward;
  final String? wardCode;
  final String detail;
  final bool isDefault;

  const AddressModel({
    required this.id,
    required this.recipientName,
    required this.phone,
    required this.province,
    this.provinceCode,
    required this.district,
    this.districtCode,
    required this.ward,
    this.wardCode,
    required this.detail,
    this.isDefault = false,
  });

  String get fullAddress {
    return [detail, ward, district, province]
        .where((s) => s.trim().isNotEmpty)
        .join(', ');
  }

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      recipientName: json['fullname']?.toString() ?? json['recipientName']?.toString() ?? json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      province: json['provinceName']?.toString() ?? json['province']?.toString() ?? '',
      provinceCode: json['provinceCode']?.toString(),
      district: json['districtName']?.toString() ?? json['district']?.toString() ?? '',
      districtCode: json['districtCode']?.toString(),
      ward: json['wardName']?.toString() ?? json['ward']?.toString() ?? '',
      wardCode: json['wardCode']?.toString(),
      detail: json['streetAddress']?.toString() ?? json['detail']?.toString() ?? json['street']?.toString() ?? '',
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullname': recipientName,
      'phone': phone,
      'provinceName': province,
      'provinceCode': provinceCode ?? '01',
      'wardName': ward,
      'wardCode': wardCode ?? '001',
      'streetAddress': detail,
      'isDefault': isDefault,
    };
  }
}

class AdministrativeUnitModel {
  final String code;
  final String name;

  const AdministrativeUnitModel({required this.code, required this.name});

  factory AdministrativeUnitModel.fromJson(Map<String, dynamic> json) {
    return AdministrativeUnitModel(
      code: json['code']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }
}

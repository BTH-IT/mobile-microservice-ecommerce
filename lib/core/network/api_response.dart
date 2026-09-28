class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final String? timestamp;

  const ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.timestamp,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json) fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] as bool? ?? true,
      message: json['message'] as String?,
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      timestamp: json['timestamp'] as String?,
    );
  }
}

class PaginatedResponse<T> {
  final List<T> items;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const PaginatedResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic itemJson) fromJsonT,
  ) {
    final rawItems = json['items'] ?? json['data'] ?? [];
    final itemsList = (rawItems as List).map((i) => fromJsonT(i)).toList();

    final total = json['total'] as int? ?? itemsList.length;
    final page = json['page'] as int? ?? 1;
    final limit = json['limit'] as int? ?? (itemsList.isEmpty ? 10 : itemsList.length);
    final totalPages = json['totalPages'] as int? ?? ((total + limit - 1) ~/ (limit > 0 ? limit : 1));

    return PaginatedResponse<T>(
      items: itemsList,
      total: total,
      page: page,
      limit: limit,
      totalPages: totalPages,
    );
  }

  bool get hasMore => page < totalPages;
}

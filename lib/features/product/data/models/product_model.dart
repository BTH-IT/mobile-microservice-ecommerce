class ProductModel {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final num price;
  final num? originalPrice;
  final String? thumbnail;
  final List<String> images;
  final String? categoryId;
  final String? categoryName;
  final String? brandId;
  final String? brandName;
  final int stock;
  final double rating;
  final int reviewCount;
  final List<ProductVariantModel> variants;

  const ProductModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    required this.price,
    this.originalPrice,
    this.thumbnail,
    this.images = const [],
    this.categoryId,
    this.categoryName,
    this.brandId,
    this.brandName,
    this.stock = 0,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.variants = const [],
  });

  bool get inStock => stock > 0;
  bool get hasDiscount => originalPrice != null && originalPrice! > price;
  int get discountPercent => hasDiscount ? (((originalPrice! - price) / originalPrice!) * 100).round() : 0;

  static String resolveImageUrl(String? url, {String? fallbackQuery}) {
    if (url == null || url.isEmpty || url.contains('zmfkjgvvpbwjtxzmdjxd.supabase.co')) {
      final query = (fallbackQuery ?? 'laptop').toLowerCase();
      if (query.contains('macbook') || query.contains('apple')) {
        return 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=800&auto=format&fit=crop';
      } else if (query.contains('hp') || query.contains('pavilion')) {
        return 'https://images.unsplash.com/photo-1525547719571-a2d4ac8945e2?w=800&auto=format&fit=crop';
      } else if (query.contains('dell') || query.contains('inspiron')) {
        return 'https://images.unsplash.com/photo-1593642632823-8f785ba67e45?w=800&auto=format&fit=crop';
      } else if (query.contains('lenovo') || query.contains('ideapad') || query.contains('thinkpad')) {
        return 'https://images.unsplash.com/photo-1603302576837-37561b2e2302?w=800&auto=format&fit=crop';
      } else if (query.contains('asus') || query.contains('vivobook') || query.contains('zenbook')) {
        return 'https://images.unsplash.com/photo-1588872657578-7efd1f1555ed?w=800&auto=format&fit=crop';
      } else if (query.contains('acer') || query.contains('aspire')) {
        return 'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=800&auto=format&fit=crop';
      } else if (query.contains('msi') || query.contains('gaming')) {
        return 'https://images.unsplash.com/photo-1542751371-adc38448a05e?w=800&auto=format&fit=crop';
      }
      return 'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=800&auto=format&fit=crop';
    }
    return url;
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final productName = json['name']?.toString() ?? '';

    // Extract thumbnail and images
    List<String> parsedImages = [];
    if (json['images'] is List) {
      parsedImages = (json['images'] as List).map((e) {
        final raw = e is Map ? (e['url']?.toString() ?? '') : e.toString();
        return resolveImageUrl(raw, fallbackQuery: productName);
      }).where((s) => s.isNotEmpty).toList();
    }

    String? thumb = json['thumbnail']?.toString();
    if (thumb == null || thumb.isEmpty || thumb.contains('zmfkjgvvpbwjtxzmdjxd.supabase.co')) {
      if (parsedImages.isNotEmpty) {
        thumb = parsedImages.first;
      } else {
        thumb = resolveImageUrl(thumb, fallbackQuery: productName);
      }
    }

    // Extract variants
    List<ProductVariantModel> parsedVariants = [];
    if (json['variants'] is List) {
      parsedVariants = (json['variants'] as List)
          .map((v) => ProductVariantModel.fromJson(v as Map<String, dynamic>))
          .toList();
    }

    // Handle nested category/brand
    String? catName;
    String? catId;
    if (json['category'] is Map) {
      catId = json['category']['id']?.toString() ?? json['category']['_id']?.toString();
      catName = json['category']['name']?.toString();
    } else if (json['categoryId'] != null) {
      catId = json['categoryId']?.toString();
    }

    String? brName;
    String? brId;
    if (json['brand'] is Map) {
      brId = json['brand']['id']?.toString() ?? json['brand']['_id']?.toString();
      brName = json['brand']['name']?.toString();
    } else if (json['brandId'] != null) {
      brId = json['brandId']?.toString();
    }
    if (brName == null && json['brandName'] != null) {
      brName = json['brandName'].toString();
    }

    final origPrice = json['originPrice'] as num? ?? json['originalPrice'] as num? ?? json['comparePrice'] as num?;
    final salePercent = json['salePercent'] as num? ?? 0;
    num price = json['price'] as num? ?? 0;
    num? finalOriginalPrice;

    if (price == 0 && origPrice != null) {
      if (salePercent > 0) {
        price = origPrice * (100 - salePercent) / 100;
        finalOriginalPrice = origPrice;
      } else {
        price = origPrice;
      }
    } else if (origPrice != null && origPrice > price) {
      finalOriginalPrice = origPrice;
    }

    final stock = (json['stock'] as num?)?.toInt() ??
        (json['availableQuantity'] as num?)?.toInt() ??
        (json['quantity'] as num?)?.toInt() ??
        0;

    return ProductModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      description: json['description']?.toString(),
      price: price,
      originalPrice: finalOriginalPrice,
      thumbnail: thumb,
      images: parsedImages,
      categoryId: catId,
      categoryName: catName,
      brandId: brId,
      brandName: brName,
      stock: stock,
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? (json['soldNum'] as num?)?.toInt() ?? 0,
      variants: parsedVariants,
    );
  }
}

class ProductVariantModel {
  final String id;
  final String name;
  final String? sku;
  final num price;
  final num? originalPrice;
  final int stock;
  final Map<String, String> attributes;

  const ProductVariantModel({
    required this.id,
    required this.name,
    this.sku,
    required this.price,
    this.originalPrice,
    this.stock = 0,
    this.attributes = const {},
  });

  factory ProductVariantModel.fromJson(Map<String, dynamic> json) {
    Map<String, String> attrs = {};
    if (json['attributes'] is Map) {
      attrs = (json['attributes'] as Map).map(
        (key, value) => MapEntry(key.toString(), value.toString()),
      );
    }

    return ProductVariantModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      sku: json['sku']?.toString(),
      price: json['price'] as num? ?? 0,
      originalPrice: json['originalPrice'] as num?,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      attributes: attrs,
    );
  }
}

class CategoryModel {
  final String id;
  final String name;
  final String slug;
  final String? image;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    this.image,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final name = json['name']?.toString() ?? '';
    String? img = json['image']?.toString() ?? json['thumbnail']?.toString() ?? json['icon']?.toString();
    if (img == null || img.isEmpty || img.contains('zmfkjgvvpbwjtxzmdjxd.supabase.co')) {
      final q = name.toLowerCase();
      if (q.contains('apple')) {
        img = 'https://images.unsplash.com/photo-1611186871348-b1ce696e52c9?w=300&auto=format&fit=crop';
      } else if (q.contains('asus')) {
        img = 'https://images.unsplash.com/photo-1588872657578-7efd1f1555ed?w=300&auto=format&fit=crop';
      } else if (q.contains('dell')) {
        img = 'https://images.unsplash.com/photo-1593642632823-8f785ba67e45?w=300&auto=format&fit=crop';
      } else if (q.contains('hp')) {
        img = 'https://images.unsplash.com/photo-1525547719571-a2d4ac8945e2?w=300&auto=format&fit=crop';
      } else if (q.contains('lenovo')) {
        img = 'https://images.unsplash.com/photo-1603302576837-37561b2e2302?w=300&auto=format&fit=crop';
      } else if (q.contains('msi')) {
        img = 'https://images.unsplash.com/photo-1542751371-adc38448a05e?w=300&auto=format&fit=crop';
      } else if (q.contains('acer')) {
        img = 'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=300&auto=format&fit=crop';
      } else {
        img = 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=300&auto=format&fit=crop';
      }
    }

    return CategoryModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: name,
      slug: json['slug']?.toString() ?? '',
      image: img,
    );
  }
}

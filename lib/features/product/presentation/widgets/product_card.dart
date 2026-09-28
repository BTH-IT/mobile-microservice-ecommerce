import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce_mobile/config/theme/app_colors.dart';
import 'package:ecommerce_mobile/config/theme/app_spacing.dart';
import 'package:ecommerce_mobile/config/theme/app_typography.dart';
import 'package:ecommerce_mobile/features/product/data/models/product_model.dart';
import 'package:ecommerce_mobile/shared/widgets/loading_indicator.dart';
import 'package:ecommerce_mobile/shared/widgets/price_tag.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail Image
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (product.thumbnail != null && product.thumbnail!.isNotEmpty)
                    CachedNetworkImage(
                      imageUrl: product.thumbnail!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const ShimmerBox(
                        width: double.infinity,
                        height: double.infinity,
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.surfaceSecondary,
                        child: const Icon(
                          Icons.image_not_supported_outlined,
                          color: AppColors.textMuted,
                          size: 32,
                        ),
                      ),
                    )
                  else
                    Container(
                      color: AppColors.surfaceSecondary,
                      child: const Icon(
                        Icons.shopping_bag_outlined,
                        color: AppColors.textMuted,
                        size: 32,
                      ),
                    ),
                  if (!product.inStock)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.4),
                        alignment: Alignment.center,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: AppRadius.roundedSm,
                          ),
                          child: Text(
                            'Hết hàng',
                            style: AppTypography.bodySmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Info Section
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product.brandName != null || product.categoryName != null)
                    Text(
                      product.brandName ?? product.categoryName ?? '',
                      style: AppTypography.bodySmall.copyWith(fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 2),
                  Text(
                    product.name,
                    style: AppTypography.label.copyWith(fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  PriceTag(
                    price: product.price,
                    originalPrice: product.originalPrice,
                    priceStyle: AppTypography.price.copyWith(fontSize: 15),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

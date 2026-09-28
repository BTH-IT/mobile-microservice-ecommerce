import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ecommerce_mobile/config/theme/app_colors.dart';
import 'package:ecommerce_mobile/config/theme/app_spacing.dart';
import 'package:ecommerce_mobile/config/theme/app_typography.dart';
import 'package:ecommerce_mobile/features/auth/presentation/auth_controller.dart';
import 'package:ecommerce_mobile/features/cart/presentation/cart_controller.dart';
import 'package:ecommerce_mobile/features/product/data/models/product_model.dart';
import 'package:ecommerce_mobile/features/product/data/product_repository.dart';
import 'package:ecommerce_mobile/routing/app_routes.dart';
import 'package:ecommerce_mobile/shared/widgets/app_button.dart';
import 'package:ecommerce_mobile/shared/widgets/empty_view.dart';
import 'package:ecommerce_mobile/shared/widgets/loading_indicator.dart';
import 'package:ecommerce_mobile/shared/widgets/price_tag.dart';
import 'package:ecommerce_mobile/shared/dialogs/app_toast.dart';

final productDetailProvider = FutureProvider.family<ProductModel, String>((ref, id) async {
  final repo = ref.watch(productRepositoryProvider);
  return await repo.getProductById(id);
});

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _selectedImageIndex = 0;
  String? _selectedVariantId;
  int _quantity = 1;

  void _showLoginRequiredModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline, size: 48, color: AppColors.primary),
                const SizedBox(height: AppSpacing.md),
                Text('Yêu cầu đăng nhập', style: AppTypography.h3),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Vui lòng đăng nhập để thêm sản phẩm vào giỏ hàng và thanh toán.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.xl),
                AppButton(
                  text: 'Đăng nhập ngay',
                  onPressed: () {
                    Navigator.pop(ctx);
                    context.push(AppRoutes.login);
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Để sau'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleAddToCart(ProductModel product) async {
    final authState = ref.read(authProvider);
    if (!authState.isAuthenticated) {
      _showLoginRequiredModal();
      return;
    }

    final success = await ref.read(cartProvider.notifier).addToCart(
          productId: product.id,
          variantId: _selectedVariantId,
          quantity: _quantity,
        );

    if (mounted) {
      if (success) {
        AppToast.success('Đã thêm sản phẩm vào giỏ hàng!', context: context);
      } else {
        final err = ref.read(cartProvider).errorMessage ?? 'Không thể thêm vào giỏ hàng';
        AppToast.error(err, context: context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productDetailProvider(widget.productId));
    final cartState = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi Tiết Sản Phẩm'),
        actions: [
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.shopping_bag_outlined),
                if (cartState.itemCount > 0)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        '${cartState.itemCount}',
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () => context.go(AppRoutes.cart),
          ),
        ],
      ),
      body: productAsync.when(
        data: (ProductModel product) {
          final allImages = product.images.isNotEmpty
              ? product.images
              : (product.thumbnail != null ? [product.thumbnail!] : <String>[]);

          return Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    // Image Gallery
                    if (allImages.isNotEmpty) ...[
                      SizedBox(
                        height: 320,
                        child: PageView.builder(
                          itemCount: allImages.length,
                          onPageChanged: (index) {
                            setState(() => _selectedImageIndex = index);
                          },
                          itemBuilder: (context, index) {
                            return CachedNetworkImage(
                              imageUrl: allImages[index],
                              fit: BoxFit.contain,
                              placeholder: (_, _) => const ShimmerBox(width: double.infinity, height: 320),
                              errorWidget: (_, _, _) => const Center(
                                child: Icon(Icons.broken_image, size: 64, color: AppColors.textMuted),
                              ),
                            );
                          },
                        ),
                      ),
                      if (allImages.length > 1)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            allImages.length,
                            (index) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                              width: _selectedImageIndex == index ? 16 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _selectedImageIndex == index ? AppColors.primary : AppColors.border,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                    ],

                    Padding(
                      padding: AppSpacing.screenPadding,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Brand & Category
                          if (product.brandName != null || product.categoryName != null)
                            Text(
                              product.brandName ?? product.categoryName ?? '',
                              style: AppTypography.label.copyWith(color: AppColors.primary),
                            ),
                          const SizedBox(height: AppSpacing.xs),

                          // Product Name
                          Text(product.name, style: AppTypography.h2),
                          const SizedBox(height: AppSpacing.sm),

                          // Price Tag
                          PriceTag(
                            price: product.price,
                            originalPrice: product.originalPrice,
                            priceStyle: AppTypography.h2.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // Stock Status
                          Row(
                            children: [
                              Icon(
                                product.inStock ? Icons.check_circle : Icons.cancel,
                                size: 16,
                                color: product.inStock ? AppColors.success : AppColors.error,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                product.inStock ? 'Còn hàng (${product.stock} sản phẩm)' : 'Hết hàng',
                                style: AppTypography.bodySmall.copyWith(
                                  color: product.inStock ? AppColors.success : AppColors.error,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 32),

                          // Variants (if any)
                          if (product.variants.isNotEmpty) ...[
                            Text('Phiên bản', style: AppTypography.h3),
                            const SizedBox(height: AppSpacing.sm),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: product.variants.map((v) {
                                final isSelected = _selectedVariantId == v.id;
                                return ChoiceChip(
                                  label: Text(v.name),
                                  selected: isSelected,
                                  onSelected: (val) {
                                    setState(() {
                                      _selectedVariantId = val ? v.id : null;
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                            const Divider(height: 32),
                          ],

                          // Quantity Selector
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Số lượng', style: AppTypography.h3),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.border),
                                  borderRadius: AppRadius.roundedMd,
                                ),
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove, size: 18),
                                      onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                                    ),
                                    Text('$_quantity', style: AppTypography.label),
                                    IconButton(
                                      icon: const Icon(Icons.add, size: 18),
                                      onPressed: () => setState(() => _quantity++),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 32),

                          // Description
                          Text('Mô tả sản phẩm', style: AppTypography.h3),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            product.description ?? 'Chưa có mô tả chi tiết cho sản phẩm này.',
                            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary, height: 1.6),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          text: 'Thêm vào giỏ',
                          variant: AppButtonVariant.secondary,
                          icon: const Icon(Icons.add_shopping_cart, size: 18, color: AppColors.primary),
                          onPressed: product.inStock ? () => _handleAddToCart(product) : null,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: AppButton(
                          text: 'Mua ngay',
                          onPressed: product.inStock
                              ? () async {
                                  await _handleAddToCart(product);
                                  if (!context.mounted) return;
                                  if (ref.read(authProvider).isAuthenticated) {
                                    context.go(AppRoutes.cart);
                                  }
                                }
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const LoadingIndicator(),
        error: (err, _) => EmptyView(
          icon: Icons.error_outline,
          title: 'Không thể tải thông tin sản phẩm',
          description: err.toString(),
          buttonText: 'Thử lại',
          onButtonPressed: () => ref.invalidate(productDetailProvider(widget.productId)),
        ),
      ),
    );
  }
}

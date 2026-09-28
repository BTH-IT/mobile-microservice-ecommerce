import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ecommerce_mobile/config/theme/app_colors.dart';
import 'package:ecommerce_mobile/config/theme/app_spacing.dart';
import 'package:ecommerce_mobile/config/theme/app_typography.dart';
import 'package:ecommerce_mobile/features/cart/presentation/cart_controller.dart';
import 'package:ecommerce_mobile/features/product/data/models/product_model.dart';
import 'package:ecommerce_mobile/features/product/data/product_repository.dart';
import 'package:ecommerce_mobile/features/product/presentation/widgets/product_card.dart';
import 'package:ecommerce_mobile/routing/app_routes.dart';
import 'package:ecommerce_mobile/shared/widgets/empty_view.dart';
import 'package:ecommerce_mobile/shared/widgets/loading_indicator.dart';

final homeProductsProvider = FutureProvider<List<ProductModel>>((ref) async {
  final repo = ref.watch(productRepositoryProvider);
  final res = await repo.getProducts(limit: 8);
  return res.items;
});

final homeCategoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  final repo = ref.watch(productRepositoryProvider);
  return await repo.getCategories();
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(homeProductsProvider);
    final categoriesAsync = ref.watch(homeCategoriesProvider);
    final cartState = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: AppRadius.roundedSm,
              ),
              child: const Icon(Icons.bolt, color: Colors.white, size: 20),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'BTH Store',
              style: AppTypography.h3.copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.shopping_bag_outlined, size: 26),
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
                      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                      child: Text(
                        '${cartState.itemCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () => context.go(AppRoutes.cart),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(homeProductsProvider);
          ref.invalidate(homeCategoriesProvider);
        },
        child: ListView(
          padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
          children: [
            // Search Bar Header
            Padding(
              padding: AppSpacing.screenPadding,
              child: GestureDetector(
                onTap: () => context.push(AppRoutes.products),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSecondary,
                    borderRadius: AppRadius.roundedFull,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: AppColors.textMuted, size: 20),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Tìm kiếm sản phẩm, thương hiệu...',
                        style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Hero Banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: AppRadius.roundedXl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: AppRadius.roundedFull,
                      ),
                      child: Text(
                        'ƯU ĐÃI ĐẶC BIỆT',
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Bộ Sưu Tập Công Nghệ Mới',
                      style: AppTypography.h2.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Giảm giá lên đến 40% cho các sản phẩm hàng đầu',
                      style: AppTypography.bodyMedium.copyWith(color: Colors.white70),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedFull),
                      ),
                      onPressed: () => context.push(AppRoutes.products),
                      child: const Text('Mua ngay'),
                    ),
                  ],
                ),
              ),
            ),

            // Categories Section
            categoriesAsync.when(
              data: (categories) {
                if (categories.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                      child: Text('Danh Mục Nổi Bật', style: AppTypography.h3),
                    ),
                    SizedBox(
                      height: 44,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final cat = categories[index];
                          return ActionChip(
                            label: Text(cat.name),
                            backgroundColor: AppColors.surfaceSecondary,
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadius.roundedFull,
                              side: const BorderSide(color: AppColors.border),
                            ),
                            labelStyle: AppTypography.bodySmall.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            onPressed: () => context.push('${AppRoutes.products}?category=${cat.id}'),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
              loading: () => const SizedBox(
                height: 50,
                child: Center(child: LoadingIndicator(size: 20)),
              ),
              error: (_, _) => const SizedBox.shrink(),
            ),

            // Products Section Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 28, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Sản Phẩm Mới Nhất', style: AppTypography.h3),
                  TextButton(
                    onPressed: () => context.push(AppRoutes.products),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Xem tất cả', style: AppTypography.label.copyWith(color: AppColors.primary)),
                        const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.primary),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Products Grid
            productsAsync.when(
              data: (products) {
                if (products.isEmpty) {
                  return const EmptyView(
                    icon: Icons.inventory_2_outlined,
                    title: 'Chưa có sản phẩm',
                    description: 'Các sản phẩm mới đang được cập nhật.',
                  );
                }
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.68,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ProductCard(
                      product: product,
                      onTap: () => context.push(AppRoutes.productDetailPath(product.id)),
                    );
                  },
                );
              },
              loading: () => GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.68,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: 4,
                itemBuilder: (_, _) => const ProductCardSkeleton(),
              ),
              error: (err, _) => Padding(
                padding: const EdgeInsets.all(24),
                child: EmptyView(
                  icon: Icons.error_outline,
                  title: 'Không thể tải sản phẩm',
                  description: err.toString(),
                  buttonText: 'Thử lại',
                  onButtonPressed: () => ref.invalidate(homeProductsProvider),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

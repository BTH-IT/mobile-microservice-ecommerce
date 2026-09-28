import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ecommerce_mobile/config/theme/app_colors.dart';
import 'package:ecommerce_mobile/config/theme/app_spacing.dart';
import 'package:ecommerce_mobile/config/theme/app_typography.dart';
import 'package:ecommerce_mobile/core/utils/currency_formatter.dart';
import 'package:ecommerce_mobile/features/auth/presentation/auth_controller.dart';
import 'package:ecommerce_mobile/features/cart/presentation/cart_controller.dart';
import 'package:ecommerce_mobile/routing/app_routes.dart';
import 'package:ecommerce_mobile/shared/widgets/app_button.dart';
import 'package:ecommerce_mobile/shared/widgets/empty_view.dart';
import 'package:ecommerce_mobile/shared/widgets/loading_indicator.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final cartState = ref.watch(cartProvider);

    // If not authenticated, prompt login
    if (!authState.isAuthenticated) {
      return Scaffold(
        appBar: AppBar(title: const Text('Giỏ Hàng')),
        body: EmptyView(
          icon: Icons.lock_outline,
          title: 'Đăng nhập để xem giỏ hàng',
          description: 'Các sản phẩm bạn đã thêm sẽ được lưu an toàn trong tài khoản của bạn.',
          buttonText: 'Đăng nhập ngay',
          onButtonPressed: () => context.push(AppRoutes.login),
        ),
      );
    }

    if (cartState.isLoading && cartState.cart.items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Giỏ Hàng')),
        body: const LoadingIndicator(),
      );
    }

    if (cartState.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Giỏ Hàng')),
        body: EmptyView(
          icon: Icons.shopping_cart_outlined,
          title: 'Giỏ hàng của bạn đang trống',
          description: 'Hãy khám phá hàng ngàn sản phẩm công nghệ hấp dẫn của chúng tôi!',
          buttonText: 'Mua sắm ngay',
          onButtonPressed: () => context.go(AppRoutes.products),
        ),
      );
    }

    final items = cartState.cart.items;

    return Scaffold(
      appBar: AppBar(
        title: Text('Giỏ Hàng (${cartState.itemCount})'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Xóa toàn bộ',
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Xóa toàn bộ giỏ hàng?'),
                  content: const Text('Bạn có chắc chắn muốn xóa tất cả sản phẩm khỏi giỏ hàng không?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Hủy'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                      onPressed: () {
                        Navigator.pop(ctx);
                        ref.read(cartProvider.notifier).clearCart();
                      },
                      child: const Text('Xóa', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.read(cartProvider.notifier).loadCart(),
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Thumbnail
                          ClipRRect(
                            borderRadius: AppRadius.roundedMd,
                            child: SizedBox(
                              width: 80,
                              height: 80,
                              child: item.thumbnail != null && item.thumbnail!.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: item.thumbnail!,
                                      fit: BoxFit.cover,
                                      errorWidget: (_, _, _) => Container(
                                        color: AppColors.surfaceSecondary,
                                        child: const Icon(Icons.image_not_supported_outlined, color: AppColors.textMuted),
                                      ),
                                    )
                                  : Container(
                                      color: AppColors.surfaceSecondary,
                                      child: const Icon(Icons.shopping_bag_outlined, color: AppColors.textMuted),
                                    ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),

                          // Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.productName,
                                  style: AppTypography.label,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (item.variantName != null && item.variantName!.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    item.variantName!,
                                    style: AppTypography.bodySmall,
                                  ),
                                ],
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  CurrencyFormatter.formatVND(item.price),
                                  style: AppTypography.price.copyWith(fontSize: 15),
                                ),
                                const SizedBox(height: AppSpacing.sm),

                                // Quantity Controls
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(color: AppColors.border),
                                        borderRadius: AppRadius.roundedSm,
                                      ),
                                      child: Row(
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              if (item.quantity > 1) {
                                                ref.read(cartProvider.notifier).updateQuantityDelta(item.id, -1);
                                              } else {
                                                ref.read(cartProvider.notifier).removeItem(item.id);
                                              }
                                            },
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              child: Icon(Icons.remove, size: 16),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10),
                                            child: Text('${item.quantity}', style: AppTypography.label),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              ref.read(cartProvider.notifier).updateQuantityDelta(item.id, 1);
                                            },
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              child: Icon(Icons.add, size: 16),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: AppColors.textMuted, size: 20),
                                      onPressed: () {
                                        ref.read(cartProvider.notifier).removeItem(item.id);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Bottom Order Summary Bar
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Tổng thanh toán:', style: AppTypography.bodyMedium),
                        Text(
                          CurrencyFormatter.formatVND(cartState.cart.totalPrice),
                          style: AppTypography.h2.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppButton(
                      text: 'Tiến hành đặt hàng (${cartState.itemCount})',
                      onPressed: () => context.push(AppRoutes.checkout),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

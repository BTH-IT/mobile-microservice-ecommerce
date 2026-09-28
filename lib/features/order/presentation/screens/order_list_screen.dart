import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ecommerce_mobile/config/theme/app_colors.dart';
import 'package:ecommerce_mobile/config/theme/app_spacing.dart';
import 'package:ecommerce_mobile/config/theme/app_typography.dart';
import 'package:ecommerce_mobile/core/utils/currency_formatter.dart';
import 'package:ecommerce_mobile/core/utils/date_formatter.dart';
import 'package:ecommerce_mobile/features/auth/presentation/auth_controller.dart';
import 'package:ecommerce_mobile/features/checkout/presentation/screens/stripe_webview_screen.dart';
import 'package:ecommerce_mobile/features/order/data/models/order_model.dart';
import 'package:ecommerce_mobile/features/order/data/order_repository.dart';
import 'package:ecommerce_mobile/routing/app_routes.dart';
import 'package:ecommerce_mobile/shared/widgets/empty_view.dart';
import 'package:ecommerce_mobile/shared/widgets/loading_indicator.dart';

class OrderFilterStatusNotifier extends Notifier<String> {
  @override
  String build() => 'ALL';

  void setStatus(String status) => state = status;
}

final orderFilterStatusProvider =
    NotifierProvider<OrderFilterStatusNotifier, String>(
  OrderFilterStatusNotifier.new,
);

final ordersProvider = FutureProvider<List<OrderModel>>((ref) async {
  final status = ref.watch(orderFilterStatusProvider);
  final repo = ref.watch(orderRepositoryProvider);
  final res = await repo.getOrders(status: status, limit: 30);
  return res.items;
});

class OrderListScreen extends ConsumerWidget {
  const OrderListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    if (!authState.isAuthenticated) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text('Đơn Hàng Của Tôi'),
          elevation: 0,
          backgroundColor: Colors.white,
        ),
        body: EmptyView(
          icon: Icons.lock_outline,
          title: 'Đăng nhập để xem đơn hàng',
          description: 'Vui lòng đăng nhập tài khoản để theo dõi tình trạng đơn hàng của bạn.',
          buttonText: 'Đăng nhập ngay',
          onButtonPressed: () => context.push(AppRoutes.login),
        ),
      );
    }

    final currentStatus = ref.watch(orderFilterStatusProvider);
    final ordersAsync = ref.watch(ordersProvider);

    final statusFilters = [
      {'label': 'Tất cả', 'value': 'ALL'},
      {'label': 'Chờ xử lý', 'value': 'PENDING'},
      {'label': 'Đang giao', 'value': 'SHIPPING'},
      {'label': 'Hoàn thành', 'value': 'DONE'},
      {'label': 'Đã hủy', 'value': 'CANCELLED'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Đơn Hàng Của Tôi'),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Filter Chips Carousel
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: statusFilters.map((f) {
                  final isSelected = currentStatus == f['value'];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(f['label']!),
                      selected: isSelected,
                      selectedColor: AppColors.primaryLight,
                      backgroundColor: const Color(0xFFF1F5F9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected ? AppColors.primary : Colors.transparent,
                        ),
                      ),
                      labelStyle: AppTypography.bodySmall.copyWith(
                        color: isSelected ? AppColors.primary : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (val) {
                        if (val) {
                          ref.read(orderFilterStatusProvider.notifier).setStatus(f['value']!);
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Orders List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => ref.invalidate(ordersProvider),
              child: ordersAsync.when(
                data: (orders) {
                  if (orders.isEmpty) {
                    return const EmptyView(
                      icon: Icons.receipt_long_outlined,
                      title: 'Không có đơn hàng nào',
                      description: 'Bạn chưa có đơn hàng nào trong trạng thái này.',
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: orders.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return _buildOrderCard(context, ref, order);
                    },
                  );
                },
                loading: () => const LoadingIndicator(),
                error: (err, _) => EmptyView(
                  icon: Icons.error_outline,
                  title: 'Không thể tải đơn hàng',
                  description: err.toString(),
                  buttonText: 'Thử lại',
                  onButtonPressed: () => ref.invalidate(ordersProvider),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, WidgetRef ref, OrderModel order) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.roundedMd,
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppRadius.roundedMd,
          onTap: () => context.push(AppRoutes.orderDetailPath(order.id)),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header: Order ID + Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.storefront_outlined, size: 18, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Text(
                          '#${order.displayOrderNumber}',
                          style: AppTypography.label.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: order.statusColor.withValues(alpha: 0.12),
                        borderRadius: AppRadius.roundedSm,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: order.statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            order.statusVietnamese,
                            style: AppTypography.bodySmall.copyWith(
                              color: order.statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Order Date & Payment Badges
                Row(
                  children: [
                    Text(
                      DateFormatter.formatDateTime(order.createdAt),
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 11),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            order.isStripe ? Icons.credit_card : Icons.payments_outlined,
                            size: 11,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            order.isStripe ? 'Stripe' : 'COD',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: order.paymentStatusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        order.paymentStatusVietnamese,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: order.paymentStatusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 18),

                // Product items preview
                if (order.items.isNotEmpty) ...[
                  Row(
                    children: [
                      // First item thumbnail
                      ClipRRect(
                        borderRadius: AppRadius.roundedSm,
                        child: Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceSecondary,
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: order.items.first.thumbnail != null && order.items.first.thumbnail!.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: order.items.first.thumbnail!,
                                  fit: BoxFit.cover,
                                  errorWidget: (_, _, _) => const Icon(
                                    Icons.shopping_bag_outlined,
                                    size: 20,
                                    color: AppColors.textSecondary,
                                  ),
                                )
                              : const Icon(
                                  Icons.shopping_bag_outlined,
                                  size: 20,
                                  color: AppColors.textSecondary,
                                ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.items.first.name,
                              style: AppTypography.label.copyWith(fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              order.items.length > 1
                                  ? 'và ${order.items.length - 1} sản phẩm khác'
                                  : 'Số lượng: ${order.items.first.quantity}',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],

                // Footer: Total & Action
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tổng tiền (${order.items.length} món)',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 11),
                        ),
                        Text(
                          CurrencyFormatter.formatVND(order.totalAmount),
                          style: AppTypography.price.copyWith(fontSize: 16),
                        ),
                      ],
                    ),
                    if (order.canPayStripe) ...[
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedSm),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.lock_outline, size: 14),
                        label: const Text(
                          'Thanh toán Stripe',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => StripeWebViewScreen(
                                paymentUrl: order.stripePaymentUrl!,
                                orderId: order.id,
                              ),
                            ),
                          );
                          ref.invalidate(ordersProvider);
                        },
                      ),
                    ] else ...[
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedSm),
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                        ),
                        onPressed: () => context.push(AppRoutes.orderDetailPath(order.id)),
                        child: const Text('Xem chi tiết', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

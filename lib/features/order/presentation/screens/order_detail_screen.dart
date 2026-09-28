import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ecommerce_mobile/config/theme/app_colors.dart';
import 'package:ecommerce_mobile/config/theme/app_spacing.dart';
import 'package:ecommerce_mobile/config/theme/app_typography.dart';
import 'package:ecommerce_mobile/core/utils/currency_formatter.dart';
import 'package:ecommerce_mobile/core/utils/date_formatter.dart';
import 'package:ecommerce_mobile/features/checkout/presentation/screens/stripe_webview_screen.dart';
import 'package:ecommerce_mobile/features/order/data/models/order_model.dart';
import 'package:ecommerce_mobile/features/order/data/order_repository.dart';
import 'package:ecommerce_mobile/routing/app_routes.dart';
import 'package:ecommerce_mobile/shared/widgets/app_button.dart';
import 'package:ecommerce_mobile/shared/widgets/empty_view.dart';
import 'package:ecommerce_mobile/shared/widgets/loading_indicator.dart';
import 'package:ecommerce_mobile/shared/dialogs/app_toast.dart';

final orderDetailProvider = FutureProvider.family<OrderModel, String>((ref, id) async {
  final repo = ref.watch(orderRepositoryProvider);
  return await repo.getOrderById(id);
});

class OrderDetailScreen extends ConsumerStatefulWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  bool _isCancelling = false;
  bool _isCompleting = false;

  Future<void> _handleCancelOrder() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedLg),
        title: const Text('Hủy đơn hàng?'),
        content: const Text(
          'Bạn có chắc chắn muốn hủy đơn hàng này không? Sau khi hủy, sản phẩm sẽ được hoàn lại vào kho.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Không'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedSm),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xác nhận hủy', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isCancelling = true);
    try {
      await ref.read(orderRepositoryProvider).cancelOrder(widget.orderId);
      ref.invalidate(orderDetailProvider(widget.orderId));
      if (mounted) {
        AppToast.success('Đã hủy đơn hàng thành công!', context: context);
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(e.toString(), context: context);
      }
    } finally {
      if (mounted) {
        setState(() => _isCancelling = false);
      }
    }
  }

  Future<void> _handleConfirmReceived() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedLg),
        title: const Text('Đã nhận được hàng?'),
        content: const Text(
          'Vui lòng chỉ xác nhận nếu bạn đã nhận đủ và kiểm tra kiện hàng. Đơn hàng sẽ được chuyển sang trạng thái Hoàn thành.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Đóng'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedSm),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xác nhận đã nhận', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isCompleting = true);
    try {
      await ref.read(orderRepositoryProvider).completeOrder(widget.orderId);
      ref.invalidate(orderDetailProvider(widget.orderId));
      if (mounted) {
        AppToast.success('Đơn hàng đã hoàn thành! Cảm ơn bạn đã mua sắm.', context: context);
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(e.toString(), context: context);
      }
    } finally {
      if (mounted) {
        setState(() => _isCompleting = false);
      }
    }
  }

  void _openStripePayment(String url) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StripeWebViewScreen(
          paymentUrl: url,
          orderId: widget.orderId,
        ),
      ),
    );
    if (mounted) {
      ref.invalidate(orderDetailProvider(widget.orderId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderAsync = ref.watch(orderDetailProvider(widget.orderId));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Chi Tiết Đơn Hàng'),
        elevation: 0,
        backgroundColor: Colors.white,
        leading: BackButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.orders);
            }
          },
        ),
        actions: [
          IconButton(
            tooltip: 'Sao chép mã đơn',
            icon: const Icon(Icons.copy_outlined, size: 20),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: widget.orderId));
              AppToast.info('Đã sao chép mã đơn hàng vào bộ nhớ tạm', context: context);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(orderDetailProvider(widget.orderId));
        },
        child: orderAsync.when(
          data: (order) => _buildContent(context, order),
          loading: () => const LoadingIndicator(),
          error: (err, _) => EmptyView(
            icon: Icons.error_outline,
            title: 'Không thể tải chi tiết đơn hàng',
            description: err.toString(),
            buttonText: 'Thử lại',
            onButtonPressed: () => ref.invalidate(orderDetailProvider(widget.orderId)),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, OrderModel order) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        // 1. Order Code & Date Header
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppRadius.roundedMd,
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Đơn hàng: #${order.displayOrderNumber}',
                    style: AppTypography.h3.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormatter.formatDateTime(order.createdAt),
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: order.statusColor.withValues(alpha: 0.12),
                  borderRadius: AppRadius.roundedSm,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: order.statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      order.statusVietnamese,
                      style: AppTypography.bodySmall.copyWith(
                        color: order.statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 2. Order Tracking Stepper
        _buildOrderStepper(order),
        const SizedBox(height: 12),

        // 3. Stripe Payment Banner (if Stripe & PENDING)
        if (order.canPayStripe) ...[
          _buildStripePaymentBanner(order),
          const SizedBox(height: 12),
        ],

        // 4. Delivery Address
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppRadius.roundedMd,
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: AppRadius.roundedSm,
                    ),
                    child: const Icon(Icons.location_on_outlined, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Text('Địa chỉ nhận hàng', style: AppTypography.h3.copyWith(fontSize: 15)),
                ],
              ),
              const Divider(height: 20),
              if (order.customerName != null) ...[
                Text(
                  order.customerName!,
                  style: AppTypography.label.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 2),
              ],
              if (order.customerPhone != null) ...[
                Text(
                  order.customerPhone!,
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 6),
              ],
              Text(
                order.shippingAddress ?? 'Địa chỉ chưa cập nhật',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 5. Products Ordered
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppRadius.roundedMd,
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Sản phẩm (${order.items.length})', style: AppTypography.h3.copyWith(fontSize: 15)),
                  Text(
                    order.paymentMethod == 'STRIPE' ? 'Thẻ Stripe' : 'COD',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),
              ...order.items.map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: AppRadius.roundedSm,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceSecondary,
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: item.thumbnail != null && item.thumbnail!.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: item.thumbnail!,
                                  fit: BoxFit.cover,
                                  errorWidget: (_, _, _) => const Icon(
                                    Icons.image_not_supported,
                                    size: 24,
                                    color: AppColors.textSecondary,
                                  ),
                                )
                              : const Icon(
                                  Icons.shopping_bag_outlined,
                                  size: 24,
                                  color: AppColors.textSecondary,
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: AppTypography.label.copyWith(fontSize: 13),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${CurrencyFormatter.formatVND(item.price)} × ${item.quantity}',
                              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        CurrencyFormatter.formatVND(item.subtotal),
                        style: AppTypography.label.copyWith(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 6. Payment & Cost Details
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppRadius.roundedMd,
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Chi tiết thanh toán', style: AppTypography.h3.copyWith(fontSize: 15)),
              const Divider(height: 20),
              _buildSummaryRow(
                'Hình thức thanh toán',
                order.paymentMethod == 'STRIPE'
                    ? 'Thẻ quốc tế (Stripe Checkout)'
                    : 'Thanh toán khi nhận hàng (COD)',
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Trạng thái thanh toán', style: AppTypography.bodyMedium),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: order.paymentStatusColor.withValues(alpha: 0.12),
                      borderRadius: AppRadius.roundedSm,
                    ),
                    child: Text(
                      order.paymentStatusVietnamese,
                      style: AppTypography.bodySmall.copyWith(
                        color: order.paymentStatusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildSummaryRow('Tạm tính', CurrencyFormatter.formatVND(order.subtotal)),
              const SizedBox(height: 8),
              _buildSummaryRow(
                'Phí vận chuyển',
                order.shippingFee == 0 ? 'Miễn phí' : CurrencyFormatter.formatVND(order.shippingFee),
                valueColor: order.shippingFee == 0 ? AppColors.success : null,
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Tổng cộng', style: AppTypography.h3),
                  Text(
                    CurrencyFormatter.formatVND(order.totalAmount),
                    style: AppTypography.h2.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 7. Action Buttons (Confirm Received / Cancel)
        if (order.canConfirmReceived) ...[
          AppButton(
            text: 'Đã nhận được hàng',
            variant: AppButtonVariant.primary,
            isLoading: _isCompleting,
            onPressed: _handleConfirmReceived,
          ),
          const SizedBox(height: 10),
        ],

        if (order.canCancel) ...[
          AppButton(
            text: 'Hủy đơn hàng',
            variant: AppButtonVariant.danger,
            isLoading: _isCancelling,
            onPressed: _handleCancelOrder,
          ),
          const SizedBox(height: 10),
        ],

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
        Text(
          value,
          style: AppTypography.label.copyWith(color: valueColor ?? AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildStripePaymentBanner(OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.roundedMd,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.credit_card, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Thanh Toán Trực Tuyến Stripe',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Cần thanh toán: ${CurrencyFormatter.formatVND(order.totalAmount)}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF4F46E5),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedSm),
                elevation: 0,
              ),
              icon: const Icon(Icons.lock_outline, size: 18),
              label: const Text(
                'Thanh toán qua Stripe ngay',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              onPressed: () => _openStripePayment(order.stripePaymentUrl!),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderStepper(OrderModel order) {
    if (order.status.toUpperCase() == 'CANCELLED') {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.errorLight,
          borderRadius: AppRadius.roundedMd,
          border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.cancel_outlined, color: AppColors.error, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Đơn hàng đã bị hủy',
                    style: AppTypography.h3.copyWith(color: AppColors.error, fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Đơn hàng này không còn hiệu lực. Bạn có thể đặt lại sản phẩm bất cứ lúc nào.',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.error),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final currentStep = order.statusStepIndex;
    final steps = [
      {'title': 'Đặt hàng', 'icon': Icons.receipt_long_outlined},
      {'title': 'Xác nhận', 'icon': Icons.check_circle_outline},
      {'title': 'Đang giao', 'icon': Icons.local_shipping_outlined},
      {'title': 'Hoàn thành', 'icon': Icons.task_alt},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.roundedMd,
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tiến độ đơn hàng', style: AppTypography.h3.copyWith(fontSize: 14)),
          const SizedBox(height: 16),
          Row(
            children: List.generate(steps.length * 2 - 1, (index) {
              if (index.isOdd) {
                final lineStepIndex = index ~/ 2;
                final isPassed = currentStep > lineStepIndex;
                return Expanded(
                  child: Container(
                    height: 3,
                    color: isPassed ? AppColors.primary : AppColors.border,
                  ),
                );
              }

              final stepIndex = index ~/ 2;
              final isPassed = currentStep >= stepIndex;
              final isCurrent = currentStep == stepIndex;
              final step = steps[stepIndex];

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isPassed ? AppColors.primary : AppColors.surfaceSecondary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isPassed ? AppColors.primary : AppColors.border,
                        width: isCurrent ? 2 : 1,
                      ),
                      boxShadow: isCurrent
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      step['icon'] as IconData,
                      size: 18,
                      color: isPassed ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    step['title'] as String,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                      color: isPassed ? AppColors.textPrimary : AppColors.textSecondary,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

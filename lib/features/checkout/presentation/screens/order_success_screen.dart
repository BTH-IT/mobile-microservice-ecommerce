import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ecommerce_mobile/config/theme/app_colors.dart';
import 'package:ecommerce_mobile/config/theme/app_spacing.dart';
import 'package:ecommerce_mobile/config/theme/app_typography.dart';
import 'package:ecommerce_mobile/routing/app_routes.dart';
import 'package:ecommerce_mobile/shared/widgets/app_button.dart';

class OrderSuccessScreen extends StatelessWidget {
  final String orderId;

  const OrderSuccessScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.go(AppRoutes.home);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: AppColors.successLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    size: 80,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                Text(
                  'Đặt Hàng Thành Công!',
                  style: AppTypography.h1,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Cảm ơn bạn đã mua sắm tại BTH Store. Đơn hàng của bạn đang được xử lý và chuẩn bị giao hàng.',
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSecondary,
                    borderRadius: AppRadius.roundedMd,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Mã đơn hàng', style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
                      const SizedBox(height: 4),
                      SelectableText(
                        orderId,
                        textAlign: TextAlign.center,
                        style: AppTypography.label.copyWith(color: AppColors.primary, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                AppButton(
                  text: 'Xem chi tiết đơn hàng',
                  onPressed: () => context.go(AppRoutes.orderDetailPath(orderId)),
                ),
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  text: 'Tiếp tục mua sắm',
                  variant: AppButtonVariant.outline,
                  onPressed: () => context.go(AppRoutes.home),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

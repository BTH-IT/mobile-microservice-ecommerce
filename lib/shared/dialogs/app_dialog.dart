import 'package:flutter/material.dart';
import 'package:ecommerce_mobile/config/theme/app_colors.dart';
import 'package:ecommerce_mobile/config/theme/app_decorations.dart';
import 'package:ecommerce_mobile/config/theme/app_typography.dart';
import 'package:ecommerce_mobile/routing/app_coordinator.dart';

class AppDialog {
  AppDialog._();

  static Future<bool> confirm({
    required String title,
    required String message,
    String confirmText = 'Xác nhận',
    String cancelText = 'Hủy',
    bool isDestructive = false,
  }) async {
    final context = AppCoordinator.context;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppDecorations.radiusL),
        title: Text(title, style: AppTypography.titleLarge),
        content: Text(message, style: AppTypography.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(cancelText, style: AppTypography.button.copyWith(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDestructive ? AppColors.error : AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: AppDecorations.radiusS),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(confirmText, style: AppTypography.button),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

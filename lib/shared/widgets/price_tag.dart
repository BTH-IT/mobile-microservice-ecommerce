import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_spacing.dart';
import '../../config/theme/app_typography.dart';
import '../../core/utils/currency_formatter.dart';

class PriceTag extends StatelessWidget {
  final num price;
  final num? originalPrice;
  final TextStyle? priceStyle;
  final bool showBadge;

  const PriceTag({
    super.key,
    required this.price,
    this.originalPrice,
    this.priceStyle,
    this.showBadge = true,
  });

  @override
  Widget build(BuildContext context) {
    final hasDiscount = originalPrice != null && originalPrice! > price;
    final discountPercent = hasDiscount
        ? CurrencyFormatter.calculateDiscountPercent(originalPrice!, price)
        : '';

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.xs,
      children: [
        Text(
          CurrencyFormatter.formatVND(price),
          style: priceStyle ?? AppTypography.price,
        ),
        if (hasDiscount) ...[
          Text(
            CurrencyFormatter.formatVND(originalPrice),
            style: AppTypography.originalPrice,
          ),
          if (showBadge && discountPercent.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                borderRadius: AppRadius.roundedSm,
              ),
              child: Text(
                discountPercent,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ),
        ],
      ],
    );
  }
}

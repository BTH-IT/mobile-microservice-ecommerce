import 'package:flutter/material.dart';
import 'package:ecommerce_mobile/config/theme/app_colors.dart';
import 'package:ecommerce_mobile/config/theme/app_decorations.dart';
import 'package:ecommerce_mobile/config/theme/app_typography.dart';

enum XButtonVariant { primary, secondary, outline, danger }

class XButtonSize {
  final double height;
  final double iconSize;
  final double padding;
  final TextStyle style;

  const XButtonSize({
    required this.height,
    required this.iconSize,
    required this.padding,
    required this.style,
  });

  factory XButtonSize.small() => XButtonSize(
        height: 36,
        iconSize: 16,
        padding: 12,
        style: AppTypography.button.copyWith(fontSize: 13),
      );

  factory XButtonSize.medium() => XButtonSize(
        height: 48,
        iconSize: 20,
        padding: 16,
        style: AppTypography.button.copyWith(fontSize: 15),
      );

  factory XButtonSize.large() => XButtonSize(
        height: 56,
        iconSize: 24,
        padding: 20,
        style: AppTypography.button.copyWith(fontSize: 16),
      );
}

/// A button that displays a busy indicator without causing UI jumpiness,
/// inspired by GoldenOwl template XButton.
class XButton extends StatelessWidget {
  final String? title;
  final Widget? child;
  final Widget? icon;
  final VoidCallback? onPressed;
  final bool busy;
  final bool enabled;
  final bool isFullWidth;
  final XButtonVariant variant;
  final XButtonSize? size;

  const XButton({
    super.key,
    this.title,
    this.child,
    this.icon,
    this.onPressed,
    this.busy = false,
    this.enabled = true,
    this.isFullWidth = true,
    this.variant = XButtonVariant.primary,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final buttonSize = size ?? XButtonSize.medium();

    Color backgroundColor;
    Color foregroundColor;
    BorderSide borderSide = BorderSide.none;

    switch (variant) {
      case XButtonVariant.primary:
        backgroundColor = AppColors.primary;
        foregroundColor = AppColors.primaryForeground;
        break;
      case XButtonVariant.secondary:
        backgroundColor = AppColors.primaryLight;
        foregroundColor = AppColors.primary;
        break;
      case XButtonVariant.outline:
        backgroundColor = Colors.transparent;
        foregroundColor = AppColors.textPrimary;
        borderSide = const BorderSide(color: AppColors.border, width: 1.2);
        break;
      case XButtonVariant.danger:
        backgroundColor = AppColors.error;
        foregroundColor = Colors.white;
        break;
    }

    // UX design: when busy, button stays visually enabled but click is blocked
    final effectiveOnPressed = enabled
        ? () {
            if (!busy) onPressed?.call();
          }
        : null;

    final indicator = SizedBox(
      width: buttonSize.iconSize,
      height: buttonSize.iconSize,
      child: CircularProgressIndicator(
        strokeWidth: 2.2,
        valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
      ),
    );

    final textWidget = child ??
        Text(
          title ?? '',
          style: buttonSize.style.copyWith(color: foregroundColor),
        );

    Widget content = busy
        ? indicator
        : (icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  icon!,
                  const SizedBox(width: 8),
                  textWidget,
                ],
              )
            : textWidget);

    return SizedBox(
      height: buttonSize.height,
      width: isFullWidth ? double.infinity : null,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: 0,
          side: borderSide,
          shape: const RoundedRectangleBorder(borderRadius: AppDecorations.radiusS),
          padding: EdgeInsets.symmetric(horizontal: buttonSize.padding),
        ),
        onPressed: effectiveOnPressed,
        child: content,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Application decoration constants for consistent UI styling
class AppDecorations {
  AppDecorations._();

  // MARK: - Shadow Styles
  static final List<BoxShadow> shadowLight = [
    BoxShadow(
      offset: const Offset(0, 1),
      blurRadius: 3,
      spreadRadius: 0,
      color: Colors.black.withValues(alpha: 0.05),
    ),
  ];

  static final List<BoxShadow> shadowMedium = [
    BoxShadow(
      offset: const Offset(0, 2),
      blurRadius: 6,
      spreadRadius: 0,
      color: Colors.black.withValues(alpha: 0.08),
    ),
  ];

  static final List<BoxShadow> shadowStrong = [
    BoxShadow(
      offset: const Offset(0, 4),
      blurRadius: 12,
      spreadRadius: 0,
      color: Colors.black.withValues(alpha: 0.12),
    ),
  ];

  static final List<BoxShadow> shadowCard = [
    BoxShadow(
      offset: const Offset(0, 1),
      blurRadius: 3,
      spreadRadius: 0,
      color: Colors.black.withValues(alpha: 0.04),
    ),
  ];

  static final List<BoxShadow> shadowModal = [
    BoxShadow(
      offset: const Offset(0, -4),
      blurRadius: 16,
      spreadRadius: 0,
      color: Colors.black.withValues(alpha: 0.08),
    ),
  ];

  // MARK: - Border Radius
  static const BorderRadius radiusXS = BorderRadius.all(Radius.circular(4));
  static const BorderRadius radiusS = BorderRadius.all(Radius.circular(8));
  static const BorderRadius radiusM = BorderRadius.all(Radius.circular(12));
  static const BorderRadius radiusL = BorderRadius.all(Radius.circular(16));
  static const BorderRadius radiusXL = BorderRadius.all(Radius.circular(24));
  static const BorderRadius radiusCircular = BorderRadius.all(Radius.circular(999));

  // MARK: - Border Styles
  static const Border borderDefault = Border.fromBorderSide(
    BorderSide(color: AppColors.border, width: 1),
  );

  static const Border borderFocused = Border.fromBorderSide(
    BorderSide(color: AppColors.primary, width: 1.5),
  );

  static const Border borderError = Border.fromBorderSide(
    BorderSide(color: AppColors.error, width: 1),
  );

  // MARK: - Container Decorations
  static BoxDecoration get cardDecoration => BoxDecoration(
        color: AppColors.surface,
        borderRadius: radiusM,
        boxShadow: shadowCard,
        border: Border.all(color: AppColors.border),
      );

  static BoxDecoration get modalDecoration => BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: shadowModal,
      );

  // MARK: - Gradient Decorations
  static const LinearGradient gradientPrimary = LinearGradient(
    colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gradientHero = LinearGradient(
    colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gradientShimmer = LinearGradient(
    colors: [Color(0xFFE2E8F0), Color(0xFFF8FAFC), Color(0xFFE2E8F0)],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

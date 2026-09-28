import 'package:flutter/material.dart';

/// Application color constants following Material Design 3 and Web Storefront tokens
class AppColors {
  AppColors._();

  // MARK: - Primary Brand Colors
  /// Deep Royal Blue matching web oklch(0.42 0.16 260)
  static const Color primary = Color(0xFF1E40AF);
  static const Color primaryHover = Color(0xFF1D4ED8);
  static const Color primaryLight = Color(0xFFEFF6FF);
  static const Color primaryDark = Color(0xFF1E3A8A);
  static const Color primaryForeground = Colors.white;

  // MARK: - Secondary Brand Colors
  static const Color secondary = Color(0xFF3B82F6);
  static const Color secondaryLight = Color(0xFFDBEAFE);
  static const Color secondaryDark = Color(0xFF1D4ED8);

  // MARK: - Text Colors
  static const Color text = Color(0xFF0F172A); // slate-900
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B); // slate-500
  static const Color textMuted = Color(0xFF94A3B8); // slate-400
  static const Color textDisabled = Color(0xFFCBD5E1); // slate-300
  static const Color textOnPrimary = Colors.white;
  static const Color link = Color(0xFF2563EB);

  // MARK: - Background Colors
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSecondary = Color(0xFFF8FAFC);
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  static const Color card = Color(0xFFFFFFFF);

  // MARK: - Semantic Colors
  static const Color success = Color(0xFF10B981); // emerald-500
  static const Color successLight = Color(0xFFECFDF5);
  static const Color warning = Color(0xFFF59E0B); // amber-500
  static const Color warningLight = Color(0xFFFFFBEB);
  static const Color error = Color(0xFFEF4444); // red-500
  static const Color errorLight = Color(0xFFFEF2F2);
  static const Color info = Color(0xFF3B82F6); // blue-500
  static const Color infoLight = Color(0xFFEFF6FF);

  // MARK: - Neutral Colors
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color neutral900 = Color(0xFF0F172A);
  static const Color neutral800 = Color(0xFF1E293B);
  static const Color neutral700 = Color(0xFF334155);
  static const Color neutral600 = Color(0xFF475569);
  static const Color neutral500 = Color(0xFF64748B);
  static const Color neutral400 = Color(0xFF94A3B8);
  static const Color neutral300 = Color(0xFFCBD5E1);
  static const Color neutral200 = Color(0xFFE2E8F0);
  static const Color neutral100 = Color(0xFFF1F5F9);
  static const Color neutral50 = Color(0xFFF8FAFC);

  // MARK: - Component Specific Colors
  static const Color divider = Color(0xFFE2E8F0);
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF1F5F9);
  static const Color inputBorder = Color(0xFFCBD5E1);
  static const Color focus = Color(0xFF2563EB);
  static const Color disabled = Color(0xFFE2E8F0);

  // MARK: - Shimmer Colors
  static const Color shimmerBase = Color(0xFFE2E8F0);
  static const Color shimmerHighlight = Color(0xFFF8FAFC);
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Application text styles following Material Design 3 typography system with Be Vietnam Pro
class AppTypography {
  AppTypography._();

  // MARK: - Display Styles
  static TextStyle get displayLarge => GoogleFonts.beVietnamPro(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
        height: 1.12,
        color: AppColors.text,
      );

  static TextStyle get displayMedium => GoogleFonts.beVietnamPro(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.16,
        color: AppColors.text,
      );

  static TextStyle get displaySmall => GoogleFonts.beVietnamPro(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.22,
        color: AppColors.text,
      );

  // MARK: - Headline Styles
  static TextStyle get headlineLarge => GoogleFonts.beVietnamPro(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
        height: 1.25,
        color: AppColors.text,
      );

  static TextStyle get headlineMedium => GoogleFonts.beVietnamPro(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
        height: 1.29,
        color: AppColors.text,
      );

  static TextStyle get headlineSmall => GoogleFonts.beVietnamPro(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.33,
        color: AppColors.text,
      );

  // MARK: - Headings Shorthand
  static TextStyle get h1 => headlineLarge;
  static TextStyle get h2 => headlineMedium;
  static TextStyle get h3 => headlineSmall;

  // MARK: - Title Styles
  static TextStyle get titleLarge => GoogleFonts.beVietnamPro(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.27,
        color: AppColors.text,
      );

  static TextStyle get titleMedium => GoogleFonts.beVietnamPro(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        height: 1.50,
        color: AppColors.text,
      );

  static TextStyle get titleSmall => GoogleFonts.beVietnamPro(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.43,
        color: AppColors.text,
      );

  // MARK: - Body Styles
  static TextStyle get bodyLarge => GoogleFonts.beVietnamPro(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        height: 1.50,
        color: AppColors.text,
      );

  static TextStyle get bodyMedium => GoogleFonts.beVietnamPro(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        height: 1.43,
        color: AppColors.text,
      );

  static TextStyle get bodySmall => GoogleFonts.beVietnamPro(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        height: 1.33,
        color: AppColors.textSecondary,
      );

  // MARK: - Label & Custom Styles
  static TextStyle get label => GoogleFonts.beVietnamPro(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.43,
        color: AppColors.text,
      );

  static TextStyle get button => GoogleFonts.beVietnamPro(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        color: AppColors.textOnPrimary,
      );

  static TextStyle get price => GoogleFonts.beVietnamPro(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        color: AppColors.primary,
      );

  static TextStyle get originalPrice => GoogleFonts.beVietnamPro(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.textMuted,
        decoration: TextDecoration.lineThrough,
      );

  static TextStyle get link => GoogleFonts.beVietnamPro(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.link,
        decoration: TextDecoration.underline,
      );

  // MARK: - Style Variants Helper Methods
  static TextStyle withColor(TextStyle baseStyle, Color color) => baseStyle.copyWith(color: color);
  static TextStyle withWeight(TextStyle baseStyle, FontWeight weight) => baseStyle.copyWith(fontWeight: weight);
  static TextStyle withSize(TextStyle baseStyle, double size) => baseStyle.copyWith(fontSize: size);
}

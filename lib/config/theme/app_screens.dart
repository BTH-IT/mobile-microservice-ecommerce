import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Screen utilities and responsive design helpers inspired by GoldenOwl template
class AppScreens {
  const AppScreens._();

  static MediaQueryData _mediaQuery = const MediaQueryData();

  /// Initialize screen data with MediaQuery context
  static void init(BuildContext context) {
    _mediaQuery = MediaQuery.of(context);
  }

  // MARK: - Basic Screen Properties
  static double get scale => _mediaQuery.devicePixelRatio;
  static double get width => _mediaQuery.size.width;
  static double get height => _mediaQuery.size.height;
  static Size get size => _mediaQuery.size;
  static Orientation get orientation => _mediaQuery.orientation;
  static bool get isPortrait => orientation == Orientation.portrait;
  static bool get isLandscape => orientation == Orientation.landscape;

  // MARK: - Safe Area Properties
  static double get topSafeHeight => _mediaQuery.padding.top;
  static double get bottomSafeHeight => _mediaQuery.padding.bottom;
  static EdgeInsets get safeAreaInsets => _mediaQuery.padding;
  static double get safeHeight => height - topSafeHeight - bottomSafeHeight;
  static double get safeWidth => width - _mediaQuery.padding.left - _mediaQuery.padding.right;

  // MARK: - Breakpoints & Device Types
  static bool get isPhone => width < 600;
  static bool get isTablet => width >= 600 && width < 1200;
  static bool get isDesktop => width >= 1200;
  static bool get isSmallScreen => width < 360;

  // MARK: - Responsive Helpers
  static T responsive<T>({required T mobile, T? tablet, T? desktop}) {
    if (isDesktop && desktop != null) return desktop;
    if (isTablet && tablet != null) return tablet;
    return mobile;
  }

  static double widthPercent(double percentage) => width * (percentage / 100);
  static double heightPercent(double percentage) => height * (percentage / 100);

  // MARK: - Keyboard & Notch
  static bool get hasNotch => topSafeHeight > 24;
  static bool get hasKeyboard => _mediaQuery.viewInsets.bottom > 0;
  static double get keyboardHeight => _mediaQuery.viewInsets.bottom;

  // MARK: - System UI Controls
  static void setLightStatusBar() => SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  static void setDarkStatusBar() => SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
}

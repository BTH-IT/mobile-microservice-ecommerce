import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _vndFormat = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
    decimalDigits: 0,
  );

  /// Formats an integer or double price to Vietnamese Dong string:
  /// e.g. 150000 -> "150.000 ₫"
  static String formatVND(num? amount) {
    if (amount == null) return '0 ₫';
    return _vndFormat.format(amount).trim();
  }

  /// Calculates discount percentage string: e.g. -25%
  static String calculateDiscountPercent(num originalPrice, num salePrice) {
    if (originalPrice <= 0 || salePrice >= originalPrice) return '';
    final percent = (((originalPrice - salePrice) / originalPrice) * 100).round();
    return '-$percent%';
  }
}

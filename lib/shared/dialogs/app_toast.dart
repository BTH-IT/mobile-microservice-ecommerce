import 'package:flutter/material.dart';
import 'package:ecommerce_mobile/routing/app_coordinator.dart';

enum ToastType { success, error, warning, info }

/// Premium, modern floating toast component for BTH Ecommerce
class AppToast {
  AppToast._();

  static void success(String message, {BuildContext? context, String? title}) {
    show(message, type: ToastType.success, context: context, title: title ?? 'Thành công');
  }

  static void error(String message, {BuildContext? context, String? title}) {
    show(message, type: ToastType.error, context: context, title: title ?? 'Đã xảy ra lỗi');
  }

  static void warning(String message, {BuildContext? context, String? title}) {
    show(message, type: ToastType.warning, context: context, title: title ?? 'Cảnh báo');
  }

  static void info(String message, {BuildContext? context, String? title}) {
    show(message, type: ToastType.info, context: context, title: title ?? 'Thông báo');
  }

  static void show(
    String message, {
    ToastType type = ToastType.info,
    BuildContext? context,
    String? title,
    Duration duration = const Duration(seconds: 3),
  }) {
    final ctx = context ?? (AppCoordinator.navigatorKey.currentState?.context);
    if (ctx == null) return;

    final messenger = ScaffoldMessenger.maybeOf(ctx);
    if (messenger == null) return;

    messenger.hideCurrentSnackBar();

    Color accentColor;
    IconData iconData;
    String defaultTitle;

    switch (type) {
      case ToastType.success:
        accentColor = const Color(0xFF10B981); // Emerald green
        iconData = Icons.check_circle_rounded;
        defaultTitle = 'Thành công';
        break;
      case ToastType.error:
        accentColor = const Color(0xFFEF4444); // Crimson red
        iconData = Icons.cancel_rounded;
        defaultTitle = 'Thất bại';
        break;
      case ToastType.warning:
        accentColor = const Color(0xFFF59E0B); // Amber
        iconData = Icons.warning_rounded;
        defaultTitle = 'Chú ý';
        break;
      case ToastType.info:
        accentColor = const Color(0xFF3B82F6); // Blue
        iconData = Icons.info_rounded;
        defaultTitle = 'Thông báo';
        break;
    }

    final displayTitle = title ?? defaultTitle;

    messenger.showSnackBar(
      SnackBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
        padding: EdgeInsets.zero,
        duration: duration,
        content: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF18181B), // Dark obsidian / zinc-900
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.4),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 18,
                offset: const Offset(0, 8),
                spreadRadius: 1,
              ),
              BoxShadow(
                color: accentColor.withValues(alpha: 0.18),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Glowing Icon Badge
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  iconData,
                  color: accentColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              // Message Column
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayTitle,
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      message,
                      style: const TextStyle(
                        color: Color(0xFFF1F5F9),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Close button
              GestureDetector(
                onTap: () => messenger.hideCurrentSnackBar(),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.close_rounded,
                    color: Colors.white.withValues(alpha: 0.45),
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

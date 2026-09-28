import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../config/theme/app_typography.dart';
import '../../../../routing/app_routes.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/dialogs/app_toast.dart';
import '../../../auth/presentation/auth_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tài Khoản'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // User Card or Login Banner
          if (authState.isAuthenticated) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: AppColors.primaryLight,
                      backgroundImage: authState.user?.avatarUrl != null
                          ? CachedNetworkImageProvider(authState.user!.avatarUrl!)
                          : null,
                      child: authState.user?.avatarUrl == null
                          ? Text(
                              (authState.user?.fullName.isNotEmpty ?? false)
                                  ? authState.user!.fullName[0].toUpperCase()
                                  : 'U',
                              style: AppTypography.h2.copyWith(color: AppColors.primary),
                            )
                          : null,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            authState.user?.fullName ?? 'Khách hàng',
                            style: AppTypography.h3,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            authState.user?.email ?? '',
                            style: AppTypography.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            Card(
              color: AppColors.primaryLight,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Chào mừng bạn đến với BTH Store', style: AppTypography.h3),
                    const SizedBox(height: 6),
                    Text(
                      'Đăng nhập ngay để tận hưởng trải nghiệm mua sắm trọn vẹn và ưu đãi đặc quyền.',
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    AppButton(
                      text: 'Đăng nhập / Đăng ký',
                      onPressed: () => context.push(AppRoutes.login),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),

          // Menu Options
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.receipt_long_outlined, color: AppColors.primary),
                  title: const Text('Đơn hàng của tôi'),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () {
                    if (authState.isAuthenticated) {
                      context.push(AppRoutes.orders);
                    } else {
                      context.push(AppRoutes.login);
                    }
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.location_on_outlined, color: AppColors.primary),
                  title: const Text('Sổ địa chỉ nhận hàng'),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () {
                    if (authState.isAuthenticated) {
                      context.push(AppRoutes.addressList);
                    } else {
                      context.push(AppRoutes.login);
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // General Settings & Support
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.support_agent_outlined, color: AppColors.primary),
                  title: const Text('Trung tâm hỗ trợ khách hàng'),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () {
                    AppToast.info('Hotline: 1900 xxxx (8:00 - 21:00 hàng ngày)', context: context);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.info_outline, color: AppColors.primary),
                  title: const Text('Thông tin ứng dụng'),
                  subtitle: const Text('Phiên bản 1.0.0'),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Logout Button
          if (authState.isAuthenticated) ...[
            AppButton(
              text: 'Đăng xuất',
              variant: AppButtonVariant.outline,
              icon: const Icon(Icons.logout, size: 18),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Đăng xuất?'),
                    content: const Text('Bạn có chắc chắn muốn đăng xuất khỏi tài khoản không?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Hủy'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                        onPressed: () {
                          Navigator.pop(context);
                          ref.read(authProvider.notifier).logout();
                        },
                        child: const Text('Đăng xuất', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ],
      ),
    );
  }
}

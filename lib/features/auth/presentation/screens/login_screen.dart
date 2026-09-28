import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../config/env.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../config/theme/app_typography.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../routing/app_routes.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/dialogs/app_toast.dart';
import '../auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _rememberMe = true;

  @override
  void initState() {
    super.initState();
    final prefStorage = ref.read(preferenceStorageProvider);
    _emailController = TextEditingController(text: prefStorage.rememberedEmail ?? '');
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final prefStorage = ref.read(preferenceStorageProvider);
    if (_rememberMe) {
      await prefStorage.setRememberedEmail(email);
    } else {
      await prefStorage.clearRememberedEmail();
    }

    final success = await ref.read(authProvider.notifier).login(email, password);

    if (mounted) {
      if (success) {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(AppRoutes.home);
        }
      } else {
        final errorMsg = ref.read(authProvider).errorMessage ?? 'Đăng nhập không thành công';
        AppToast.error(errorMsg, context: context);
      }
    }
  }

  Future<void> _handleGoogleLogin() async {
    final googleAuthUrl = Uri.parse(
      '${Env.apiBaseUrl}${ApiEndpoints.googleAuth}?redirectUri=${Env.deepLinkScheme}://auth/callback',
    );
    if (await canLaunchUrl(googleAuthUrl)) {
      await launchUrl(googleAuthUrl, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        AppToast.error('Không thể mở liên kết đăng nhập Google', context: context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng Nhập'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo / Header
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.bolt,
                        size: 40,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Chào mừng trở lại',
                    style: AppTypography.h2,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Đăng nhập để quản lý đơn hàng và giỏ hàng của bạn',
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Email
                  AppTextField(
                    label: 'Email',
                    hint: 'name@example.com',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(Icons.email_outlined, size: 20),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Vui lòng nhập email';
                      if (!val.contains('@') || !val.contains('.')) return 'Email không đúng định dạng';
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Password
                  AppTextField(
                    label: 'Mật khẩu',
                    hint: '••••••••',
                    controller: _passwordController,
                    isPassword: true,
                    prefixIcon: const Icon(Icons.lock_outline, size: 20),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Vui lòng nhập mật khẩu';
                      if (val.length < 6) return 'Mật khẩu tối thiểu 6 ký tự';
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Remember me
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        activeColor: AppColors.primary,
                        onChanged: (val) => setState(() => _rememberMe = val ?? false),
                      ),
                      Text('Ghi nhớ tài khoản', style: AppTypography.bodyMedium),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Submit Button
                  AppButton(
                    text: 'Đăng nhập',
                    isLoading: authState.isLoading,
                    onPressed: _handleLogin,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Divider
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'HOẶC',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Google SSO
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedMd),
                    ),
                    icon: const Icon(Icons.g_mobiledata, size: 28, color: Colors.red),
                    label: Text(
                      'Đăng nhập với Google',
                      style: AppTypography.button.copyWith(color: AppColors.textPrimary),
                    ),
                    onPressed: _handleGoogleLogin,
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Register link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Chưa có tài khoản? ', style: AppTypography.bodyMedium),
                      GestureDetector(
                        onTap: () => context.push(AppRoutes.register),
                        child: Text(
                          'Đăng ký ngay',
                          style: AppTypography.label.copyWith(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

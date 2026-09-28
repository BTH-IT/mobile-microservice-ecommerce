import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ecommerce_mobile/config/theme/app_colors.dart';
import 'package:ecommerce_mobile/config/theme/app_spacing.dart';
import 'package:ecommerce_mobile/config/theme/app_typography.dart';
import 'package:ecommerce_mobile/core/utils/currency_formatter.dart';
import 'package:ecommerce_mobile/features/auth/presentation/auth_controller.dart';
import 'package:ecommerce_mobile/features/cart/presentation/cart_controller.dart';
import 'package:ecommerce_mobile/features/checkout/data/checkout_repository.dart';
import 'package:ecommerce_mobile/features/checkout/presentation/screens/stripe_webview_screen.dart';
import 'package:ecommerce_mobile/features/profile/data/address_repository.dart';
import 'package:ecommerce_mobile/features/profile/data/models/address_model.dart';
import 'package:ecommerce_mobile/features/order/data/order_repository.dart';
import 'package:ecommerce_mobile/routing/app_routes.dart';
import 'package:ecommerce_mobile/shared/widgets/app_button.dart';
import 'package:ecommerce_mobile/shared/widgets/app_text_field.dart';
import 'package:ecommerce_mobile/shared/widgets/empty_view.dart';
import 'package:ecommerce_mobile/shared/dialogs/app_toast.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _detailController;
  late final TextEditingController _provinceController;
  late final TextEditingController _districtController;
  late final TextEditingController _wardController;
  late final TextEditingController _noteController;

  String _paymentMethod = 'COD'; // 'COD' or 'STRIPE'
  bool _isProcessing = false;
  List<AddressModel> _savedAddresses = [];
  String? _selectedAddressId;

  @override
  void initState() {
    super.initState();
    final authUser = ref.read(authProvider).user;
    final defaultName = (authUser?.fullName.isNotEmpty == true && authUser?.fullName != authUser?.email)
        ? authUser!.fullName
        : 'Nguyễn Văn A';
    final defaultPhone = (authUser?.phone?.isNotEmpty == true)
        ? authUser!.phone!
        : '0901234567';

    _nameController = TextEditingController(text: defaultName);
    _phoneController = TextEditingController(text: defaultPhone);
    _detailController = TextEditingController(text: '123 Đường Cầu Giấy');
    _provinceController = TextEditingController(text: 'Hà Nội');
    _districtController = TextEditingController(text: 'Cầu Giấy');
    _wardController = TextEditingController(text: 'Dịch Vọng');
    _noteController = TextEditingController(text: 'Giao trong giờ hành chính');

    _loadSavedAddresses();
  }

  Future<void> _loadSavedAddresses() async {
    try {
      final addresses = await ref.read(addressRepositoryProvider).getAddresses();
      if (mounted && addresses.isNotEmpty) {
        setState(() {
          _savedAddresses = addresses;
          final defaultAddr = addresses.firstWhere((a) => a.isDefault, orElse: () => addresses.first);
          _applyAddress(defaultAddr);
        });
      }
    } catch (_) {}
  }

  void _applyAddress(AddressModel addr) {
    _selectedAddressId = addr.id;
    _nameController.text = addr.recipientName;
    _phoneController.text = addr.phone;
    _provinceController.text = addr.province;
    _districtController.text = addr.district;
    _wardController.text = addr.ward;
    _detailController.text = addr.detail;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _detailController.dispose();
    _provinceController.dispose();
    _districtController.dispose();
    _wardController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _handleConfirmOrder() async {
    if (!_formKey.currentState!.validate()) return;

    final cartState = ref.read(cartProvider);
    if (cartState.isEmpty) return;

    setState(() => _isProcessing = true);

    try {
      final checkoutRepo = ref.read(checkoutRepositoryProvider);
      final items = cartState.cart.items
          .map((i) => {
                'productId': i.productId,
                'quantity': i.quantity,
              })
          .toList();

      // 1. Create Checkout Session
      final session = await checkoutRepo.createSession(
        items: items,
        shippingAddressId: _selectedAddressId,
        paymentMethod: _paymentMethod,
      );

      // 2. Confirm Checkout Session
      final result = await checkoutRepo.confirmSession(
        sessionId: session.id,
        recipientName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        addressDetail: _detailController.text.trim(),
        province: _provinceController.text.trim(),
        district: _districtController.text.trim(),
        ward: _wardController.text.trim(),
        note: _noteController.text.trim(),
      );

      // 3. Clear cart
      await ref.read(cartProvider.notifier).clearCart();

      final orderId = result.orderId ?? session.id;

      if (!mounted) return;

      String? paymentUrl = result.paymentUrl;
      if (_paymentMethod == 'STRIPE' && (paymentUrl == null || paymentUrl.isEmpty)) {
        try {
          final paymentStatus = await ref.read(orderRepositoryProvider).getPaymentStatus(orderId);
          paymentUrl = paymentStatus['paymentUrl']?.toString();
        } catch (_) {}
      }

      if (!mounted) return;

      if (_paymentMethod == 'STRIPE' && paymentUrl != null && paymentUrl.isNotEmpty) {
        // Open Stripe WebView
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StripeWebViewScreen(
              paymentUrl: paymentUrl!,
              orderId: orderId,
            ),
          ),
        );
      } else {
        // COD order placed successfully
        context.go(AppRoutes.orderSuccessPath(orderId));
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(e.toString(), context: context);
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);

    if (cartState.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Thanh Toán')),
        body: EmptyView(
          icon: Icons.remove_shopping_cart_outlined,
          title: 'Giỏ hàng của bạn đang trống',
          description: 'Vui lòng chọn sản phẩm trước khi thanh toán.',
          buttonText: 'Xem sản phẩm',
          onButtonPressed: () => context.go(AppRoutes.products),
        ),
      );
    }

    final subtotal = cartState.cart.totalPrice;
    final shippingFee = subtotal > 500000 ? 0 : 30000;
    final total = subtotal + shippingFee;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Xác Nhận Đặt Hàng'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            // Saved Addresses Dropdown
            if (_savedAddresses.isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Chọn từ sổ địa chỉ', style: AppTypography.label),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedAddressId,
                        isExpanded: true,
                        decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                        items: _savedAddresses.map((a) {
                          return DropdownMenuItem(
                            value: a.id,
                            child: Text(
                              '${a.recipientName} - ${a.phone} (${a.fullAddress})',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.bodySmall,
                            ),
                          );
                        }).toList(),
                        onChanged: (id) {
                          if (id != null) {
                            final selected = _savedAddresses.firstWhere((a) => a.id == id);
                            setState(() => _applyAddress(selected));
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            // Delivery Address Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text('Thông tin giao hàng', style: AppTypography.h3),
                      ],
                    ),
                    const Divider(height: 24),
                    AppTextField(
                      label: 'Tên người nhận',
                      hint: 'Nguyễn Văn A',
                      controller: _nameController,
                      validator: (val) => val == null || val.trim().isEmpty ? 'Vui lòng nhập tên' : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      label: 'Số điện thoại',
                      hint: '0901234567',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      validator: (val) => val == null || val.trim().isEmpty ? 'Vui lòng nhập số điện thoại' : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            label: 'Tỉnh / Thành phố',
                            hint: 'Hà Nội',
                            controller: _provinceController,
                            validator: (val) => val == null || val.trim().isEmpty ? 'Nhập tỉnh/thành' : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: AppTextField(
                            label: 'Quận / Huyện',
                            hint: 'Cầu Giấy',
                            controller: _districtController,
                            validator: (_) => null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            label: 'Phường / Xã',
                            hint: 'Dịch Vọng',
                            controller: _wardController,
                            validator: (val) => val == null || val.trim().isEmpty ? 'Nhập phường/xã' : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: AppTextField(
                            label: 'Số nhà, đường',
                            hint: '123 Đường Cầu Giấy',
                            controller: _detailController,
                            validator: (val) => val == null || val.trim().isEmpty ? 'Nhập địa chỉ chi tiết' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      label: 'Ghi chú cho shipper (tùy chọn)',
                      hint: 'Giao trong giờ hành chính...',
                      controller: _noteController,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Payment Methods Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadius.roundedMd,
                border: Border.all(color: AppColors.borderLight),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.payment_outlined, color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Text('Phương thức thanh toán', style: AppTypography.h3.copyWith(fontSize: 15)),
                    ],
                  ),
                  const Divider(height: 20),

                  // Option 1: COD
                  InkWell(
                    borderRadius: AppRadius.roundedSm,
                    onTap: () => setState(() => _paymentMethod = 'COD'),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _paymentMethod == 'COD' ? AppColors.primaryLight.withValues(alpha: 0.4) : const Color(0xFFF8FAFC),
                        borderRadius: AppRadius.roundedSm,
                        border: Border.all(
                          color: _paymentMethod == 'COD' ? AppColors.primary : AppColors.borderLight,
                          width: _paymentMethod == 'COD' ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _paymentMethod == 'COD' ? AppColors.primary : Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.borderLight),
                            ),
                            child: Icon(
                              Icons.local_shipping_outlined,
                              size: 18,
                              color: _paymentMethod == 'COD' ? Colors.white : AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Thanh toán khi nhận hàng (COD)',
                                  style: AppTypography.label.copyWith(
                                    fontSize: 13,
                                    color: _paymentMethod == 'COD' ? AppColors.primaryDark : AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Thanh toán tiền mặt cho nhân viên giao hàng',
                                  style: AppTypography.bodySmall.copyWith(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _paymentMethod == 'COD' ? AppColors.primary : const Color(0xFFCBD5E1),
                                width: 2,
                              ),
                            ),
                            child: _paymentMethod == 'COD'
                                ? Center(
                                    child: Container(
                                      width: 11,
                                      height: 11,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Option 2: Stripe
                  InkWell(
                    borderRadius: AppRadius.roundedSm,
                    onTap: () => setState(() => _paymentMethod = 'STRIPE'),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _paymentMethod == 'STRIPE' ? const Color(0xFFEEF2FF) : const Color(0xFFF8FAFC),
                        borderRadius: AppRadius.roundedSm,
                        border: Border.all(
                          color: _paymentMethod == 'STRIPE' ? const Color(0xFF6366F1) : AppColors.borderLight,
                          width: _paymentMethod == 'STRIPE' ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _paymentMethod == 'STRIPE' ? const Color(0xFF6366F1) : Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.borderLight),
                            ),
                            child: Icon(
                              Icons.credit_card,
                              size: 18,
                              color: _paymentMethod == 'STRIPE' ? Colors.white : AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Thẻ quốc tế / Stripe',
                                      style: AppTypography.label.copyWith(
                                        fontSize: 13,
                                        color: _paymentMethod == 'STRIPE' ? const Color(0xFF4338CA) : AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF4F46E5).withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'Bảo mật SSL',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF4F46E5),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Visa, MasterCard, JCB qua Stripe Checkout',
                                  style: AppTypography.bodySmall.copyWith(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _paymentMethod == 'STRIPE' ? const Color(0xFF6366F1) : const Color(0xFFCBD5E1),
                                width: 2,
                              ),
                            ),
                            child: _paymentMethod == 'STRIPE'
                                ? Center(
                                    child: Container(
                                      width: 11,
                                      height: 11,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFF6366F1),
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Order Summary Breakdown
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tóm tắt đơn hàng', style: AppTypography.h3),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Tạm tính (${cartState.itemCount} sản phẩm)', style: AppTypography.bodyMedium),
                        Text(CurrencyFormatter.formatVND(subtotal), style: AppTypography.label),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Phí vận chuyển', style: AppTypography.bodyMedium),
                        Text(
                          shippingFee == 0 ? 'Miễn phí' : CurrencyFormatter.formatVND(shippingFee),
                          style: AppTypography.label.copyWith(
                            color: shippingFee == 0 ? AppColors.success : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Tổng thanh toán', style: AppTypography.h3),
                        const SizedBox(width: AppSpacing.sm),
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              CurrencyFormatter.formatVND(total),
                              style: AppTypography.h2.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Submit Button
            AppButton(
              text: _paymentMethod == 'STRIPE' ? 'Tiếp tục thanh toán với Stripe' : 'Xác nhận đặt hàng',
              isLoading: _isProcessing,
              onPressed: _handleConfirmOrder,
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}

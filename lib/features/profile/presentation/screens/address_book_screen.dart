import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ecommerce_mobile/config/theme/app_colors.dart';
import 'package:ecommerce_mobile/config/theme/app_spacing.dart';
import 'package:ecommerce_mobile/config/theme/app_typography.dart';
import 'package:ecommerce_mobile/features/profile/data/address_repository.dart';
import 'package:ecommerce_mobile/features/profile/data/models/address_model.dart';
import 'package:ecommerce_mobile/shared/widgets/app_button.dart';
import 'package:ecommerce_mobile/shared/widgets/app_text_field.dart';
import 'package:ecommerce_mobile/shared/widgets/empty_view.dart';
import 'package:ecommerce_mobile/shared/widgets/loading_indicator.dart';
import 'package:ecommerce_mobile/shared/dialogs/app_toast.dart';

final addressesProvider = FutureProvider<List<AddressModel>>((ref) async {
  final repo = ref.watch(addressRepositoryProvider);
  return await repo.getAddresses();
});

class AddressBookScreen extends ConsumerWidget {
  const AddressBookScreen({super.key});

  void _showAddAddressDialog(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: 'Nguyễn Văn A');
    final phoneCtrl = TextEditingController(text: '0901234567');
    final provinceCtrl = TextEditingController(text: 'Thành phố Hồ Chí Minh');
    final districtCtrl = TextEditingController(text: 'Quận 1');
    final wardCtrl = TextEditingController(text: 'Phường Bến Nghé');
    final detailCtrl = TextEditingController(text: '123 Đường Đồng Khởi');
    bool isDefault = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Thêm Địa Chỉ Mới', style: AppTypography.h3),
                      const Divider(height: 24),
                      AppTextField(
                        label: 'Họ tên người nhận',
                        hint: 'Nguyễn Văn A',
                        controller: nameCtrl,
                        validator: (v) => v?.trim().isEmpty ?? true ? 'Vui lòng nhập họ tên' : null,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      AppTextField(
                        label: 'Số điện thoại',
                        hint: '0901234567',
                        controller: phoneCtrl,
                        keyboardType: TextInputType.phone,
                        validator: (v) => v?.trim().isEmpty ?? true ? 'Vui lòng nhập số điện thoại' : null,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      AppTextField(
                        label: 'Tỉnh / Thành phố',
                        hint: 'Hà Nội',
                        controller: provinceCtrl,
                        validator: (v) => v?.trim().isEmpty ?? true ? 'Nhập tỉnh/thành' : null,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              label: 'Quận / Huyện',
                              hint: 'Cầu Giấy',
                              controller: districtCtrl,
                              validator: (v) => v?.trim().isEmpty ?? true ? 'Nhập quận/huyện' : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: AppTextField(
                              label: 'Phường / Xã',
                              hint: 'Dịch Vọng',
                              controller: wardCtrl,
                              validator: (v) => v?.trim().isEmpty ?? true ? 'Nhập phường/xã' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      AppTextField(
                        label: 'Địa chỉ cụ thể (số nhà, ngõ, đường)',
                        hint: 'Số 123 đường Cầu Giấy',
                        controller: detailCtrl,
                        validator: (v) => v?.trim().isEmpty ?? true ? 'Nhập địa chỉ chi tiết' : null,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Checkbox(
                            value: isDefault,
                            activeColor: AppColors.primary,
                            onChanged: (v) => setModalState(() => isDefault = v ?? false),
                          ),
                          Text('Đặt làm địa chỉ mặc định', style: AppTypography.bodyMedium),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      AppButton(
                        text: 'Lưu địa chỉ',
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;
                          final newAddr = AddressModel(
                            id: '',
                            recipientName: nameCtrl.text.trim(),
                            phone: phoneCtrl.text.trim(),
                            province: provinceCtrl.text.trim(),
                            district: districtCtrl.text.trim(),
                            ward: wardCtrl.text.trim(),
                            detail: detailCtrl.text.trim(),
                            isDefault: isDefault,
                          );

                          try {
                            await ref.read(addressRepositoryProvider).addAddress(newAddr);
                            ref.invalidate(addressesProvider);
                            if (ctx.mounted) {
                              Navigator.pop(ctx);
                            }
                          } catch (e) {
                            if (ctx.mounted) {
                              AppToast.error(e.toString(), context: ctx);
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addressesAsync = ref.watch(addressesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sổ Địa Chỉ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Thêm địa chỉ mới',
            onPressed: () => _showAddAddressDialog(context, ref),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(addressesProvider),
        child: addressesAsync.when(
          data: (addresses) {
            if (addresses.isEmpty) {
              return EmptyView(
                icon: Icons.location_off_outlined,
                title: 'Chưa có địa chỉ nào',
                description: 'Thêm địa chỉ nhận hàng để thanh toán nhanh chóng hơn.',
                buttonText: 'Thêm địa chỉ ngay',
                onButtonPressed: () => _showAddAddressDialog(context, ref),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: addresses.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final addr = addresses[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(addr.recipientName, style: AppTypography.label),
                            if (addr.isDefault)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: AppRadius.roundedSm,
                                ),
                                child: Text(
                                  'Mặc định',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(addr.phone, style: AppTypography.bodySmall),
                        const SizedBox(height: 8),
                        Text(addr.fullAddress, style: AppTypography.bodyMedium),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (!addr.isDefault)
                              TextButton(
                                onPressed: () async {
                                  await ref.read(addressRepositoryProvider).setDefaultAddress(addr.id);
                                  ref.invalidate(addressesProvider);
                                },
                                child: const Text('Đặt mặc định'),
                              ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.error),
                              onPressed: () async {
                                await ref.read(addressRepositoryProvider).deleteAddress(addr.id);
                                ref.invalidate(addressesProvider);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const LoadingIndicator(),
          error: (err, _) => Center(
            child: EmptyView(
              icon: Icons.error_outline,
              title: 'Không thể tải sổ địa chỉ',
              description: err.toString(),
              buttonText: 'Thử lại',
              onButtonPressed: () => ref.invalidate(addressesProvider),
            ),
          ),
        ),
      ),
    );
  }
}

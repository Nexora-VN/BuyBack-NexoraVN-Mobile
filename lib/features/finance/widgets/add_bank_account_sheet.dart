import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../repositories/finance_repository.dart';

void showAddBankAccountSheet(
  BuildContext context,
  WidgetRef ref, {
  VoidCallback? onSuccess,
}) {
  final codeController = TextEditingController();
  final nameController = TextEditingController();
  final holderController = TextEditingController();
  final numberController = TextEditingController();
  bool isSubmitting = false;
  String? errorText;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Thêm tài khoản ngân hàng',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                      ),
                      IconButton(
                        icon: const Icon(LucideIcons.x, size: 20),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    controller: codeController,
                    label: 'Mã ngân hàng (ví dụ: VCB, MB, TCB)',
                    hintText: 'Nhập mã ngân hàng...',
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: nameController,
                    label: 'Tên ngân hàng (ví dụ: Vietcombank)',
                    hintText: 'Nhập tên ngân hàng...',
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: holderController,
                    label: 'Tên chủ tài khoản (Viết hoa không dấu)',
                    hintText: 'NGUYEN VAN A',
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: numberController,
                    label: 'Số tài khoản',
                    hintText: 'Nhập số tài khoản...',
                    keyboardType: TextInputType.number,
                  ),
                  if (errorText != null) ...[
                    const SizedBox(height: 10),
                    Text(errorText!, style: const TextStyle(color: AppColors.statusDangerText, fontSize: 12)),
                  ],
                  const SizedBox(height: 20),
                  AppButton(
                    text: 'Lưu tài khoản',
                    isLoading: isSubmitting,
                    onPressed: () async {
                      if (codeController.text.trim().isEmpty ||
                          nameController.text.trim().isEmpty ||
                          holderController.text.trim().isEmpty ||
                          numberController.text.trim().isEmpty) {
                        setSheetState(() => errorText = 'Vui lòng điền đầy đủ các thông tin');
                        return;
                      }

                      setSheetState(() {
                        isSubmitting = true;
                        errorText = null;
                      });

                      try {
                        await ref.read(financeRepositoryProvider).createBankAccount(
                              bankCode: codeController.text.trim(),
                              bankName: nameController.text.trim(),
                              accountHolder: holderController.text.trim().toUpperCase(),
                              accountNumber: numberController.text.trim(),
                            );
                        if (ctx.mounted) Navigator.pop(ctx);
                        onSuccess?.call();
                      } catch (e) {
                        setSheetState(() {
                          isSubmitting = false;
                          errorText = e.toString().replaceAll('Exception: ', '');
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

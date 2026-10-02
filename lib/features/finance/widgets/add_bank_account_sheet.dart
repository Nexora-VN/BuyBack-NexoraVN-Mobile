import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_feedback.dart';
import '../../../core/widgets/app_text_field.dart';
import '../models/bank_account_model.dart';
import '../repositories/finance_repository.dart';

void showAddBankAccountSheet(
  BuildContext context,
  WidgetRef ref, {
  BankAccountModel? bank,
  VoidCallback? onSuccess,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _BankAccountSheet(bank: bank, onSuccess: onSuccess),
  );
}

class _BankAccountSheet extends ConsumerStatefulWidget {
  final BankAccountModel? bank;
  final VoidCallback? onSuccess;

  const _BankAccountSheet({this.bank, this.onSuccess});

  @override
  ConsumerState<_BankAccountSheet> createState() => _BankAccountSheetState();
}

class _BankAccountSheetState extends ConsumerState<_BankAccountSheet> {
  late final TextEditingController _code;
  late final TextEditingController _name;
  late final TextEditingController _holder;
  final TextEditingController _number = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _code = TextEditingController(text: widget.bank?.bankCode);
    _name = TextEditingController(text: widget.bank?.bankName);
    _holder = TextEditingController(text: widget.bank?.accountHolder);
  }

  @override
  void dispose() {
    _code.dispose();
    _name.dispose();
    _holder.dispose();
    _number.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (_code.text.trim().isEmpty ||
        _name.text.trim().isEmpty ||
        _holder.text.trim().isEmpty ||
        _number.text.trim().isEmpty) {
      setState(() => _error = 'Vui lòng điền đầy đủ các thông tin');
      return;
    }
    if (!RegExp(r'^\d{6,30}$').hasMatch(_number.text.trim())) {
      setState(() => _error = 'Số tài khoản phải gồm 6 đến 30 chữ số');
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final repository = ref.read(financeRepositoryProvider);
      if (widget.bank == null) {
        await repository.createBankAccount(
          bankCode: _code.text.trim(),
          bankName: _name.text.trim(),
          accountHolder: _holder.text.trim().toUpperCase(),
          accountNumber: _number.text.trim(),
        );
      } else {
        await repository.updateBankAccount(
          widget.bank!.id,
          bankCode: _code.text.trim(),
          bankName: _name.text.trim(),
          accountHolder: _holder.text.trim().toUpperCase(),
          accountNumber: _number.text.trim(),
        );
      }
      if (!mounted) return;
      Navigator.of(context).pop();
      widget.onSuccess?.call();
      AppFeedback.success(
        widget.bank == null
            ? 'Đã thêm tài khoản ngân hàng'
            : 'Đã cập nhật tài khoản ngân hàng',
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = AppFeedback.messageFor(
          error,
          fallback: 'Không thể lưu tài khoản. Vui lòng thử lại.',
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bank = widget.bank;
    return PopScope(
      canPop: !_submitting,
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    bank == null
                        ? 'Thêm tài khoản ngân hàng'
                        : 'Sửa tài khoản ngân hàng',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Đóng',
                    icon: const Icon(LucideIcons.x, size: 20),
                    onPressed: _submitting
                        ? null
                        : () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              AppTextField(
                controller: _code,
                label: 'Mã ngân hàng (ví dụ: VCB, MB, TCB)',
                hintText: 'Nhập mã ngân hàng...',
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _name,
                label: 'Tên ngân hàng (ví dụ: Vietcombank)',
                hintText: 'Nhập tên ngân hàng...',
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _holder,
                label: 'Tên chủ tài khoản (Viết hoa không dấu)',
                hintText: 'NGUYEN VAN A',
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _number,
                label: 'Số tài khoản',
                hintText: bank == null
                    ? 'Nhập số tài khoản...'
                    : 'Nhập lại đầy đủ số tài khoản...',
                keyboardType: TextInputType.number,
              ),
              if (bank != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Tài khoản hiện tại •••• ${bank.lastFour}. Nhập lại số đầy đủ để lưu thay đổi; phiên bản mới cần được duyệt.',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(
                  _error!,
                  style: const TextStyle(
                    color: AppColors.statusDangerText,
                    fontSize: 12,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              AppButton(
                text: bank == null ? 'Lưu tài khoản' : 'Lưu thay đổi',
                isLoading: _submitting,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

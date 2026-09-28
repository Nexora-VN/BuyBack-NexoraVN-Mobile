import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/status_badge.dart';
import '../../auth/providers/auth_provider.dart';
import '../../finance/models/bank_account_model.dart';
import '../../finance/repositories/finance_repository.dart';

final bankAccountsProvider = FutureProvider.autoDispose<List<BankAccountModel>>((ref) {
  final repo = ref.watch(financeRepositoryProvider);
  return repo.getBankAccounts();
});

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  void _showAddBankDialog(BuildContext context, WidgetRef ref) {
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
                          ref.invalidate(bankAccountsProvider);
                          if (ctx.mounted) Navigator.pop(ctx);
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

  Future<void> _deleteBank(BuildContext context, WidgetRef ref, String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Gỡ tài khoản ngân hàng?'),
        content: const Text('Bạn có chắc chắn muốn gỡ tài khoản này? Các yêu cầu rút tiền đã tạo trước đó vẫn giữ nguyên thông tin.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.statusDangerText),
            child: const Text('Gỡ tài khoản'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(financeRepositoryProvider).deleteBankAccount(id);
        ref.invalidate(bankAccountsProvider);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final banksAsync = ref.watch(bankAccountsProvider);

    return Scaffold(
      backgroundColor: AppColors.pageTint,
      appBar: AppBar(
        title: const Text('Tài khoản của bạn'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // User Card
            AppCard(
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.softSurface,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(
                      child: Icon(LucideIcons.user, size: 24, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authState.user?.email ?? 'Người dùng',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Vai trò: ${authState.user?.role ?? "USER"}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Bank Accounts Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'TÀI KHOẢN NGÂN HÀNG',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _showAddBankDialog(context, ref),
                  icon: const Icon(LucideIcons.plus, size: 14, color: AppColors.primary),
                  label: const Text(
                    'Thêm mới',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Bank Accounts List
            banksAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
              error: (err, _) => AppCard(
                child: Text('Lỗi: $err', style: const TextStyle(color: AppColors.statusDangerText)),
              ),
              data: (banks) {
                if (banks.isEmpty) {
                  return AppCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    child: Center(
                      child: Text(
                        'Bạn chưa thêm tài khoản ngân hàng nào. Bấm "Thêm mới" để liên kết tài khoản nhận tiền rút nha!',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: banks.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final bank = banks[index];
                    return AppCard(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.softSurface,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(LucideIcons.landmark, size: 20, color: AppColors.primary),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        bank.bankName,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    StatusBadge(status: bank.status, domain: StatusDomain.bank),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${bank.accountHolder} • •••• ${bank.lastFour}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                if (bank.reviewReason != null && bank.reviewReason!.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    bank.reviewReason!,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.statusDangerText,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(LucideIcons.trash2, size: 18, color: AppColors.textDisabled),
                            onPressed: () => _deleteBank(context, ref, bank.id),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 24),

            // Navigation shortcuts
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(LucideIcons.link2, size: 20, color: AppColors.primary),
                    title: const Text('Link của tôi', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    trailing: const Icon(LucideIcons.chevronRight, size: 18, color: AppColors.textDisabled),
                    onTap: () => context.push('/app/links'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(LucideIcons.shieldCheck, size: 20, color: AppColors.primary),
                    title: const Text('Điều khoản & Chính sách', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    trailing: const Icon(LucideIcons.chevronRight, size: 18, color: AppColors.textDisabled),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Logout Button
            AppButton(
              text: 'Đăng xuất',
              icon: const Icon(LucideIcons.logOut, size: 18, color: AppColors.statusDangerText),
              variant: AppButtonVariant.outline,
              onPressed: () async {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) {
                  context.go('/login');
                }
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

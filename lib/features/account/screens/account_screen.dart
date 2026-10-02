import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_feedback.dart';
import '../../../core/widgets/status_badge.dart';
import '../../auth/providers/auth_provider.dart';
import '../../finance/models/bank_account_model.dart';
import '../../finance/repositories/finance_repository.dart';
import '../../finance/widgets/add_bank_account_sheet.dart';

final bankAccountsProvider = FutureProvider.autoDispose<List<BankAccountModel>>(
  (ref) {
    final repo = ref.watch(financeRepositoryProvider);
    return repo.getBankAccounts();
  },
);

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  Future<void> _deleteBank(
    BuildContext context,
    WidgetRef ref,
    String id,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Gỡ tài khoản ngân hàng?'),
        content: const Text(
          'Bạn có chắc chắn muốn gỡ tài khoản này? Các yêu cầu rút tiền đã tạo trước đó vẫn giữ nguyên thông tin.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.statusDangerText,
            ),
            child: const Text('Gỡ tài khoản'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(financeRepositoryProvider).deleteBankAccount(id);
        ref.invalidate(bankAccountsProvider);
        AppFeedback.success('Đã gỡ tài khoản ngân hàng');
      } catch (e) {
        AppFeedback.error(
          e,
          fallback: 'Không thể gỡ tài khoản. Vui lòng thử lại.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final banksAsync = ref.watch(bankAccountsProvider);

    return Scaffold(
      backgroundColor: AppColors.pageTint,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Page Heading matching Web 1:1
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tài khoản của bạn',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.4,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Thông tin cá nhân, liên kết ngân hàng nhận tiền hoàn và cài đặt.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
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
                      child: Icon(
                        LucideIcons.user,
                        size: 24,
                        color: AppColors.primary,
                      ),
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
                  onPressed: () => showAddBankAccountSheet(
                    context,
                    ref,
                    onSuccess: () => ref.invalidate(bankAccountsProvider),
                  ),
                  icon: const Icon(
                    LucideIcons.plus,
                    size: 14,
                    color: AppColors.primary,
                  ),
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
                child: Column(
                  children: [
                    Text(
                      AppFeedback.messageFor(
                        err,
                        fallback: 'Không thể tải tài khoản ngân hàng.',
                      ),
                      style: const TextStyle(color: AppColors.statusDangerText),
                    ),
                    TextButton(
                      onPressed: () => ref.invalidate(bankAccountsProvider),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
              data: (banks) {
                if (banks.isEmpty) {
                  return AppCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                    child: Center(
                      child: Text(
                        'Bạn chưa thêm tài khoản ngân hàng nào. Bấm "Thêm mới" để liên kết tài khoản nhận tiền rút nha!',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.softSurface,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  LucideIcons.landmark,
                                  size: 20,
                                  color: AppColors.primary,
                                ),
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
                                        StatusBadge(
                                          status: bank.status,
                                          domain: StatusDomain.bank,
                                        ),
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
                                    if (bank.reviewReason != null &&
                                        bank.reviewReason!.isNotEmpty) ...[
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
                            ],
                          ),
                          const Divider(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                onPressed: () => showAddBankAccountSheet(
                                  context,
                                  ref,
                                  bank: bank,
                                  onSuccess: () =>
                                      ref.invalidate(bankAccountsProvider),
                                ),
                                icon: const Icon(LucideIcons.pencil, size: 16),
                                label: const Text('Sửa'),
                              ),
                              TextButton.icon(
                                onPressed: () =>
                                    _deleteBank(context, ref, bank.id),
                                icon: const Icon(LucideIcons.trash2, size: 16),
                                label: const Text('Gỡ'),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.statusDangerText,
                                ),
                              ),
                            ],
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
                    leading: const Icon(
                      LucideIcons.link2,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    title: const Text(
                      'Link của tôi',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: const Icon(
                      LucideIcons.chevronRight,
                      size: 18,
                      color: AppColors.textDisabled,
                    ),
                    onTap: () => context.push('/app/links'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Logout Button
            AppButton(
              text: 'Đăng xuất',
              icon: const Icon(
                LucideIcons.logOut,
                size: 18,
                color: AppColors.statusDangerText,
              ),
              variant: AppButtonVariant.outline,
              isLoading: authState.isLoading,
              onPressed: () async {
                try {
                  await ref.read(authProvider.notifier).logout();
                  AppFeedback.success('Đã đăng xuất');
                } catch (error) {
                  AppFeedback.error(
                    error,
                    fallback: 'Không thể đăng xuất. Vui lòng thử lại.',
                  );
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/format_utils.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_feedback.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../finance/models/bank_account_model.dart';
import '../../finance/models/dashboard_model.dart';
import '../../finance/repositories/finance_repository.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import '../../wallet/screens/wallet_screen.dart';
import 'withdrawal_history_screen.dart';
import '../../finance/widgets/add_bank_account_sheet.dart';

final withdrawalWalletProvider = FutureProvider.autoDispose<DashboardWallet>((
  ref,
) {
  final repo = ref.watch(financeRepositoryProvider);
  return repo.getWallet();
});

final approvedBanksProvider =
    FutureProvider.autoDispose<List<BankAccountModel>>((ref) {
      final repo = ref.watch(financeRepositoryProvider);
      return repo.getBankAccounts(status: 'APPROVED');
    });

class NewWithdrawalScreen extends ConsumerStatefulWidget {
  const NewWithdrawalScreen({super.key});

  @override
  ConsumerState<NewWithdrawalScreen> createState() =>
      _NewWithdrawalScreenState();
}

class _NewWithdrawalScreenState extends ConsumerState<NewWithdrawalScreen> {
  final _amountController = TextEditingController();
  String? _selectedBankId;
  String? _amountError;
  String? _bankError;
  String? _apiError;
  bool _isSubmitting = false;

  int _currentStep = 1; // 1: edit, 2: review, 3: done
  String? _idempotencyKey;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _validateAndReview(
    DashboardWallet wallet,
    List<BankAccountModel> banks,
  ) {
    bool valid = true;
    final rawAmount = _amountController.text.replaceAll(RegExp(r'[^\d]'), '');
    final amountNum = int.tryParse(rawAmount) ?? 0;
    final availableNum =
        int.tryParse(wallet.available.replaceAll(RegExp(r'[^\d]'), '')) ?? 0;

    if (amountNum < 50000) {
      setState(() => _amountError = 'Số tiền rút tối thiểu là 50.000 ₫');
      valid = false;
    } else if (amountNum > availableNum) {
      setState(() => _amountError = 'Số dư khả dụng không đủ');
      valid = false;
    } else {
      setState(() => _amountError = null);
    }

    if (_selectedBankId == null || _selectedBankId!.isEmpty) {
      setState(
        () => _bankError = 'Vui lòng chọn tài khoản ngân hàng nhận tiền',
      );
      valid = false;
    } else {
      setState(() => _bankError = null);
    }

    if (valid) {
      setState(() => _currentStep = 2);
    }
  }

  Future<void> _submitWithdrawal() async {
    if (_isSubmitting) return;
    setState(() {
      _isSubmitting = true;
      _apiError = null;
    });

    _idempotencyKey ??= const Uuid().v4();
    final rawAmount = _amountController.text.replaceAll(RegExp(r'[^\d]'), '');

    try {
      await ref
          .read(financeRepositoryProvider)
          .createWithdrawal(
            amount: rawAmount,
            bankId: _selectedBankId!,
            idempotencyKey: _idempotencyKey!,
          );
      if (!mounted) return;
      ref.invalidate(withdrawalWalletProvider);
      ref.invalidate(withdrawalHistoryProvider);
      ref.invalidate(walletDashboardProvider);
      ref.invalidate(dashboardFutureProvider);
      setState(() {
        _isSubmitting = false;
        _currentStep = 3;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _apiError = AppFeedback.messageFor(
          e,
          fallback: 'Không thể tạo yêu cầu rút tiền. Vui lòng thử lại.',
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final walletAsync = ref.watch(withdrawalWalletProvider);
    final banksAsync = ref.watch(approvedBanksProvider);

    return Scaffold(
      backgroundColor: AppColors.pageTint,
      appBar: AppBar(title: const Text('Yêu cầu rút tiền')),
      body: _currentStep == 3
          ? _buildSuccessView()
          : walletAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (err, _) => Center(
                child: Text(
                  'Lỗi: $err',
                  style: const TextStyle(color: AppColors.statusDangerText),
                ),
              ),
              data: (wallet) {
                return banksAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                  error: (err, _) => Center(
                    child: Text(
                      'Lỗi: $err',
                      style: const TextStyle(color: AppColors.statusDangerText),
                    ),
                  ),
                  data: (banks) {
                    if (banks.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                LucideIcons.alertCircle,
                                size: 48,
                                color: AppColors.statusPendingText,
                              ),
                              const SizedBox(height: 14),
                              const Text(
                                'Chưa có tài khoản ngân hàng đã duyệt',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Bạn cần liên kết tài khoản ngân hàng và được admin duyệt trước khi rút tiền.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              AppButton(
                                text: 'Thêm tài khoản ngân hàng',
                                onPressed: () {
                                  showAddBankAccountSheet(
                                    context,
                                    ref,
                                    onSuccess: () {
                                      ref.invalidate(approvedBanksProvider);
                                    },
                                  );
                                },
                              ),
                              const SizedBox(height: 12),
                              AppButton(
                                text: 'Đến Cài đặt tài khoản',
                                variant: AppButtonVariant.outline,
                                onPressed: () => context.go('/app/account'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    // Set default bank if not selected
                    _selectedBankId ??= banks.first.id;
                    final selectedBank = banks.firstWhere(
                      (b) => b.id == _selectedBankId,
                      orElse: () => banks.first,
                    );

                    // STEP 2: Review
                    if (_currentStep == 2) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AppCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'XÁC NHẬN YÊU CẦU RÚT TIỀN',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textSecondary,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildReviewRow(
                                    'Số tiền rút',
                                    FormatUtils.formatVnd(
                                      _amountController.text,
                                    ),
                                    isHighlight: true,
                                  ),
                                  const Divider(height: 20),
                                  _buildReviewRow(
                                    'Ngân hàng nhận',
                                    selectedBank.bankName,
                                  ),
                                  const Divider(height: 20),
                                  _buildReviewRow(
                                    'Số tài khoản',
                                    '•••• ${selectedBank.lastFour}',
                                  ),
                                  const Divider(height: 20),
                                  _buildReviewRow(
                                    'Chủ tài khoản',
                                    selectedBank.accountHolder,
                                  ),
                                ],
                              ),
                            ),
                            if (_apiError != null) ...[
                              const SizedBox(height: 14),
                              Text(
                                _apiError!,
                                style: const TextStyle(
                                  color: AppColors.statusDangerText,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: AppButton(
                                    text: 'Quay lại',
                                    variant: AppButtonVariant.outline,
                                    onPressed: () =>
                                        setState(() => _currentStep = 1),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: AppButton(
                                    text: 'Xác nhận rút',
                                    isLoading: _isSubmitting,
                                    onPressed: _submitWithdrawal,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }

                    // STEP 1: Edit Form
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AppCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Số dư khả dụng của bạn',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  FormatUtils.formatVnd(wallet.available),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          AppCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Amount Input
                                AppTextField(
                                  controller: _amountController,
                                  label:
                                      'Số tiền muốn rút (tối thiểu 50.000 ₫)',
                                  hintText: 'Nhập số tiền (VND)...',
                                  keyboardType: TextInputType.number,
                                  errorText: _amountError,
                                  prefixIcon: const Icon(
                                    LucideIcons.banknote,
                                    size: 18,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 18),

                                // Select Bank
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Tài khoản ngân hàng nhận tiền',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        showAddBankAccountSheet(
                                          context,
                                          ref,
                                          onSuccess: () {
                                            ref.invalidate(
                                              approvedBanksProvider,
                                            );
                                          },
                                        );
                                      },
                                      borderRadius: BorderRadius.circular(4),
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 4,
                                          vertical: 2,
                                        ),
                                        child: Text(
                                          '+ Thêm mới',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: AppDimensions.roundedControl,
                                    border: Border.all(
                                      color: AppColors.borderSubtle,
                                      width: 1.0,
                                    ),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _selectedBankId,
                                      isExpanded: true,
                                      icon: const Icon(
                                        LucideIcons.chevronDown,
                                        size: 18,
                                      ),
                                      items: banks.map((bank) {
                                        return DropdownMenuItem<String>(
                                          value: bank.id,
                                          child: Text(
                                            '${bank.bankName} - ${bank.accountHolder} (•••• ${bank.lastFour})',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        setState(() => _selectedBankId = val);
                                      },
                                    ),
                                  ),
                                ),
                                if (_bankError != null) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    _bankError!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.statusDangerText,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 24),

                                AppButton(
                                  text: 'Tiếp tục',
                                  onPressed: () =>
                                      _validateAndReview(wallet, banks),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _buildSuccessView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 32),
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppColors.statusSuccessBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.checkCircle2,
                size: 36,
                color: AppColors.statusSuccessText,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Đã gửi yêu cầu rút tiền',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Số tiền đã được giữ để xử lý yêu cầu. Admin sẽ chuyển khoản thủ công cho bạn trong thời gian sớm nhất.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            AppButton(
              text: 'Xem lịch sử rút tiền',
              onPressed: () => context.go('/app/withdrawals'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewRow(
    String label,
    String value, {
    bool isHighlight = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isHighlight ? 16 : 13,
            fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w600,
            color: isHighlight ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

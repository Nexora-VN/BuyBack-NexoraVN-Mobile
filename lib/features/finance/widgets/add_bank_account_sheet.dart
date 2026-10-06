import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
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
  final _number = TextEditingController();
  late final TextEditingController _holder;
  List<BankOption> _banks = [];
  String? _bankCode;
  bool _loadingBanks = true;
  bool _review = false;
  bool _submitting = false;
  String? _error;

  BankOption? get _selected {
    for (final bank in _banks) {
      if (bank.code == _bankCode) return bank;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _bankCode = widget.bank?.bankCode;
    _holder = TextEditingController(text: widget.bank?.accountHolder);
    _loadBanks();
  }

  Future<void> _loadBanks() async {
    try {
      final banks = await ref
          .read(financeRepositoryProvider)
          .getSupportedBanks();
      if (!mounted) return;
      if (widget.bank != null &&
          !banks.any((item) => item.code == widget.bank!.bankCode)) {
        banks.add(
          BankOption(code: widget.bank!.bankCode, name: widget.bank!.bankName),
        );
      }
      setState(() {
        _banks = banks;
        _loadingBanks = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingBanks = false;
        _error = 'Không tải được danh sách ngân hàng. Vui lòng thử lại.';
      });
    }
  }

  Future<void> _chooseBank() async {
    if (_loadingBanks || _submitting) return;
    final result = await showModalBottomSheet<BankOption>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _BankPickerSheet(banks: _banks),
    );
    if (!mounted || result == null) return;
    setState(() {
      _bankCode = result.code;
      _error = null;
    });
  }

  @override
  void dispose() {
    _number.dispose();
    _holder.dispose();
    super.dispose();
  }

  void _next() {
    final selected = _selected;
    final number = _number.text.trim();
    final holder = _holder.text.trim();
    String? error;
    if (selected == null) {
      error = 'Vui lòng chọn ngân hàng hoặc MoMo';
    } else if (selected.kind == 'wallet' &&
        !RegExp(r'^0\d{9}$').hasMatch(number)) {
      error = 'Số điện thoại MoMo phải có 10 chữ số và bắt đầu bằng 0';
    } else if (selected.kind != 'wallet' &&
        !RegExp(r'^\d{6,30}$').hasMatch(number)) {
      error = 'Số tài khoản phải gồm 6 đến 30 chữ số';
    } else if (holder.length < 2 || holder.length > 120) {
      error = 'Vui lòng nhập tên chủ tài khoản';
    }
    setState(() {
      _error = error;
      _review = error == null;
    });
  }

  Future<void> _save() async {
    if (_submitting || _selected == null) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final bank = _selected!;
      final repository = ref.read(financeRepositoryProvider);
      if (widget.bank == null) {
        await repository.createBankAccount(
          bankCode: bank.code,
          bankName: bank.name,
          accountHolder: _holder.text.trim().toUpperCase(),
          accountNumber: _number.text.trim(),
        );
      } else {
        await repository.updateBankAccount(
          widget.bank!.id,
          bankCode: bank.code,
          bankName: bank.name,
          accountHolder: _holder.text.trim().toUpperCase(),
          accountNumber: _number.text.trim(),
        );
      }
      if (!mounted) return;
      Navigator.of(context).pop();
      widget.onSuccess?.call();
      AppFeedback.success(
        widget.bank == null
            ? 'Đã thêm nơi nhận tiền'
            : 'Đã cập nhật nơi nhận tiền',
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = AppFeedback.messageFor(
          error,
          fallback: 'Không thể lưu thông tin. Vui lòng thử lại.',
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selected;
    final isMomo = selected?.kind == 'wallet';
    return PopScope(
      canPop: !_submitting,
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _review
                        ? 'Kiểm tra thông tin nhận tiền'
                        : widget.bank == null
                        ? 'Thêm nơi nhận tiền'
                        : 'Sửa nơi nhận tiền',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
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
              const SizedBox(height: 16),
              if (_review) ...[
                if (selected != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.pageTint,
                      borderRadius: AppDimensions.roundedCard,
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _BankLogo(code: selected.code),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    selected.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    isMomo
                                        ? 'Ví điện tử MoMo'
                                        : (selected.fullName.isNotEmpty
                                            ? selected.fullName
                                            : selected.name),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isMomo
                                    ? const Color(0xFFA50064).withValues(alpha: 0.1)
                                    : AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: AppDimensions.roundedPill,
                              ),
                              child: Text(
                                isMomo ? 'Ví MoMo' : 'Ngân hàng',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isMomo
                                      ? const Color(0xFFA50064)
                                      : AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Divider(
                            height: 1,
                            color: AppColors.borderSubtle,
                          ),
                        ),
                        Text(
                          isMomo ? 'Số điện thoại ví' : 'Số tài khoản',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _number.text,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          isMomo ? 'Tên chủ ví' : 'Tên chủ tài khoản',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _holder.text.trim().toUpperCase(),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.statusPendingBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          LucideIcons.info,
                          size: 16,
                          color: AppColors.statusPendingText,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Vui lòng kiểm tra kỹ. Tên chủ tài khoản do bạn tự khai và sẽ được duyệt trước khi rút tiền.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.statusPendingText,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          text: 'Chỉnh sửa',
                          variant: AppButtonVariant.outline,
                          onPressed: _submitting
                              ? null
                              : () => setState(() => _review = false),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AppButton(
                          text: 'Xác nhận lưu',
                          isLoading: _submitting,
                          onPressed: _save,
                        ),
                      ),
                    ],
                  ),
                ],
              ] else ...[
                const Text(
                  'Ngân hàng hoặc ví điện tử',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                InkWell(
                  onTap: _loadingBanks ? null : _chooseBank,
                  borderRadius: AppDimensions.roundedControl,
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 52),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: AppDimensions.roundedControl,
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Row(
                      children: [
                        if (selected != null) ...[
                          _BankLogo(code: selected.code),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  selected.name,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  isMomo
                                      ? 'Ví điện tử MoMo'
                                      : (selected.fullName.isNotEmpty
                                          ? selected.fullName
                                          : selected.name),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          Expanded(
                            child: Text(
                              _loadingBanks
                                  ? 'Đang tải danh sách…'
                                  : 'Chọn ngân hàng hoặc MoMo',
                              style: TextStyle(
                                fontSize: 14,
                                color: _loadingBanks
                                    ? AppColors.textSecondary
                                    : AppColors.textDisabled,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                        const Icon(
                          LucideIcons.chevronDown,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: _number,
                  label: isMomo ? 'Số điện thoại ví MoMo' : 'Số tài khoản',
                  hintText: widget.bank == null
                      ? (isMomo ? '0901234567' : 'Nhập số tài khoản')
                      : 'Nhập lại đầy đủ thông tin nhận tiền',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: _holder,
                  label: isMomo ? 'Tên chủ ví' : 'Tên chủ tài khoản',
                  hintText: 'NGUYEN VAN A',
                ),
                if (widget.bank != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Thông tin hiện tại •••• ${widget.bank!.lastFour}. Nhập lại số đầy đủ để sửa; thông tin mới cần được duyệt.',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                AppButton(
                  text: 'Kiểm tra thông tin',
                  onPressed: _loadingBanks ? null : _next,
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
            ],
          ),
        ),
      ),
    );
  }
}

class _BankLogo extends StatelessWidget {
  final String code;
  const _BankLogo({required this.code});

  @override
  Widget build(BuildContext context) {
    if (code.toUpperCase() == 'MOMO') {
      return Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: const Color(0xFFA50064),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFA50064).withValues(alpha: 0.25),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: const Text(
          'MoMo',
          style: TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.3,
          ),
        ),
      );
    }

    return Container(
      width: 38,
      height: 38,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Image.asset(
        'assets/images/banks/$code.png',
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => Center(
          child: Text(
            code.length > 4 ? code.substring(0, 4) : code,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _BankPickerSheet extends StatefulWidget {
  final List<BankOption> banks;
  const _BankPickerSheet({required this.banks});
  @override
  State<_BankPickerSheet> createState() => _BankPickerSheetState();
}

class _BankPickerSheetState extends State<_BankPickerSheet> {
  String _search = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String normalize(String value) => value.toLowerCase();
    final filtered = widget.banks
        .where(
          (bank) =>
              normalize('${bank.name} ${bank.fullName} ${bank.code}')
                  .contains(normalize(_search.trim())),
        )
        .toList();
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * .75,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Chọn ngân hàng hoặc MoMo',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppDimensions.roundedControl,
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      LucideIcons.search,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    suffixIcon: _search.isNotEmpty
                        ? IconButton(
                            icon: const Icon(LucideIcons.x, size: 16),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _search = '');
                            },
                          )
                        : null,
                    hintText: 'Tìm theo tên hoặc mã viết tắt…',
                    hintStyle: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textDisabled,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  onChanged: (value) => setState(() => _search = value),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              LucideIcons.searchX,
                              size: 36,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Không tìm thấy ngân hàng',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const Divider(
                          height: 1,
                          indent: 62,
                          color: AppColors.borderSubtle,
                        ),
                        itemBuilder: (context, index) {
                          final bank = filtered[index];
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            leading: _BankLogo(code: bank.code),
                            title: Text(
                              bank.name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            subtitle: Text(
                              bank.kind == 'wallet'
                                  ? 'Ví điện tử MoMo'
                                  : bank.fullName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            onTap: () => Navigator.of(context).pop(bank),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

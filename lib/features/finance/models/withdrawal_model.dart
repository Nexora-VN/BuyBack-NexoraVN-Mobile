class WithdrawalModel {
  final String id;
  final String amount;
  final String status;
  final String bankName;
  final String lastFour;
  final String createdAt;
  final String? reviewReason;

  WithdrawalModel({
    required this.id,
    required this.amount,
    required this.status,
    required this.bankName,
    required this.lastFour,
    required this.createdAt,
    this.reviewReason,
  });

  factory WithdrawalModel.fromJson(Map<String, dynamic> json) {
    final bank = json['bank'] as Map<String, dynamic>? ?? {};
    return WithdrawalModel(
      id: json['id']?.toString() ?? '',
      amount: json['amount']?.toString() ?? '0',
      status: json['status']?.toString() ?? 'PENDING',
      bankName: bank['bankName']?.toString() ?? 'Ngân hàng',
      lastFour: bank['lastFour']?.toString() ?? '••••',
      createdAt: json['createdAt']?.toString() ?? '',
      reviewReason: json['reviewReason']?.toString(),
    );
  }
}

class BankAccountModel {
  final String id;
  final String bankCode;
  final String bankName;
  final String accountHolder;
  final String? accountNumber;
  final String lastFour;
  final String status;
  final String? reviewReason;

  BankAccountModel({
    required this.id,
    required this.bankCode,
    required this.bankName,
    required this.accountHolder,
    this.accountNumber,
    required this.lastFour,
    required this.status,
    this.reviewReason,
  });

  factory BankAccountModel.fromJson(Map<String, dynamic> json) {
    return BankAccountModel(
      id: json['id']?.toString() ?? '',
      bankCode: json['bankCode']?.toString() ?? '',
      bankName: json['bankName']?.toString() ?? '',
      accountHolder: json['accountHolder']?.toString() ?? '',
      accountNumber: json['accountNumber']?.toString(),
      lastFour: json['lastFour']?.toString() ??
          (json['accountNumber'] != null && json['accountNumber'].toString().length >= 4
              ? json['accountNumber'].toString().substring(json['accountNumber'].toString().length - 4)
              : '••••'),
      status: json['status']?.toString() ?? 'PENDING',
      reviewReason: json['reviewReason']?.toString(),
    );
  }
}

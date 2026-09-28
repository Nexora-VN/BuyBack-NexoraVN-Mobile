class WalletTransactionModel {
  final String id;
  final String type;
  final String? availableDelta;
  final String? reservedDelta;
  final String? availableAfter;
  final String createdAt;

  WalletTransactionModel({
    required this.id,
    required this.type,
    this.availableDelta,
    this.reservedDelta,
    this.availableAfter,
    required this.createdAt,
  });

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) {
    return WalletTransactionModel(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'Giao dịch',
      availableDelta: json['availableDelta']?.toString(),
      reservedDelta: json['reservedDelta']?.toString(),
      availableAfter: json['availableAfter']?.toString(),
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }
}

import 'transaction_source_model.dart';

class WalletTransactionModel {
  final String id;
  final String type;
  final String? availableDelta;
  final String? reservedDelta;
  final String? availableAfter;
  final String createdAt;
  final TransactionSourceModel? source;

  WalletTransactionModel({
    required this.id,
    required this.type,
    this.availableDelta,
    this.reservedDelta,
    this.availableAfter,
    required this.createdAt,
    this.source,
  });

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) {
    return WalletTransactionModel(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'Giao dịch',
      availableDelta: json['availableDelta']?.toString(),
      reservedDelta: json['reservedDelta']?.toString(),
      availableAfter: json['availableAfter']?.toString(),
      createdAt: json['createdAt']?.toString() ?? '',
      source: json['source'] is Map<String, dynamic>
          ? TransactionSourceModel.fromJson(
              json['source'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

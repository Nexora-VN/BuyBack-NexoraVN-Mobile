import 'transaction_source_model.dart';

class CashbackModel {
  final String id;
  final String commissionId;
  final String userAmount;
  final String state;
  final String createdAt;
  final TransactionSourceModel? source;

  CashbackModel({
    required this.id,
    required this.commissionId,
    required this.userAmount,
    required this.state,
    required this.createdAt,
    this.source,
  });

  factory CashbackModel.fromJson(Map<String, dynamic> json) {
    final commission = json['commission'] as Map<String, dynamic>? ?? {};
    return CashbackModel(
      id: json['id']?.toString() ?? '',
      commissionId:
          commission['id']?.toString() ??
          json['commissionId']?.toString() ??
          '—',
      userAmount: json['userAmount']?.toString() ?? '0',
      state: json['state']?.toString() ?? 'PENDING',
      createdAt: json['createdAt']?.toString() ?? '',
      source: json['source'] is Map<String, dynamic>
          ? TransactionSourceModel.fromJson(
              json['source'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

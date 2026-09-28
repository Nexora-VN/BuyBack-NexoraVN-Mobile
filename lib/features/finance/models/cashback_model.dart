class CashbackModel {
  final String id;
  final String commissionId;
  final String userAmount;
  final String state;
  final String createdAt;

  CashbackModel({
    required this.id,
    required this.commissionId,
    required this.userAmount,
    required this.state,
    required this.createdAt,
  });

  factory CashbackModel.fromJson(Map<String, dynamic> json) {
    final commission = json['commission'] as Map<String, dynamic>? ?? {};
    return CashbackModel(
      id: json['id']?.toString() ?? '',
      commissionId: commission['id']?.toString() ?? json['commissionId']?.toString() ?? '—',
      userAmount: json['userAmount']?.toString() ?? '0',
      state: json['state']?.toString() ?? 'PENDING',
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }
}

class TransactionSourceModel {
  final TransactionOrderSource? order;
  final List<TransactionOrderSource> orders;
  final TransactionWithdrawalSource? withdrawal;

  const TransactionSourceModel({
    this.order,
    this.orders = const [],
    this.withdrawal,
  });

  factory TransactionSourceModel.fromJson(Map<String, dynamic> json) {
    final order = json['order'];
    final orders = json['orders'];
    final withdrawal = json['withdrawal'];
    return TransactionSourceModel(
      order: order is Map<String, dynamic>
          ? TransactionOrderSource.fromJson(order)
          : null,
      orders: orders is List
          ? orders
                .whereType<Map<String, dynamic>>()
                .map(TransactionOrderSource.fromJson)
                .toList()
          : const [],
      withdrawal: withdrawal is Map<String, dynamic>
          ? TransactionWithdrawalSource.fromJson(withdrawal)
          : null,
    );
  }
}

class TransactionOrderSource {
  final String id;
  final String orderSn;
  final String platform;
  final String? productName;

  const TransactionOrderSource({
    required this.id,
    required this.orderSn,
    required this.platform,
    this.productName,
  });

  factory TransactionOrderSource.fromJson(Map<String, dynamic> json) =>
      TransactionOrderSource(
        id: json['id']?.toString() ?? '',
        orderSn: json['orderSn']?.toString() ?? '',
        platform: json['platform']?.toString() ?? '',
        productName: json['productName']?.toString(),
      );
}

class TransactionWithdrawalSource {
  final String id;
  final String? bankName;
  final String? lastFour;

  const TransactionWithdrawalSource({
    required this.id,
    this.bankName,
    this.lastFour,
  });

  factory TransactionWithdrawalSource.fromJson(Map<String, dynamic> json) =>
      TransactionWithdrawalSource(
        id: json['id']?.toString() ?? '',
        bankName: json['bankName']?.toString(),
        lastFour: json['lastFour']?.toString(),
      );
}

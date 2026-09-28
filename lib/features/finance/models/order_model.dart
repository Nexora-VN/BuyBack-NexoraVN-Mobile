class OrderItem {
  final String? name;
  final String? imageUrl;
  final String? priceVnd;
  final int quantity;
  final String? variation;

  OrderItem({
    this.name,
    this.imageUrl,
    this.priceVnd,
    this.quantity = 1,
    this.variation,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      name: json['name']?.toString() ?? json['productName']?.toString(),
      imageUrl: json['imageUrl']?.toString() ?? json['image']?.toString(),
      priceVnd: json['priceVnd']?.toString() ?? json['itemPriceVnd']?.toString(),
      quantity: json['quantity'] is int
          ? json['quantity'] as int
          : int.tryParse(json['quantity']?.toString() ?? '1') ?? 1,
      variation: json['variation']?.toString() ?? json['itemModel']?.toString(),
    );
  }
}

class OrderModel {
  final String id;
  final String orderSn;
  final String status;
  final String platform;
  final String? totalAmountVnd;
  final String? purchasedAt;
  final String commissionState;
  final String? cashbackState;
  final String? cashbackAmount;
  final String productName;
  final String? productImageUrl;
  final int itemCount;
  final List<OrderItem> items;

  OrderModel({
    required this.id,
    required this.orderSn,
    required this.status,
    required this.platform,
    this.totalAmountVnd,
    this.purchasedAt,
    required this.commissionState,
    this.cashbackState,
    this.cashbackAmount,
    required this.productName,
    this.productImageUrl,
    this.itemCount = 1,
    this.items = const [],
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final checkout = json['checkout'] as Map<String, dynamic>? ?? {};
    final commission = checkout['commission'] as Map<String, dynamic>? ?? {};
    final cashback = commission['cashback'] as Map<String, dynamic>? ?? {};
    final productSummary = json['productSummary'] as Map<String, dynamic>? ?? {};

    final itemsRaw = json['items'] as List<dynamic>?;
    final itemsList = itemsRaw != null
        ? itemsRaw.map((e) => OrderItem.fromJson(e as Map<String, dynamic>)).toList()
        : <OrderItem>[];

    final pName = productSummary['name']?.toString() ??
        json['productName']?.toString() ??
        json['orderSn']?.toString() ??
        'Đơn hàng';

    return OrderModel(
      id: json['id']?.toString() ?? '',
      orderSn: json['orderSn']?.toString() ?? '—',
      status: json['status']?.toString() ?? 'PENDING',
      platform: productSummary['platform']?.toString() ??
          json['platform']?.toString() ??
          'Shopee',
      totalAmountVnd: json['totalAmountVnd']?.toString(),
      purchasedAt: checkout['purchasedAt']?.toString() ?? json['createdAt']?.toString(),
      commissionState: commission['state']?.toString() ?? 'ESTIMATED',
      cashbackState: cashback['state']?.toString(),
      cashbackAmount: cashback['userAmount']?.toString(),
      productName: pName,
      productImageUrl: productSummary['imageUrl']?.toString() ?? json['imageUrl']?.toString(),
      itemCount: productSummary['itemCount'] is int
          ? productSummary['itemCount'] as int
          : int.tryParse(productSummary['itemCount']?.toString() ?? '1') ?? 1,
      items: itemsList,
    );
  }
}

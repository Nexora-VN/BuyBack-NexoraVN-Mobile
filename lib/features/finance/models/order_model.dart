import '../../../core/utils/format_utils.dart';

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
    final payload = json['payload'] as Map<String, dynamic>? ?? {};

    final rawName = json['itemName'] ??
        json['item_name'] ??
        payload['item_name'] ??
        json['name'] ??
        json['productName'];

    final rawImage = json['image'] ??
        json['imageUrl'] ??
        payload['image'] ??
        json['productImage'] ??
        json['product_image'];

    final rawPrice = json['itemPriceRaw'] ??
        json['actualAmountRaw'] ??
        json['price'] ??
        payload['price'] ??
        json['priceVnd'] ??
        json['itemPriceVnd'];

    final rawQty = json['qty'] ?? json['quantity'] ?? payload['qty'] ?? 1;

    final rawVariation = json['variation'] ??
        json['itemModel'] ??
        payload['item_model'] ??
        json['modelName'];

    return OrderItem(
      name: rawName?.toString(),
      imageUrl: FormatUtils.normalizeImageUrl(rawImage?.toString()),
      priceVnd: rawPrice?.toString(),
      quantity: rawQty is int ? rawQty : int.tryParse(rawQty.toString()) ?? 1,
      variation: rawVariation?.toString(),
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
        (itemsList.isNotEmpty && itemsList.first.name != null
            ? itemsList.first.name!
            : (json['orderSn']?.toString() ?? 'Đơn hàng'));

    final rawProductImage = productSummary['imageUrl']?.toString() ??
        json['imageUrl']?.toString() ??
        (itemsList.isNotEmpty ? itemsList.first.imageUrl : null);

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
      productImageUrl: FormatUtils.normalizeImageUrl(rawProductImage),
      itemCount: productSummary['itemCount'] is int
          ? productSummary['itemCount'] as int
          : int.tryParse(productSummary['itemCount']?.toString() ?? '1') ??
              (itemsList.isNotEmpty ? itemsList.length : 1),
      items: itemsList,
    );
  }
}

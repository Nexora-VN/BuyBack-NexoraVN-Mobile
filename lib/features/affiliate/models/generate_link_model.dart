class ProductPreview {
  final String? itemId;
  final String? shopId;
  final String productName;
  final String? shopName;
  final String? imageUrl;
  final dynamic price;
  final dynamic commission;
  final dynamic rating;
  final dynamic historicalSold;
  final bool isExtra;

  ProductPreview({
    this.itemId,
    this.shopId,
    required this.productName,
    this.shopName,
    this.imageUrl,
    this.price,
    this.commission,
    this.rating,
    this.historicalSold,
    this.isExtra = false,
  });

  factory ProductPreview.fromJson(Map<String, dynamic> json) {
    return ProductPreview(
      itemId: json['itemId']?.toString(),
      shopId: json['shopId']?.toString(),
      productName: json['productName']?.toString() ??
          json['name']?.toString() ??
          'Sản phẩm',
      shopName: json['shopName']?.toString(),
      imageUrl: json['imageUrl']?.toString() ?? json['image']?.toString(),
      price: json['price'],
      commission: json['commission'] ?? json['maxCommission'],
      rating: json['rating'],
      historicalSold: json['historicalSold'],
      isExtra: json['isExtra'] == true,
    );
  }
}

class GenerateLinkResponse {
  final String? link;
  final String? code;
  final ProductPreview? product;

  GenerateLinkResponse({
    this.link,
    this.code,
    this.product,
  });

  factory GenerateLinkResponse.fromJson(Map<String, dynamic> json) {
    return GenerateLinkResponse(
      link: json['link'] as String?,
      code: json['code'] as String?,
      product: json['product'] != null
          ? ProductPreview.fromJson(json['product'] as Map<String, dynamic>)
          : null,
    );
  }
}

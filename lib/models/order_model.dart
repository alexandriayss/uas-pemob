class OrderModel {
  final int id;
  final int? userBeli;
  final int? userJual;
  final int productId;
  final int? totalPrice;
  final String paymentMethod;
  final String status;

  final String? shippingPhone;
  final String? shippingStreet;
  final String? shippingCity;
  final String? shippingState;
  final String? shippingPostalCode;
  final String? shippingCountry;

  final String createdAt;

  OrderModel({
    required this.id,
    this.userBeli,
    this.userJual,
    required this.productId,
    this.totalPrice,
    required this.paymentMethod,
    required this.status,
    this.shippingPhone,
    this.shippingStreet,
    this.shippingCity,
    this.shippingState,
    this.shippingPostalCode,
    this.shippingCountry,
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      userBeli: json['user_beli'],
      userJual: json['user_jual'],
      productId: json['product_id'],
      totalPrice: json['total_price'],
      paymentMethod: json['payment_method'] ?? '',
      status: json['status'] ?? '',
      shippingPhone: json['shipping_phone'],
      shippingStreet: json['shipping_street'],
      shippingCity: json['shipping_city'],
      shippingState: json['shipping_state'],
      shippingPostalCode: json['shipping_postal_code'],
      shippingCountry: json['shipping_country'],
      createdAt: json['created_at'] ?? '',
    );
  }
}


class OrderItem {
  final String productId;
  final String productName;
  final double price;
  final int quantity;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
  });

  double get totalPrice => price * quantity;

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'productName': productName,
    'price': price,
    'quantity': quantity,
  };

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    productId: json['productId'] as String,
    productName: json['productName'] as String,
    price: (json['price'] as num).toDouble(),
    quantity: json['quantity'] as int,
  );

  OrderItem copyWith({
    String? productId,
    String? productName,
    double? price,
    int? quantity,
  }) => OrderItem(
    productId: productId ?? this.productId,
    productName: productName ?? this.productName,
    price: price ?? this.price,
    quantity: quantity ?? this.quantity,
  );
}

class Order {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final double totalPrice;
  final String status; // pending, confirmed, shipped, delivered
  final DateTime createdAt;
  final String shippingAddress;
  final String shippingPhone;
  final String paymentMethod; // cash, card

  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    required this.shippingAddress,
    required this.shippingPhone,
    required this.paymentMethod,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'items': items.map((item) => item.toJson()).toList(),
    'totalPrice': totalPrice,
    'status': status,
    'createdAt': createdAt.toIso8601String(),
    'shippingAddress': shippingAddress,
    'shippingPhone': shippingPhone,
    'paymentMethod': paymentMethod,
  };

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: json['id'] as String,
    userId: json['userId'] as String,
    items: (json['items'] as List).map((item) => OrderItem.fromJson(item as Map<String, dynamic>)).toList(),
    totalPrice: (json['totalPrice'] as num).toDouble(),
    status: json['status'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    shippingAddress: json['shippingAddress'] as String,
    shippingPhone: json['shippingPhone'] as String,
    paymentMethod: json['paymentMethod'] as String,
  );
}

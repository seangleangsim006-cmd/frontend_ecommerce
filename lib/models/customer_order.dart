import 'package:widget_flutter/core/constants/api_url.dart';

class CustomerOrderItem {
  final int id;
  final int productId;
  final String productName;
  final int quantity;
  final double price;
  final String? productImage;

  CustomerOrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    this.productImage,
  });

  factory CustomerOrderItem.fromJson(Map<String, dynamic> json) {
    final product = json['product'] is Map<String, dynamic>
        ? json['product'] as Map<String, dynamic>
        : null;

    return CustomerOrderItem(
      id: json['id'] ?? 0,
      productId: json['product_id'] ?? product?['id'] ?? 0,
      productName: json['name'] ?? product?['name'] ?? 'Product',
      quantity: json['quantity'] ?? 1,
      price: _parseDouble(json['price']),
      productImage: product?['image'],
    );
  }

  static double _parseDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  double get total => price * quantity;
}



class CustomerOrder {
  final int id;
  final String status;
  final double total;
  final String? createdAt;
  final String restaurantName;
  final String? restaurantLogo;
  final List<CustomerOrderItem> items;

  CustomerOrder({
    required this.id,
    required this.status,
    required this.total,
    this.createdAt,
    required this.restaurantName,
    this.restaurantLogo,
    required this.items,
  });

  factory CustomerOrder.fromJson(Map<String, dynamic> json) {
    final restaurant = json['restaurant'] is Map<String, dynamic>
        ? json['restaurant'] as Map<String, dynamic>
        : null;
    final rawItems = json['items'] as List<dynamic>? ?? [];

    return CustomerOrder(
      id: json['id'],
      status: json['status'] ?? 'pending',
      total: CustomerOrderItem._parseDouble(json['total']),
      createdAt: json['created_at'],
      restaurantName: restaurant?['name'] ?? 'Restaurant',
      restaurantLogo: restaurant?['logo'],
      items: rawItems
          .map((e) => CustomerOrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  String? get restaurantLogoUrl {
    if (restaurantLogo == null || restaurantLogo!.isEmpty) return null;
    return ApiUrl.imageUrl(restaurantLogo);
  }

  bool get canConfirmDelivery {
    return status == 'accepted' || status == 'preparing';
  }

  bool get isActiveOrder {
    return ['pending', 'accepted', 'preparing'].contains(status);
  }

  bool get isHistoryOrder {
    return ['completed', 'cancelled'].contains(status);
  }
}

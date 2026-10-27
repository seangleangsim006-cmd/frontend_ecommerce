class MerchantOrderItem {
  final int productId;
  final String name;
  final int quantity;
  final double price;

  MerchantOrderItem({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.price,
  });

  factory MerchantOrderItem.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    final product = json['product'] is Map<String, dynamic>
        ? json['product'] as Map<String, dynamic>
        : null;

    return MerchantOrderItem(
      productId: json['product_id'] ?? json['id'] ?? (product?['id'] ?? 0),
      name: json['name'] ?? (product?['name'] ?? ''),
      quantity: json['quantity'] ?? 1,
      price: parseDouble(json['price']),
    );
  }
}

class MerchantOrder {
  final int id;
  final String? customerName;
  final List<MerchantOrderItem> items;
  final double total;
  final String status;
  final String? createdAt;

  MerchantOrder({
    required this.id,
    this.customerName,
    required this.items,
    required this.total,
    required this.status,
    this.createdAt,
  });

  factory MerchantOrder.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    return MerchantOrder(
      id: json['id'],
      customerName: json['customer_name'] ?? json['customer']?['name'],
      items: rawItems.map((e) => MerchantOrderItem.fromJson(e)).toList(),
      total: _parseDouble(json['total']),
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'],
    );
  }

  static double _parseDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  double get computedTotal {
    if (total > 0) return total;
    return items.fold(0.0, (sum, i) => sum + (i.price * i.quantity));
  }
}

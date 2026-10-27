import 'dart:io';

import 'package:widget_flutter/core/constants/api_url.dart';

class MerchantProduct {
  final int id;
  final String name;
  final String description;
  final double price;
  final String? _image;
  final bool isAvailable;
  final int? categoryId;
  final int? restaurantId;
  final int? stock;
  final File? imageFile;

  String get image => ApiUrl.imageUrl(_image);

  MerchantProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.isAvailable,
    this.categoryId,
    this.restaurantId,
    this.stock,
    this.imageFile,
    String? image,
  }) : _image = image;

  factory MerchantProduct.fromJson(Map<String, dynamic> json) {
    double parsePrice(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    int? parseInt(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString());
    }

    return MerchantProduct(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: parsePrice(json['price']),
      image: json['image'],
      isAvailable: json['is_available'] == 1 ||
          json['is_available'] == true ||
          json['is_available'] == '1',
      categoryId: parseInt(json['category_id']),
      restaurantId: parseInt(json['restaurant_id']),
      stock: parseInt(json['stock']),
    );
  }
}

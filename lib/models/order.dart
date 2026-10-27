import 'package:widget_flutter/core/constants/api_url.dart';

class Order {
   final int id;
  final String name;
  final String? description;
  final double price;
  final int categoryId;
  final int restaurantId;
  final String? _imageUrl;
  int qty;
  String? get imageUrl => ApiUrl.imageUrl(_imageUrl);

  Order({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.categoryId,
    required this.restaurantId,
    String? imageUrl,
    required this.qty
  }) : _imageUrl = imageUrl;

}
import 'package:widget_flutter/core/constants/api_url.dart';
import 'package:widget_flutter/models/category.dart';
import 'package:widget_flutter/models/restaurant.dart';

class Product {
  final int id;
  final int restaurantId;
  final int categoryId;
  final String name;
  final String description;
  final double price;
  final String _image;
  final bool isAvailable;
  final Restaurant restaurant;
  final Category category;

  String get image => ApiUrl.imageUrl(_image);

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.restaurant,
    required String image,
    required this.isAvailable,
    required this.restaurantId,
    required this.categoryId,
  }) : _image = image;
  factory Product.fromJson(Map<String,dynamic> json){
    return Product(
      id: json['id'], 
      name: json['name'], 
      price: double.parse(json['price'].toString()), 
      category: Category.fromJson(json['category']), 
      restaurant: Restaurant.fromJson(json['restaurant']),
      image: json['image'],
      isAvailable: json['is_available']==1,
      description: json['description'],
      categoryId: json['category_id'],
      restaurantId: json['restaurant_id']
    );
  }
}

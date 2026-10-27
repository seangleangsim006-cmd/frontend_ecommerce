import 'dart:io';

import 'package:widget_flutter/core/constants/api_url.dart';

class MerchantCategory {
  final int id;
  final String name;
  final String? _image;
  final int? restaurantId;
  final File? imageFile;

  String get image => ApiUrl.imageUrl(_image);

  MerchantCategory({
    required this.id,
    required this.name,
    String? image,
    this.restaurantId,
    this.imageFile,
  }) : _image = image;

  factory MerchantCategory.fromJson(Map<String, dynamic> json) {
    return MerchantCategory(
      id: json['id'],
      name: json['name'] ?? '',
      image: json['image'],
      restaurantId: json['restaurant_id'],
    );
  }
}

import 'package:widget_flutter/core/constants/api_url.dart';

class Category {
  final int id;
  final String name;
  final String _image;

  String get image => ApiUrl.imageUrl(_image);

  Category({required this.id, required this.name, required String image})
      : _image = image;

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      image: json['image'],
    );
  }
}

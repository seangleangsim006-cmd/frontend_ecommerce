import 'package:widget_flutter/core/constants/api_url.dart';

class Restaurant {
  final int id;
  final String name;
  final String address;
  final String? _logo;
  final List<String>? _tags;
  final double? _rating;
  final String? _deliveryTime;

  String get logoUrl => ApiUrl.imageUrl(_logo);
  List<String> get tags => _tags ?? [];
  double get rating => _rating ?? 4.5;
  String get deliveryTime => _deliveryTime ?? '30 min';

  Restaurant({
    required this.id,
    required this.name,
    required this.address,
    String? logo,
    List<String>? tags,
    double? rating,
    String? deliveryTime,
  })  : _logo = logo,
        _tags = tags,
        _rating = rating,
        _deliveryTime = deliveryTime;

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      logo: json['logo'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      rating: json['rating'] != null ? (json['rating'] is int ? json['rating'].toDouble() : json['rating'].toDouble()) : null,
      deliveryTime: json['delivery_time'],
    );
  }
}

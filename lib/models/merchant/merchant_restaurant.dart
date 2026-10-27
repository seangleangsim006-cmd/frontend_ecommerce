import 'package:widget_flutter/core/constants/api_url.dart';

class MerchantRestaurant {
  final int id;
  final String name;
  final String address;
  final String? _logo;
  final double? _rating;
  final String? _deliveryTime;
  final String? description;

  String? get logo => _logo;
  String get logoUrl => ApiUrl.imageUrl(_logo);
  double get rating => _rating ?? 0.0;
  String get deliveryTime => _deliveryTime ?? '30 min';

  MerchantRestaurant({
    required this.id,
    required this.name,
    required this.address,
    String? logo,
    double? rating,
    String? deliveryTime,
    this.description,
  })  : _logo = logo,
        _rating = rating,
        _deliveryTime = deliveryTime;

  factory MerchantRestaurant.fromJson(Map<String, dynamic> json) {
    return MerchantRestaurant(
      id: json['id'],
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      logo: json['logo'],
      rating: json['rating'] != null
          ? (json['rating'] is num
              ? (json['rating'] as num).toDouble()
              : double.tryParse(json['rating'].toString()))
          : null,
      deliveryTime: json['delivery_time'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'delivery_time': _deliveryTime,
      'description': description,
      if (_logo != null) 'logo': _logo,
    };
  }
}

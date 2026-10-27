import 'dart:convert';
import 'dart:io';

import 'package:widget_flutter/core/constants/api_url.dart';
import 'package:widget_flutter/models/merchant/merchant_category.dart';
import 'package:widget_flutter/models/merchant/merchant_order.dart';
import 'package:widget_flutter/models/merchant/merchant_product.dart';
import 'package:widget_flutter/models/merchant/merchant_restaurant.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart' show MultipartFile, MultipartRequest;

class MerchantService {
  static Map<String, String> _headers(String token) => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  static dynamic _parse(http.Response response) {
    final body = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (body is Map && body['success'] == false) {
        throw Exception(body['message'] ?? 'Request failed');
      }
      return body['data'] ?? body;
    } else {
      throw Exception(body['message'] ?? 'Request failed (${response.statusCode})');
    }
  }

  // Restaurant (own only)
  static Future<MerchantRestaurant?> getRestaurant(String token) async {
    final res = await http.get(
      Uri.parse('${ApiUrl.baseUrl}/merchant/restaurants'),
      headers: _headers(token),
    );
    if (res.statusCode == 404) {
      return null;
    }
    final body = jsonDecode(res.body);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = body is Map && body.containsKey('data') ? body['data'] : body;
      final list = data is List ? data : [data];
      if (list.isEmpty) return null;
      return MerchantRestaurant.fromJson(list.first);
    }
    if (body is Map && body['success'] == false && body['message'] == 'No restaurants found') {
      return null;
    }
    throw Exception(body['message'] ?? 'Request failed (${res.statusCode})');
  }

  static Future<MerchantRestaurant> createRestaurant(
    String token,
    MerchantRestaurant restaurant, {
    File? image,
  }) async {
    if (image == null) {
      final res = await http.post(
        Uri.parse('${ApiUrl.baseUrl}/merchant/restaurants'),
        headers: _headers(token),
        body: jsonEncode(restaurant.toJson()),
      );
      return MerchantRestaurant.fromJson(_parse(res));
    }

    final request = MultipartRequest(
      'POST',
      Uri.parse('${ApiUrl.baseUrl}/merchant/restaurants'),
    );
    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    request.fields.addAll({
      'name': restaurant.name,
      'address': restaurant.address,
      'delivery_time': restaurant.deliveryTime,
      if (restaurant.description != null && restaurant.description!.isNotEmpty)
        'description': restaurant.description!,
    });
    request.files.add(await MultipartFile.fromPath('logo', image.path));
    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    return MerchantRestaurant.fromJson(_parse(res));
  }

  static Future<MerchantRestaurant> updateRestaurant(
    String token,
    int id,
    MerchantRestaurant restaurant, {
    File? image,
  }) async {
    if (image == null) {
      final res = await http.put(
        Uri.parse('${ApiUrl.baseUrl}/merchant/restaurants/$id'),
        headers: _headers(token),
        body: jsonEncode(restaurant.toJson()),
      );
      return MerchantRestaurant.fromJson(_parse(res));
    }

    final request = MultipartRequest(
      'POST',
      Uri.parse('${ApiUrl.baseUrl}/merchant/restaurants/$id'),
    );
    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    request.fields['_method'] = 'PUT';
    request.fields.addAll({
      'name': restaurant.name,
      'address': restaurant.address,
      'delivery_time': restaurant.deliveryTime,
      if (restaurant.description != null && restaurant.description!.isNotEmpty)
        'description': restaurant.description!,
    });
    request.files.add(await MultipartFile.fromPath('logo', image.path));
    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    return MerchantRestaurant.fromJson(_parse(res));
  }

  // Categories
  static Future<List<MerchantCategory>> getCategories(String token) async {
    final res = await http.get(
      Uri.parse('${ApiUrl.baseUrl}/merchant/categories'),
      headers: _headers(token),
    );
    final data = _parse(res);
    final list = data is List ? data : [data];
    return list.map((e) => MerchantCategory.fromJson(e)).toList();
  }

  static Future<MerchantCategory> createCategory({
    required String token,
    required String name,
    required File image,
    int? restaurantId,
  }) async {
    final request = MultipartRequest(
      'POST',
      Uri.parse('${ApiUrl.baseUrl}/merchant/categories'),
    );
    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    request.fields['name'] = name;
    if (restaurantId != null) {
      request.fields['restaurant_id'] = restaurantId.toString();
    }
    request.files.add(
      await MultipartFile.fromPath('image', image.path),
    );
    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    return MerchantCategory.fromJson(_parse(res));
  }

  static Future<MerchantCategory> updateCategory({
    required String token,
    required int id,
    required String name,
    File? image,
  }) async {
    final request = MultipartRequest(
      'POST',
      Uri.parse('${ApiUrl.baseUrl}/merchant/categories/$id'),
    );
    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    request.fields['_method'] = 'PUT';
    request.fields['name'] = name;
    if (image != null) {
      request.files.add(
        await MultipartFile.fromPath('image', image.path),
      );
    }
    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    return MerchantCategory.fromJson(_parse(res));
  }

  static Future<void> deleteCategory(String token, int id) async {
    final res = await http.delete(
      Uri.parse('${ApiUrl.baseUrl}/merchant/categories/$id'),
      headers: _headers(token),
    );
    _parse(res);
  }

  // Products
  static Future<List<MerchantProduct>> getProducts(String token) async {
    final res = await http.get(
      Uri.parse('${ApiUrl.baseUrl}/merchant/products'),
      headers: _headers(token),
    );
    final data = _parse(res);
    final list = data is List ? data : [data];
    return list.map((e) => MerchantProduct.fromJson(e)).toList();
  }

  static Future<MerchantProduct> createProduct({
    required String token,
    required String name,
    required String description,
    required double price,
    required int categoryId,
    required bool isAvailable,
    required File image,
    int? restaurantId,
    int stock = 0,
  }) async {
    final request = MultipartRequest(
      'POST',
      Uri.parse('${ApiUrl.baseUrl}/merchant/products'),
    );
    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    request.fields['name'] = name;
    request.fields['description'] = description;
    request.fields['price'] = price.toString();
    request.fields['category_id'] = categoryId.toString();
    request.fields['is_available'] = isAvailable ? '1' : '0';
    request.fields['stock'] = stock.toString();
    if (restaurantId != null) {
      request.fields['restaurant_id'] = restaurantId.toString();
    }
    request.files.add(await MultipartFile.fromPath('image', image.path));
    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    return MerchantProduct.fromJson(_parse(res));
  }

  static Future<MerchantProduct> updateProduct({
    required String token,
    required int id,
    required String name,
    required String description,
    required double price,
    required int categoryId,
    required bool isAvailable,
    File? image,
    int stock = 0,
  }) async {
    final request = MultipartRequest(
      'POST',
      Uri.parse('${ApiUrl.baseUrl}/merchant/products/$id'),
    );
    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    request.fields['_method'] = 'PUT';
    request.fields['name'] = name;
    request.fields['description'] = description;
    request.fields['price'] = price.toString();
    request.fields['category_id'] = categoryId.toString();
    request.fields['is_available'] = isAvailable ? '1' : '0';
    request.fields['stock'] = stock.toString();
    if (image != null) {
      request.files.add(await MultipartFile.fromPath('image', image.path));
    }
    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    return MerchantProduct.fromJson(_parse(res));
  }

  static Future<void> deleteProduct(String token, int id) async {
    final res = await http.delete(
      Uri.parse('${ApiUrl.baseUrl}/merchant/products/$id'),
      headers: _headers(token),
    );
    _parse(res);
  }

  // Orders
  static Future<List<MerchantOrder>> getOrders(String token) async {
    final res = await http.get(
      Uri.parse('${ApiUrl.baseUrl}/merchant/orders'),
      headers: _headers(token),
    );
    final data = _parse(res);
    final List<dynamic> raw = data is List
        ? data
        : (data is Map && data['data'] is List)
            ? data['data'] as List<dynamic>
            : const [];
    return raw.map((e) => MerchantOrder.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<MerchantOrder> getOrder(String token, int id) async {
    final res = await http.get(
      Uri.parse('${ApiUrl.baseUrl}/merchant/orders/$id'),
      headers: _headers(token),
    );
    return MerchantOrder.fromJson(_parse(res));
  }

  static Future<MerchantOrder> updateOrderStatus(
    String token,
    int id,
    String status,
  ) async {
    final url = '${ApiUrl.baseUrl}/merchant/orders/$id/status';
    print('MerchantService: updating order $id to status "$status"');
    print('MerchantService: URL: $url');
    
    final res = await http.put(
      Uri.parse(url),
      headers: _headers(token),
      body: jsonEncode({'status': status}),
    );
    
    print('MerchantService: response status ${res.statusCode}');
    print('MerchantService: response body: ${res.body}');
    
    return MerchantOrder.fromJson(_parse(res));
  }
}

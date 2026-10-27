import 'dart:convert';

import 'package:widget_flutter/core/constants/api_url.dart';
import 'package:widget_flutter/models/category.dart';
import 'package:widget_flutter/models/customer_order.dart';
import 'package:widget_flutter/models/product.dart';
import 'package:http/http.dart'as http;
import 'package:widget_flutter/models/restaurant.dart';
class ProductService {
   static Future <List<Product>> fetchProduct()async{
    final response = await  http.get(Uri.parse("${ApiUrl.baseUrl}/customer/products"));
    if (response.statusCode == 200) {
    final Map<String, dynamic> body = jsonDecode(response.body);

    if (body['success'] == true) {
      final List<dynamic> data = body['data'];  // ⚠️ access 'data' key, not root
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception(body['message']);
    }
  } else {
    throw Exception('Failed to load products: ${response.statusCode}');
  }
}

  static Future<List<Category>> fetchCategory() async{
    final response = await  http.get(Uri.parse("${ApiUrl.baseUrl}/customer/categories"));
    if (response.statusCode == 200) {
    final Map<String, dynamic> body = jsonDecode(response.body);

    if (body['success'] == true) {
      final List<dynamic> data = body['data'];  // ⚠️ access 'data' key, not root
      return data.map((json) => Category.fromJson(json)).toList();
    } else {
      throw Exception(body['message']);
    }
  } else {
    throw Exception('Failed to load products: ${response.statusCode}');
  }
  }
  static Future<List<Restaurant>> fetchRestaurant() async{
    final response = await  http.get(Uri.parse("${ApiUrl.baseUrl}/customer/restaurants"));
    if (response.statusCode == 200) {
    final Map<String, dynamic> body = jsonDecode(response.body);

    if (body['success'] == true) {
      final List<dynamic> data = body['data'];  // ⚠️ access 'data' key, not root
      return data.map((json) => Restaurant.fromJson(json)).toList();
    } else {
      throw Exception(body['message']);
    }
  } else {
    throw Exception('Failed to load products: ${response.statusCode}');
  }
  }
  static Future<List<Product>> fetchProductsByCategory(int categoryId) async{
    final response = await  http.get(Uri.parse("${ApiUrl.baseUrl}/customer/categories/$categoryId/products"));
    if (response.statusCode == 200) {
    final Map<String, dynamic> body = jsonDecode(response.body);

    if (body['success'] == true) {
      final List<dynamic> data = body['data'];  // ⚠️ access 'data' key, not root
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception(body['message']);
    }
  } else {
    throw Exception('Failed to load products: ${response.statusCode}');
  }
  }
  static Future<Map<String, dynamic>> placeOrder({
    required int restaurantId,
    required List<Map<String, dynamic>> items,
    String? token,
  }) async {
    final headers = <String, String>{
      "Content-Type": "application/json",
      if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
    };
    final response = await http.post(
      Uri.parse("${ApiUrl.baseUrl}/customer/orders"),
      headers: headers,
      body: jsonEncode({
        "restaurant_id": restaurantId,
        "items": items,
      }),
    );
    try {
      final Map<String, dynamic> body = jsonDecode(response.body);
      if (response.statusCode == 201 && body['success'] == true) {
        return body;
      } else {
        throw Exception(body['message'] ?? 'Failed to place order');
      }
    } on FormatException {
      throw Exception('Server error: received HTML instead of JSON (status ${response.statusCode}). Raw response: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');
    }
  }

  static Future<List<CustomerOrder>> fetchCustomerOrders(String token) async {
    final response = await http.get(
      Uri.parse("${ApiUrl.baseUrl}/customer/orders"),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      if (body['success'] == true) {
        final List<dynamic> data = body['data'] ?? [];
        return data.map((json) => CustomerOrder.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw Exception(body['message'] ?? 'Failed to load orders');
      }
    } else {
      throw Exception('Failed to load orders: ${response.statusCode}');
    }
  }

  static Future<List<CustomerOrder>> fetchCustomerOrderHistory(String token) async {
    final response = await http.get(
      Uri.parse('${ApiUrl.baseUrl}/customer/orders/history'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      if (body['success'] == true) {
        final List<dynamic> data = body['data'] ?? [];
        return data.map((json) => CustomerOrder.fromJson(json as Map<String, dynamic>)).toList();
      }
      throw Exception(body['message'] ?? 'Failed to load order history');
    }

    throw Exception('Failed to load order history: ${response.statusCode}');
  }

  static Future<CustomerOrder> updateCustomerOrderStatus(
    String token,
    int id,
    String status,
  ) async {
    final response = await http.put(
      Uri.parse('${ApiUrl.baseUrl}/customer/orders/$id/status'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'status': status}),
    );

    final Map<String, dynamic> body = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300 && body['success'] == true) {
      return CustomerOrder.fromJson(body['data'] ?? body);
    }

    throw Exception(body['message'] ?? 'Failed to update order status');
  }
}
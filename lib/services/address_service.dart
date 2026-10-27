import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:widget_flutter/core/constants/api_url.dart';
import 'package:widget_flutter/models/address.dart';

class AddressService {
  static Map<String, String> _headers(String token) => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  static dynamic _data(http.Response response) {
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300 &&
        body['success'] != false) {
      return body['data'];
    }
    throw Exception(
      body['message'] ?? 'Address request failed (${response.statusCode})',
    );
  }

  static Future<List<Address>> getAddresses(String token) async {
    final response = await http.get(
      Uri.parse('${ApiUrl.baseUrl}/customer/addresses'),
      headers: _headers(token),
    );
    final data = _data(response);
    return (data as List<dynamic>)
        .map((item) => Address.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static Future<Address> createAddress(String token, Address address) async {
    final response = await http.post(
      Uri.parse('${ApiUrl.baseUrl}/customer/addresses'),
      headers: _headers(token),
      body: jsonEncode(address.toJson()),
    );
    return Address.fromJson(_data(response) as Map<String, dynamic>);
  }

  static Future<void> deleteAddress(String token, int id) async {
    final response = await http.delete(
      Uri.parse('${ApiUrl.baseUrl}/customer/addresses/$id'),
      headers: _headers(token),
    );
    _data(response);
  }

  static Future<Address> setDefault(String token, int id) async {
    final response = await http.put(
      Uri.parse('${ApiUrl.baseUrl}/customer/addresses/$id/default'),
      headers: _headers(token),
    );
    return Address.fromJson(_data(response) as Map<String, dynamic>);
  }
}
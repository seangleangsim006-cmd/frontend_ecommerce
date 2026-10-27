import 'dart:convert';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;
import 'package:widget_flutter/core/constants/api_url.dart';
import 'package:widget_flutter/models/khqr_payment.dart';

class PaymentServiceException implements Exception {
  final int statusCode;
  final String message;

  const PaymentServiceException(this.statusCode, this.message);

  @override
  String toString() => message;
}

class PaymentService {
  static Future<KhqrPayment> createKhqr({
    required int orderId,
    required String token,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiUrl.baseUrl}/customer/payment/khqr'),
      headers: _headers(token),
      body: jsonEncode({'order_id': orderId}),
    );
    return _parsePaymentResponse(response, 'Failed to create KHQR');
  }

  static Future<KhqrPayment> checkPayment({
    required int paymentId,
    required String token,
  }) async {
    if (token.trim().isEmpty) {
      throw Exception('Authentication token is missing. Please log in again.');
    }

    final response = await http.get(
      Uri.parse(
        '${ApiUrl.baseUrl}/customer/payment/$paymentId/check'
        '?payment_id=$paymentId',
      ),
      headers: _headers(token),
    );
    developer.log(
      'Payment check response for payment_id=$paymentId: '
      'HTTP ${response.statusCode} ${response.body}',
      name: 'PaymentService',
    );
    return _parsePaymentResponse(
      response,
      'Failed to check payment for payment_id=$paymentId',
    );
  }

  static Map<String, String> _headers(String token) => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  static KhqrPayment _parsePaymentResponse(
    http.Response response,
    String fallbackMessage,
  ) {
    final Map<String, dynamic> body;
    try {
      final decoded = jsonDecode(response.body);
      body = decoded is Map<String, dynamic>
          ? decoded
          : <String, dynamic>{'message': response.body};
    } on FormatException {
      throw PaymentServiceException(
        response.statusCode,
        '$fallbackMessage: server returned HTTP ${response.statusCode}: '
            '${response.body}',
      );
    }

    final data = body['data'];
    if (response.statusCode >= 200 &&
        response.statusCode < 300 &&
        body['success'] == true &&
        data is Map<String, dynamic>) {
      return KhqrPayment.fromJson(data);
    }
    final message = body['message']?.toString() ??
      body['error']?.toString() ??
      body['exception']?.toString();
    throw PaymentServiceException(
      response.statusCode,
      '$fallbackMessage: HTTP ${response.statusCode}'
          '${message == null || message.isEmpty ? '' : ' - $message'}',
    );
  }
}
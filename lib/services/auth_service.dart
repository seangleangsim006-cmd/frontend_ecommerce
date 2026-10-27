import 'dart:convert';

import 'package:widget_flutter/core/constants/api_url.dart';
import 'package:widget_flutter/models/user.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static Future<User> register({
    required String name,
    String? email,
    String? phone,
    required String password,
    String? profileImagePath,
  }) async {
    final request =
        http.MultipartRequest('POST', Uri.parse("${ApiUrl.baseUrl}/register"))
          ..headers['Accept'] = 'application/json'
          ..fields['name'] = name
          ..fields['password'] = password;

    if (email != null && email.isNotEmpty) request.fields['email'] = email;
    if (phone != null && phone.isNotEmpty) request.fields['phone'] = phone;
    if (profileImagePath != null && profileImagePath.isNotEmpty) {
      request.files.add(
        await http.MultipartFile.fromPath('profile_image', profileImagePath),
      );
    }

    final response = await http.Response.fromStream(await request.send());
    return _parseAuthResponse(response, 'Register');
  }

  static Future<void> sendOtp({required String phone}) async {
    final response = await http.post(
      Uri.parse("${ApiUrl.baseUrl}/send-otp"),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'phone': phone}),
    );
    _ensureSuccess(response, 'Send OTP');
  }

  static Future<User> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    final response = await http.post(
      Uri.parse("${ApiUrl.baseUrl}/verify-otp"),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'phone': phone, 'otp': otp}),
    );
    return _parseAuthResponse(response, 'Verify OTP');
  }

  static Future<User> login({
    String? email,
    String? phone,
    required String password,
  }) async {
    final body = <String, String>{'password': password};
    if (email != null && email.isNotEmpty) body['email'] = email;
    if (phone != null && phone.isNotEmpty) body['phone'] = phone;
    final response = await http.post(
      Uri.parse("${ApiUrl.baseUrl}/login"),
      headers: {
        'Accept': "application/json",
        'Content-Type': "application/json",
      },
      body: jsonEncode(body),
    );
    return _parseAuthResponse(response, 'Login');
  }

  static Future<String> forgotPassword({required String email}) async {
    final response = await http.post(
      Uri.parse("${ApiUrl.baseUrl}/forgot-password"),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'email': email}),
    );
    final decoded = _decodeResponse(response.body);
    if (response.statusCode == 200) {
      return decoded['message']?.toString() ??
          'If an account exists for this email, a password reset link has been sent';
    }
    throw Exception(
      decoded['message']?.toString() ?? 'Unable to send password reset link',
    );
  }

  static Future<String> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await http.post(
      Uri.parse("${ApiUrl.baseUrl}/reset-password"),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'token': token,
        'password': password,
        'password_confirmation': passwordConfirmation,
      }),
    );
    final decoded = _decodeResponse(response.body);
    if (response.statusCode == 200) {
      return decoded['message']?.toString() ?? 'Password reset successfully';
    }
    throw Exception(
      decoded['message']?.toString() ??
          'Invalid or expired password reset token',
    );
  }

  static User _parseAuthResponse(http.Response response, String action) {
    final decoded = _decodeResponse(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return User.fromJson(decoded);
    }
    throw Exception('$action failed: ${decoded['message'] ?? response.body}');
  }

  static void _ensureSuccess(http.Response response, String action) {
    if (response.statusCode != 200 && response.statusCode != 201) {
      final decoded = _decodeResponse(response.body);
      throw Exception('$action failed: ${decoded['message'] ?? response.body}');
    }
  }

  static Map<String, dynamic> _decodeResponse(String body) {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) return decoded;
    return {'message': body};
  }

  static Future<User> getProfile({required String token}) async {
    final response = await http.get(
      Uri.parse("${ApiUrl.baseUrl}/me"),
      headers: {'Accept': "application/json", 'Authorization': "Bearer $token"},
    );
    if (response.statusCode == 200) {
      final decoded = _decodeResponse(response.body);
      final data = decoded['data'] is Map<String, dynamic>
        ? decoded['data'] as Map<String, dynamic>
        : decoded;
      final userData = data['user'] is Map<String, dynamic>
        ? data['user'] as Map<String, dynamic>
        : data;
      return User(
        id: userData['id'],
        name: userData['name'],
        email: userData['email'],
        role: userData['role'],
        phone: userData['phone'],
        avatar: userData['avatar'] ?? userData['profile_image'],
      );
    } else {
      throw Exception("Failed to load profile: ${response.body}");
    }
  }

  static Future<Map<String, int>> getStats({required String token}) async {
    final response = await http.get(
      Uri.parse("${ApiUrl.baseUrl}/customer/stats"),
      headers: {'Accept': "application/json", 'Authorization': "Bearer $token"},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final stats = data['data'] ?? data;
      return {
        'orders': (stats['orders'] ?? stats['orders_count'] ?? 0) is int
            ? stats['orders'] ?? stats['orders_count']
            : int.tryParse(
                    '${stats['orders'] ?? stats['orders_count'] ?? 0}',
                  ) ??
                  0,
        'saved': (stats['saved'] ?? stats['saved_count'] ?? 0) is int
            ? stats['saved'] ?? stats['saved_count']
            : int.tryParse('${stats['saved'] ?? stats['saved_count'] ?? 0}') ??
                  0,
        'coupons': (stats['coupons'] ?? stats['coupons_count'] ?? 0) is int
            ? stats['coupons'] ?? stats['coupons_count']
            : int.tryParse(
                    '${stats['coupons'] ?? stats['coupons_count'] ?? 0}',
                  ) ??
                  0,
      };
    } else {
      return {'orders': 0, 'saved': 0, 'coupons': 0};
    }
  }

  static Future<void> logout({required String token}) async {
    final response = await http.post(
      Uri.parse("${ApiUrl.baseUrl}/logout"),
      headers: {'Accept': "application/json", 'Authorization': "Bearer $token"},
    );
    if (response.statusCode != 200) {
      throw Exception("Logout failed: ${response.body}");
    }
  }
}

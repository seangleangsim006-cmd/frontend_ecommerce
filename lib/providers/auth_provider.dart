import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:widget_flutter/models/user.dart';
import 'package:widget_flutter/services/auth_service.dart';
import 'package:widget_flutter/services/push_notification_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  String? _message;
  bool _loading = false;
  SharedPreferences? _prefs;
  Map<String, int> _stats = {'orders': 0, 'saved': 0, 'coupons': 0};

  User? get user => _user;
  String? get message => _message;
  bool? get loading => _loading;
  Map<String, int> get stats => _stats;

  Future<void> initPrefs() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      final token = _prefs?.getString('auth_token');
      print('initPrefs loaded token: $token');
      if (token != null && token.isNotEmpty) {
        _user = User(token: token);
        await _loadUserProfile(token);
        notifyListeners();
      }
    } catch (e) {
      print('initPrefs error: $e');
    }
  }

  Future<void> _loadUserProfile(String token) async {
    try {
      final user = await AuthService.getProfile(token: token);
      _user = User(
        id: user.id,
        name: user.name,
        email: user.email,
        token: _user?.token ?? token,
        role: user.role,
        avatar: user.avatar,
      );
      if (_user?.role == 'merchant') {
        try {
          await PushNotificationService.initialize(token);
        } catch (e) {
          print('Push notification setup error: $e');
        }
      }
      try {
        _stats = await AuthService.getStats(token: token);
      } catch (e) {
        print('Load stats error: $e');
        _stats = {'orders': 0, 'saved': 0, 'coupons': 0};
      }
      notifyListeners();
    } catch (e) {
      print('Load profile error: $e');
    }
  }

  String? get token => _user?.token;

  Future<void> _saveToken(String? token) async {
    if (_prefs == null) await initPrefs();
    if (token != null) {
      await _prefs?.setString('auth_token', token);
    } else {
      await _prefs?.remove('auth_token');
    }
  }

  Future<void> _clearToken() async {
    await _saveToken(null);
  }

  Future<void> register({
    required String name,
    String? email,
    String? phone,
    required String password,
    String? profileImagePath,
    bool saveToken = true,
  }) async {
    _loading = true;
    notifyListeners();
    try {
      _message = null;
      _user = await AuthService.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
        profileImagePath: profileImagePath,
      );
      if (saveToken) await _saveToken(_user?.token);
      _loading = false;
      notifyListeners();
    } catch (e) {
      _message = e.toString();
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> sendOtp({required String phone}) async {
    _loading = true;
    notifyListeners();
    try {
      _message = null;
      await AuthService.sendOtp(phone: phone);
      return true;
    } catch (e) {
      _message = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> verifyOtp({
    required String phone,
    required String otp,
    bool saveToken = true,
  }) async {
    _loading = true;
    notifyListeners();
    try {
      _message = null;
      _user = await AuthService.verifyOtp(phone: phone, otp: otp);
      if (saveToken) await _saveToken(_user?.token);
      return true;
    } catch (e) {
      _message = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> forgotPassword({required String email}) async {
    _loading = true;
    notifyListeners();
    try {
      _message = await AuthService.forgotPassword(email: email);
      return true;
    } catch (e) {
      _message = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    _loading = true;
    notifyListeners();
    try {
      _message = await AuthService.resetPassword(
        email: email,
        token: token,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      return true;
    } catch (e) {
      _message = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> login({
    String? email,
    String? phone,
    required String password,
  }) async {
    _loading = true;
    _user = null;
    notifyListeners();
    try {
      _message = null;
      _user = await AuthService.login(
        email: email,
        phone: phone,
        password: password,
      );
      print('Login success, token: ${_user?.token}');
      await _saveToken(_user?.token);
      if (_user?.token != null) {
        await _loadUserProfile(_user!.token!);
        if (_user?.role == 'merchant') {
          try {
            await PushNotificationService.initialize(_user!.token!);
          } catch (e) {
            print('Push notification setup error: $e');
          }
        }
      }
      print('Token saved');
    } catch (e) {
      _user = null;
      _message = e.toString();
      print('Login error: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      if (_user?.token != null) {
        await AuthService.logout(token: _user!.token!);
      }
    } catch (e) {
      print('Logout API error: $e');
    }
    _user = null;
    _message = null;
    await _clearToken();
    notifyListeners();
  }
}

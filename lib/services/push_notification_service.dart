import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:widget_flutter/core/constants/api_url.dart';
import 'package:widget_flutter/routes/app_router.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class PushNotificationService {
  PushNotificationService._();

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static StreamSubscription<String>? _tokenSubscription;
  static StreamSubscription<RemoteMessage>? _messageSubscription;
  static StreamSubscription<RemoteMessage>? _openedSubscription;
  static String? _pendingOrderId;

  static Future<void> initialize(String authToken) async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    final token = await _messaging.getToken();
    if (token != null) {
      await _registerToken(token, authToken);
    }

    await _tokenSubscription?.cancel();
    _tokenSubscription = _messaging.onTokenRefresh.listen(
      (newToken) => _registerToken(newToken, authToken),
    );

    await _messageSubscription?.cancel();
    _messageSubscription = FirebaseMessaging.onMessage.listen((message) {
      print('Push received: ${message.notification?.title}');
      print('Push data: ${message.data}');
    });

    await _openedSubscription?.cancel();
    _openedSubscription = FirebaseMessaging.onMessageOpenedApp.listen(_openOrder);

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _openOrder(initialMessage);
    }
  }

  static Future<void> _registerToken(String token, String authToken) async {
    final response = await http.post(
      Uri.parse('${ApiUrl.baseUrl}/fcm-tokens'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode({
        'token': token,
        'device_type': _deviceType,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('FCM token registration failed: ${response.body}');
    }
  }

  static String get _deviceType {
    return Platform.isIOS ? 'ios' : 'android';
  }

  static void _openOrder(RemoteMessage message) {
    final orderId = message.data['order_id']?.toString();
    if (orderId == null || orderId.isEmpty) return;
    if (appRouter.routerDelegate.navigatorKey.currentState == null) {
      _pendingOrderId = orderId;
      return;
    }
    appRouter.push('/merchant/orders/$orderId');
  }

  static void openPendingOrder() {
    final orderId = _pendingOrderId;
    _pendingOrderId = null;
    if (orderId != null && orderId.isNotEmpty) {
      appRouter.push('/merchant/orders/$orderId');
    }
  }
}
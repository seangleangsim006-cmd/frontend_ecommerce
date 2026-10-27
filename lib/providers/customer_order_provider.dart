import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:widget_flutter/models/customer_order.dart';
import 'package:widget_flutter/providers/auth_provider.dart';
import 'package:widget_flutter/services/product_service.dart';

class CustomerOrderProvider extends ChangeNotifier {
  List<CustomerOrder> _orders = [];
  List<CustomerOrder> _historyOrders = [];
  bool _loading = false;
  String? _message;
  Timer? _timer;

  List<CustomerOrder> get orders => _orders;
  List<CustomerOrder> get historyOrders => _historyOrders;
  bool get loading => _loading;
  String? get message => _message;

  Future<void> fetchOrders(AuthProvider auth) async {
    final token = auth.token;
    if (token == null || token.isEmpty) {
      _message = 'Not authenticated';
      notifyListeners();
      return;
    }

    _loading = true;
    _message = null;
    notifyListeners();

    try {
      _orders = await ProductService.fetchCustomerOrders(token);
    } catch (e) {
      _message = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> fetchOrderHistory(AuthProvider auth) async {
    final token = auth.token;
    if (token == null || token.isEmpty) {
      _message = 'Not authenticated';
      notifyListeners();
      return;
    }

    try {
      _historyOrders = await ProductService.fetchCustomerOrderHistory(token);
    } catch (e) {
      _message = e.toString();
    } finally {
      notifyListeners();
    }
  }

  Future<void> refresh(AuthProvider auth) async {
    await fetchOrders(auth);
    await fetchOrderHistory(auth);
  }

  Future<void> updateOrderStatus(AuthProvider auth, int id, String status) async {
    final token = auth.token;
    if (token == null || token.isEmpty) {
      _message = 'Not authenticated';
      notifyListeners();
      return;
    }

    _loading = true;
    notifyListeners();

    try {
      final apiStatus = status == 'delivered' ? 'completed' : status;
      await ProductService.updateCustomerOrderStatus(token, id, apiStatus);
      await fetchOrders(auth);
      await fetchOrderHistory(auth);
    } catch (e) {
      _message = e.toString();
      notifyListeners();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void startPolling(AuthProvider auth, {Duration interval = const Duration(seconds: 5)}) {
    _timer?.cancel();
    _timer = Timer.periodic(interval, (_) => fetchOrders(auth));
  }

  void stopPolling() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

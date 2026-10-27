import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:widget_flutter/models/merchant/merchant_category.dart';
import 'package:widget_flutter/models/merchant/merchant_order.dart';
import 'package:widget_flutter/models/merchant/merchant_product.dart';
import 'package:widget_flutter/models/merchant/merchant_restaurant.dart';
import 'package:widget_flutter/providers/auth_provider.dart';
import 'package:widget_flutter/services/merchant_service.dart';

class MerchantProvider extends ChangeNotifier {
  MerchantRestaurant? _restaurant;
  List<MerchantCategory> _categories = [];
  List<MerchantProduct> _products = [];
  List<MerchantOrder> _orders = [];

  bool _loading = false;
  String? _message;
  Timer? _timer;

  MerchantRestaurant? get restaurant => _restaurant;
  List<MerchantCategory> get categories => _categories;
  List<MerchantProduct> get products => _products;
  List<MerchantOrder> get orders => _orders;
  bool get loading => _loading;
  String? get message => _message;

  String _token(AuthProvider auth) {
    final token = auth.token;
    if (token == null || token.isEmpty) {
      throw Exception('Not authenticated');
    }
    return token;
  }

  Future<void> loadAll(AuthProvider auth) async {
    final token = _token(auth);
    _loading = true;
    _message = null;
    notifyListeners();
    try {
      _restaurant = await MerchantService.getRestaurant(token);
      _categories = await MerchantService.getCategories(token);
      _products = await MerchantService.getProducts(token);
      _orders = await MerchantService.getOrders(token);
    } catch (e) {
      _message = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> _wrap(Future<void> Function(String token) action, AuthProvider auth) async {
    final token = _token(auth);
    _loading = true;
    _message = null;
    notifyListeners();
    try {
      await action(token);
    } catch (e) {
      _message = e.toString();
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Restaurant
  Future<void> saveRestaurant(
    AuthProvider auth,
    MerchantRestaurant restaurant, {
    File? image,
  }) async {
    await _wrap((token) async {
      _restaurant = restaurant.id == 0
          ? await MerchantService.createRestaurant(token, restaurant, image: image)
          : await MerchantService.updateRestaurant(
              token,
              restaurant.id,
              restaurant,
              image: image,
            );
    }, auth);
  }

  // Categories
  Future<void> createCategory({
    required AuthProvider auth,
    required String name,
    required File image,
    int? restaurantId,
  }) async {
    await _wrap((token) async {
      await MerchantService.createCategory(
        token: token,
        name: name,
        image: image,
        restaurantId: restaurantId,
      );
      _categories = await MerchantService.getCategories(token);
    }, auth);
  }

  Future<void> updateCategory({
    required AuthProvider auth,
    required int id,
    required String name,
    File? image,
  }) async {
    await _wrap((token) async {
      await MerchantService.updateCategory(
        token: token,
        id: id,
        name: name,
        image: image,
      );
      _categories = await MerchantService.getCategories(token);
    }, auth);
  }

  Future<void> deleteCategory(AuthProvider auth, int id) async {
    await _wrap((token) async {
      await MerchantService.deleteCategory(token, id);
      _categories = await MerchantService.getCategories(token);
    }, auth);
  }

  // Products
  Future<void> createProduct({
    required AuthProvider auth,
    required String name,
    required String description,
    required double price,
    required int categoryId,
    required bool isAvailable,
    required File image,
    int? restaurantId,
    int stock = 0,
  }) async {
    await _wrap((token) async {
      await MerchantService.createProduct(
        token: token,
        name: name,
        description: description,
        price: price,
        categoryId: categoryId,
        isAvailable: isAvailable,
        image: image,
        restaurantId: restaurantId,
        stock: stock,
      );
      _products = await MerchantService.getProducts(token);
    }, auth);
  }

  Future<void> updateProduct({
    required AuthProvider auth,
    required int id,
    required String name,
    required String description,
    required double price,
    required int categoryId,
    required bool isAvailable,
    File? image,
    int stock = 0,
  }) async {
    await _wrap((token) async {
      await MerchantService.updateProduct(
        token: token,
        id: id,
        name: name,
        description: description,
        price: price,
        categoryId: categoryId,
        isAvailable: isAvailable,
        image: image,
        stock: stock,
      );
      _products = await MerchantService.getProducts(token);
    }, auth);
  }

  Future<void> deleteProduct(AuthProvider auth, int id) async {
    await _wrap((token) async {
      await MerchantService.deleteProduct(token, id);
      _products = await MerchantService.getProducts(token);
    }, auth);
  }

  Future<void> toggleProductAvailability(AuthProvider auth, MerchantProduct product) async {
    await _wrap((token) async {
      await MerchantService.updateProduct(
        token: token,
        id: product.id,
        name: product.name,
        description: product.description,
        price: product.price,
        categoryId: product.categoryId!,
        isAvailable: !product.isAvailable,
        stock: product.stock ?? 0,
      );
      _products = await MerchantService.getProducts(token);
    }, auth);
  }

  // Orders
  Future<void> updateOrderStatus(AuthProvider auth, int id, String status) async {
    await _wrap((token) async {
      await MerchantService.updateOrderStatus(token, id, status);
      _orders = await MerchantService.getOrders(token);
    }, auth);
  }

  Future<void> refreshOrders(AuthProvider auth) async {
    final token = _token(auth);
    _orders = await MerchantService.getOrders(token);
    notifyListeners();
  }

  Future<MerchantOrder> getOrder(String token, int id) {
    return MerchantService.getOrder(token, id);
  }

  void startPolling(AuthProvider auth, {Duration interval = const Duration(seconds: 3)}) {
    _timer?.cancel();
    _timer = Timer.periodic(interval, (_) => refreshOrders(auth));
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

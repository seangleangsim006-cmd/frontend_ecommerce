import 'package:flutter/foundation.dart';
import 'package:widget_flutter/models/product.dart';
import 'package:widget_flutter/models/restaurant.dart';

class SearchResult {
  final String type;
  final Product? product;
  final Restaurant? restaurant;

  SearchResult.product(this.product) : type = 'product', restaurant = null;
  SearchResult.restaurant(this.restaurant) : type = 'restaurant', product = null;
}

class SearchProvider extends ChangeNotifier {
  List<SearchResult> _results = [];
  List<SearchResult> get results => _results;

  List<Product> _matchProduct = [];
  List<Product> get matchProduct => _matchProduct;

  List<Restaurant> _matchRestaurant = [];
  List<Restaurant> get matchRestaurant => _matchRestaurant;

  void search(String query, List<Product> products, List<Restaurant> restaurants) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      _results = [];
      _matchProduct = [];
      _matchRestaurant = [];
    } else {
      _matchProduct = products
          .where((p) =>
              p.name.toLowerCase().contains(q) ||
              p.description.toLowerCase().contains(q))
          .toList();

      _matchRestaurant = restaurants
          .where((r) =>
              r.name.toLowerCase().contains(q) ||
              r.tags.any((t) => t.toLowerCase().contains(q)) ||
              r.address.toLowerCase().contains(q))
          .toList();

      _results = [
        ..._matchProduct.map((p) => SearchResult.product(p)),
        ..._matchRestaurant.map((r) => SearchResult.restaurant(r)),
      ];
    }
    notifyListeners();
  }

  void clear() {
    _results = [];
    _matchProduct = [];
    _matchRestaurant = [];
    notifyListeners();
  }
}

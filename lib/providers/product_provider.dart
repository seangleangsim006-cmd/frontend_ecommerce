
import 'package:flutter/material.dart';
import 'package:widget_flutter/models/product.dart';
import 'package:widget_flutter/models/restaurant.dart';
import 'package:widget_flutter/models/category.dart';
import 'package:widget_flutter/services/product_service.dart';

class ProductProvider extends ChangeNotifier{
  List<Product> _product =[];
  List<Category> _category =[];
  List<Restaurant> _restaurant=[];

  bool _isLoading=false;
  String? _message;

  List<Product> get product => _product;
  List<Category> get category => _category;
  List<Restaurant> get restaurant => _restaurant;
  bool get isLoading => _isLoading;
  String? get message => _message;

  Future<void> getProduct()async{
    _isLoading=true;
    notifyListeners();
    try{
      _product = await ProductService.fetchProduct();
      _message=null;
    }catch(e){
      _message=e.toString();
    }
    finally{
      _isLoading=false;
      notifyListeners();
    }
  }
   Future<void> getCategory()async{
    _isLoading=true;
    notifyListeners();
    try{
      _category = await ProductService.fetchCategory();
      _message=null;
    }catch(e){
      _message=e.toString();
    }
    finally{
      _isLoading=false;
      notifyListeners();
    }
  }
  Future<void> getRestaurant()async{
    _isLoading=true;
    notifyListeners();
    try{
      _restaurant = await ProductService.fetchRestaurant();
      _message=null;
    }catch(e){
      _message=e.toString();
    }
    finally{
      _isLoading=false;
      notifyListeners();
    }
  }
}
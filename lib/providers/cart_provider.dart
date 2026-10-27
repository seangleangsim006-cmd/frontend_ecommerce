import 'package:flutter/material.dart';
import 'package:widget_flutter/models/order.dart';

class CartProvider extends ChangeNotifier{
  List<Order> _cartItem =[];
  List<Order> get cartItem => _cartItem;

  void addToCart(Order order){
    _cartItem.add(
      Order(
        id: order.id, 
        name: order.name, 
        price: order.price, 
        categoryId: order.categoryId, 
        restaurantId: order.restaurantId,
        imageUrl: order.imageUrl,
        qty: order.qty
      )
    );
    notifyListeners();
  }

  void increment(int index){
    _cartItem[index].qty++;
    notifyListeners();
  }
  void decrement(int index){
    _cartItem[index].qty--;
    notifyListeners();
  }

  void removeAt(int index){
    _cartItem.removeAt(index);
    notifyListeners();
  }

  double total(){
    double sum=0;
    for(int i=0;i<_cartItem.length;i++){
       sum+=_cartItem[i].qty*_cartItem[i].price;
    }
    return sum;
  }

  void clear(){
    _cartItem.clear();
    notifyListeners();
  }

}

import 'package:flutter/material.dart';
import '../models/cart.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class CartProvider extends ChangeNotifier {
  final Cart _cart = Cart();

  List<CartItem> get items => _cart.items;

  int get itemCount => _cart.itemCount;

  double get totalPrice => _cart.totalPrice;

  bool get isEmpty => _cart.isEmpty();

  void addItem(Product product, int quantity) {
    if (quantity <= 0) return;
    
    final cartItem = CartItem(
      product: product,
      quantity: quantity,
    );
    
    _cart.addItem(cartItem);
    notifyListeners();
  }

  void removeItem(String productId) {
    _cart.removeItem(productId);
    notifyListeners();
  }

  void updateQuantity(String productId, int quantity) {
    _cart.updateQuantity(productId, quantity);
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  CartItem? getItem(String productId) {
    try {
      return _cart.items.firstWhere((item) => item.product.id == productId);
    } catch (e) {
      return null;
    }
  }

  int getQuantity(String productId) {
    final item = getItem(productId);
    return item?.quantity ?? 0;
  }

  @override
  String toString() => 'CartProvider($_cart)';
}

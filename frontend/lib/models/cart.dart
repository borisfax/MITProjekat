import 'cart_item.dart';

class Cart {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice => _items.fold(0, (sum, item) => sum + item.totalPrice);

  void addItem(CartItem item) {
    final existingIndex = _items.indexWhere((i) => i.product.id == item.product.id);
    
    if (existingIndex >= 0) {
      _items[existingIndex].quantity += item.quantity;
    } else {
      _items.add(item);
    }
  }

  void removeItem(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
  }

  void updateQuantity(String productId, int quantity) {
    final itemIndex = _items.indexWhere((i) => i.product.id == productId);
    
    if (itemIndex >= 0) {
      if (quantity <= 0) {
        _items.removeAt(itemIndex);
      } else {
        _items[itemIndex].quantity = quantity;
      }
    }
  }

  void clear() {
    _items.clear();
  }

  bool isEmpty() => _items.isEmpty;

  @override
  String toString() => 'Cart(items: ${_items.length}, total: $totalPrice RSD)';
}

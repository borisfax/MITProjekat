import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/order.dart';

class OrderProvider extends ChangeNotifier {
  final List<Order> _orders = [];
  bool _isLoading = false;

  List<Order> get orders => List.unmodifiable(_orders);
  bool get isLoading => _isLoading;

  OrderProvider() {
    _loadOrdersFromPreferences();
  }

  Future<void> _loadOrdersFromPreferences() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final ordersJson = prefs.getStringList('orders') ?? [];

      _orders.clear();
      for (final orderJson in ordersJson) {
        final orderMap = jsonDecode(orderJson) as Map<String, dynamic>;
        _orders.add(Order.fromJson(orderMap));
      }

      debugPrint('Loaded ${_orders.length} orders from preferences');
    } catch (e) {
      debugPrint('Error loading orders: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _saveOrdersToPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ordersJson =
          _orders.map((order) => jsonEncode(order.toJson())).toList();
      await prefs.setStringList('orders', ordersJson);
      debugPrint('Saved ${_orders.length} orders to preferences');
    } catch (e) {
      debugPrint('Error saving orders: $e');
    }
  }

  void addOrder(Order order) {
    _orders.insert(0, order); // Add to beginning (newest first)
    notifyListeners();
    _saveOrdersToPreferences();
    debugPrint('Order added: ${order.id}');
  }

  // Get orders for specific user
  List<Order> getUserOrders(String userId) {
    return _orders.where((order) => order.userId == userId).toList();
  }

  // Get all orders (for admin)
  List<Order> getAllOrders() => orders;

  // Update order status
  void updateOrderStatus(String orderId, String newStatus) {
    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index != -1) {
      final updatedOrder = Order(
        id: _orders[index].id,
        userId: _orders[index].userId,
        items: _orders[index].items,
        totalPrice: _orders[index].totalPrice,
        status: newStatus,
        createdAt: _orders[index].createdAt,
        shippingAddress: _orders[index].shippingAddress,
        shippingPhone: _orders[index].shippingPhone,
        paymentMethod: _orders[index].paymentMethod,
      );
      _orders[index] = updatedOrder;
      notifyListeners();
      _saveOrdersToPreferences();
      debugPrint('Order $orderId status updated to $newStatus');
    }
  }
}

import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/order.dart';

class OrderProvider extends ChangeNotifier {
  final List<Order> _orders = [];
  bool _isLoading = false;
  String? _error;
  final String _apiBaseUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: 'http://172.16.105.106:5000/api/orders');

  List<Order> get orders => List.unmodifiable(_orders);
  bool get isLoading => _isLoading;
  String? get error => _error;

  OrderProvider();

  Future<bool> createOrder({
    required Order order,
    required String authToken,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('🔵 Creating order to URL: $_apiBaseUrl');
      debugPrint('🔵 Auth Token: ${authToken.substring(0, 20)}...');
      
      final payload = {
        'items': order.items
            .map((item) => {
                  'productId': item.productId,
                  'productName': item.productName,
                  'price': item.price,
                  'quantity': item.quantity,
                })
            .toList(),
        'totalPrice': order.totalPrice,
        'shippingAddress': order.shippingAddress,
        'shippingPhone': order.shippingPhone,
        'paymentMethod': order.paymentMethod,
      };
      
      debugPrint('🔵 Payload: ${jsonEncode(payload)}');

      final response = await http.post(
        Uri.parse(_apiBaseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(payload),
      );

      debugPrint('🔵 Response status: ${response.statusCode}');
      debugPrint('🔵 Response body: ${response.body}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['success'] == true && data['data'] != null) {
          final createdOrder = Order.fromJson(data['data']);
          _orders.insert(0, createdOrder);
          notifyListeners();
          debugPrint('✅ Order created: ${createdOrder.id}');
          _isLoading = false;
          return true;
        }
      } else if (response.statusCode == 401) {
        _error = 'Неаутентификовани приступ';
        debugPrint('❌ 401 Unauthorized');
      } else if (response.statusCode == 400) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        _error = data['message'] ?? 'Грешка валидације';
        debugPrint('❌ 400 Validation error: $_error');
      } else {
        _error = 'Грешка при креирању наружбине (${response.statusCode})';
        debugPrint('❌ ${response.statusCode} Error');
      }
    } catch (e) {
      _error = 'Грешка конекције: $e';
      debugPrint('❌ EXCEPTION Error creating order: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> fetchUserOrders({
    required String userId,
    required String authToken,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$_apiBaseUrl/user/$userId'),
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['success'] == true && data['data'] != null) {
          final ordersList = (data['data'] as List)
              .map((orderJson) => Order.fromJson(orderJson as Map<String, dynamic>))
              .toList();
          _orders.clear();
          _orders.addAll(ordersList);
          debugPrint('Loaded ${_orders.length} orders from API');
        }
      } else if (response.statusCode == 401) {
        _error = 'Неаутентификовани приступ';
      } else if (response.statusCode == 403) {
        _error = 'Немате приступ овим наружбинама';
      } else {
        _error = 'Грешка при учитавању наружбина';
      }
    } catch (e) {
      _error = 'Грешка конекције: $e';
      debugPrint('Error fetching orders: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Get orders for specific user (local)
  List<Order> getUserOrders(String userId) {
    return _orders.where((order) => order.userId == userId).toList();
  }

  // Get all orders (for admin)
  List<Order> getAllOrders() => orders;
}

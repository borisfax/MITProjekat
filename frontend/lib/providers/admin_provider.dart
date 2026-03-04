import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/order.dart';
import '../models/user.dart';

class AdminProvider extends ChangeNotifier {
  // Orders
  final List<Order> _allOrders = [];
  
  // Users
  final List<User> _allUsers = [];
  
  // Stats
  int _totalOrders = 0;
  int _totalUsers = 0;
  
  // Loading and error states
  bool _isLoading = false;
  String? _error;
  
  static const String apiBaseUrl = 'http://172.16.106.11:5000/api';

  // Getters
  List<Order> get allOrders => List.unmodifiable(_allOrders);
  List<User> get allUsers => List.unmodifiable(_allUsers);
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalOrders => _totalOrders;
  int get totalUsers => _totalUsers;

  // ============ ORDERS ============

  /// Preuzmi sve narudžbe (admin only)
  Future<bool> fetchAllOrders({
    required String authToken,
    String? status,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      String url = '$apiBaseUrl/orders';
      if (status != null && status.isNotEmpty) {
        url += '?status=$status';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      debugPrint('📋 Fetch all orders status: ${response.statusCode}');
      debugPrint('📋 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        debugPrint('📋 Server returned success: ${data['success']}');
        debugPrint('📋 Orders count from server: ${data['count']}');
        
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> ordersJson = data['data'] as List<dynamic>;
          debugPrint('📋 Total orders received: ${ordersJson.length}');
          
          _allOrders.clear();
          for (int i = 0; i < ordersJson.length; i++) {
            try {
              final order = Order.fromJson(ordersJson[i] as Map<String, dynamic>);
              debugPrint('📋 Order $i: ID=${order.id}, status=${order.status}');
              _allOrders.add(order);
            } catch (e) {
              debugPrint('❌ Error converting order $i: $e');
            }
          }
          
          _totalOrders = _allOrders.length;
          debugPrint('📋 Successfully loaded ${_totalOrders} orders');
          _isLoading = false;
          notifyListeners();
          return true;
        }
      } else if (response.statusCode == 403) {
        _error = 'Немате администраторске привилегије';
      } else {
        _error = 'Грешка при учитавању наруџби: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Грешка конекције: $e';
      debugPrint('❌ Error fetching orders: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Ажурирај статус наруџбе
  Future<bool> updateOrderStatus({
    required String orderId,
    required String status,
    required String authToken,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
        debugPrint('📋 UPDATE ORDER REQUEST: orderId=$orderId, newStatus=$status');
        debugPrint('📋 Token: ${authToken.substring(0, 20)}...');
      final response = await http.put(
        Uri.parse('$apiBaseUrl/orders/$orderId/status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({'status': status}),
      );

      debugPrint('📋 Update order status: ${response.statusCode}');
        debugPrint('📋 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['success'] == true && data['data'] != null) {
          final updatedOrder = Order.fromJson(data['data'] as Map<String, dynamic>);
          
          // Ažuriraj u listi
          final index = _allOrders.indexWhere((o) => o.id == orderId);
          if (index != -1) {
            _allOrders[index] = updatedOrder;
          }
          
          _isLoading = false;
          notifyListeners();
          return true;
        }
      } else if (response.statusCode == 403) {
        _error = 'Немате администраторске привилегије';
          debugPrint('❌ Greška 403: ${response.body}');
      } else {
        _error = 'Грешка при ажурирању статуса: ${response.statusCode}';
          debugPrint('❌ Error response: ${response.body}');
      }
    } catch (e) {
      _error = 'Грешка конекције: $e';
      debugPrint('❌ Error updating order status: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // ============ USERS ============

  /// Preuzmi sve korisnike (admin only)
  Future<bool> fetchAllUsers({
    required String authToken,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/users'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      debugPrint('👥 Fetch all users status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> usersJson = data['data'] as List<dynamic>;
          _allUsers.clear();
          _allUsers.addAll(
            usersJson.map((json) => User.fromJson(json as Map<String, dynamic>)),
          );
          _totalUsers = _allUsers.length;
          _isLoading = false;
          notifyListeners();
          return true;
        }
      } else if (response.statusCode == 403) {
        _error = 'Немате администраторске привилегије';
      } else {
        _error = 'Грешка при учитавању корисника: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Грешка конекције: $e';
      debugPrint('❌ Error fetching users: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Ažuriraj korisnika (admin only)
  Future<bool> updateUser({
    required String userId,
    required String name,
    required String email,
    required String role,
    String? phone,
    String? address,
    required String authToken,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('✏️  UPDATE USER REQUEST: userId=$userId');
      debugPrint('✏️  Data: name=$name, email=$email, role=$role');
      debugPrint('✏️  Token: ${authToken.substring(0, 20)}...');
      
      final payload = {
        'name': name,
        'email': email,
        'role': role,
        if (phone != null) 'phone': phone,
        if (address != null) 'address': address,
      };

      final response = await http.put(
        Uri.parse('$apiBaseUrl/users/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(payload),
      );

      debugPrint('✏️  Update user status: ${response.statusCode}');
      debugPrint('✏️  Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        debugPrint('✏️  Response data: $data');
        if (data['success'] == true && data['data'] != null) {
          final updatedUser = User.fromJson(data['data'] as Map<String, dynamic>);
          
          final index = _allUsers.indexWhere((u) => u.id == userId);
          if (index != -1) {
            _allUsers[index] = updatedUser;
          }
          
          _isLoading = false;
          notifyListeners();
          return true;
        }
      } else if (response.statusCode == 403) {
        _error = 'Немате администраторске привилегије';
        debugPrint('❌ Greška 403: ${response.body}');
      } else if (response.statusCode == 401) {
        _error = 'Истекло време сесије. Пријавите се поново.';
        debugPrint('❌ Greška 401: ${response.body}');
      } else if (response.statusCode == 404) {
        _error = 'Корисник није пронађен';
        debugPrint('❌ Greška 404: ${response.body}');
      } else {
        _error = 'Грешка при ажурирању корисника: ${response.statusCode}';
        debugPrint('❌ Error response: ${response.body}');
      }
    } catch (e) {
      _error = 'Грешка конекције: $e';
      debugPrint('❌ Error updating user: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Obriši korisnika (admin only)
  Future<bool> deleteUser({
    required String userId,
    required String authToken,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('🗑️  DELETE REQUEST: userId=$userId');
      debugPrint('🗑️  Token: ${authToken.substring(0, 20)}...');
      
      final response = await http.delete(
        Uri.parse('$apiBaseUrl/users/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      debugPrint('🗑️  Delete user status: ${response.statusCode}');
      debugPrint('🗑️  Response body: ${response.body}');

      if (response.statusCode == 200) {
        debugPrint('✅ User deleted successfully');
        _allUsers.removeWhere((u) => u.id == userId);
        _totalUsers = _allUsers.length;
        _isLoading = false;
        notifyListeners();
        return true;
      } else if (response.statusCode == 403) {
        _error = 'Немате администраторске привилегије';
        debugPrint('❌ Greška 403: ${response.body}');
      } else if (response.statusCode == 401) {
        _error = 'Истекло време сесије. Пријавите се поново.';
        debugPrint('❌ Greška 401: ${response.body}');
      } else if (response.statusCode == 404) {
        _error = 'Корисник није пронађен';
        debugPrint('❌ Greška 404: ${response.body}');
      } else {
        _error = 'Грешка при брисању корисника: ${response.statusCode}';
        debugPrint('❌ Error response: ${response.body}');
      }
    } catch (e) {
      _error = 'Грешка конекције: $e';
      debugPrint('❌ Error deleting user: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }
}

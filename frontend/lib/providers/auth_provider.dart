import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;

  // Mock user database (u produkciji bi ovo bilo iz backend API-ja)
  final List<Map<String, String>> _mockUsers = [];

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  bool get isAdmin => _currentUser?.role == 'admin';

  AuthProvider() {
    _loadUserFromPreferences();
  }

  // Load user from SharedPreferences on app start
  Future<void> _loadUserFromPreferences() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('currentUser');
      
      if (userJson != null) {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        _currentUser = User.fromJson(userMap);
      }
    } catch (e) {
      debugPrint('Error loading user: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save user to SharedPreferences
  Future<void> _saveUserToPreferences(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = jsonEncode(user.toJson());
      await prefs.setString('currentUser', userJson);
    } catch (e) {
      debugPrint('Error saving user: $e');
    }
  }

  // Clear user from SharedPreferences
  Future<void> _clearUserFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('currentUser');
    } catch (e) {
      debugPrint('Error clearing user: $e');
    }
  }

  // Register new user
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? address,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Check if user already exists
      final existingUser = _mockUsers.firstWhere(
        (user) => user['email'] == email,
        orElse: () => {},
      );

      if (existingUser.isNotEmpty) {
        _isLoading = false;
        notifyListeners();
        return false; // User already exists
      }

      // Create new user
      final userId = DateTime.now().millisecondsSinceEpoch.toString();
      _mockUsers.add({
        'id': userId,
        'name': name,
        'email': email,
        'password': password,
        'role': 'user',
        'phone': phone ?? '',
        'address': address ?? '',
      });

      // Auto-login after registration
      _currentUser = User(
        id: userId,
        name: name,
        email: email,
        role: 'user',
        phone: phone,
        address: address,
      );

      await _saveUserToPreferences(_currentUser!);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error during registration: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Login user
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Find user in mock database
      final user = _mockUsers.firstWhere(
        (user) => user['email'] == email && user['password'] == password,
        orElse: () => {},
      );

      if (user.isEmpty) {
        _isLoading = false;
        notifyListeners();
        return false; // Invalid credentials
      }

      // Login successful
      _currentUser = User(
        id: user['id']!,
        name: user['name']!,
        email: user['email']!,
        role: user['role']!,
        phone: user['phone']!.isEmpty ? null : user['phone'],
        address: user['address']!.isEmpty ? null : user['address'],
      );

      await _saveUserToPreferences(_currentUser!);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error during login: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout user
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _clearUserFromPreferences();
      _currentUser = null;
    } catch (e) {
      debugPrint('Error during logout: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update user profile
  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? address,
  }) async {
    if (_currentUser == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = _currentUser!.copyWith(
        name: name,
        phone: phone,
        address: address,
      );

      // Update in mock database
      final userIndex = _mockUsers.indexWhere(
        (user) => user['id'] == _currentUser!.id,
      );
      
      if (userIndex >= 0) {
        _mockUsers[userIndex] = {
          'id': _currentUser!.id,
          'name': _currentUser!.name,
          'email': _currentUser!.email,
          'password': _mockUsers[userIndex]['password']!,
          'role': _currentUser!.role,
          'phone': _currentUser!.phone ?? '',
          'address': _currentUser!.address ?? '',
        };
      }

      await _saveUserToPreferences(_currentUser!);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error updating profile: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  @override
  String toString() => 'AuthProvider(user: $_currentUser, authenticated: $isAuthenticated)';
}

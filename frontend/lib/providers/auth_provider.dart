import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  String? _authToken;
  bool _isLoading = false;
  bool _isGuest = false;
  String? _errorMessage;

  // Backend API URL
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:5000/api/auth',
  );

  User? get currentUser => _currentUser;
  String? get authToken => _authToken;
  bool get isAuthenticated => _currentUser != null && _authToken != null;
  bool get isGuest => _isGuest;
  bool get isLoading => _isLoading;
  bool get isAdmin => _currentUser?.role == 'admin';
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _loadUserFromPreferences();
  }

  // Load user and token from SharedPreferences on app start
  Future<void> _loadUserFromPreferences() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('currentUser');
      final token = prefs.getString('authToken');
      
      if (userJson != null && token != null) {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        _currentUser = User.fromJson(userMap);
        _authToken = token;
      }
    } catch (e) {
      debugPrint('Error loading user: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save user and token to SharedPreferences
  Future<void> _saveUserToPreferences(User user, String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = jsonEncode(user.toJson());
      await prefs.setString('currentUser', userJson);
      await prefs.setString('authToken', token);
    } catch (e) {
      debugPrint('Error saving user: $e');
    }
  }

  // Clear user and token from SharedPreferences
  Future<void> _clearUserFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('currentUser');
      await prefs.remove('authToken');
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
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'phone': phone ?? '',
          'address': address ?? '',
        }),
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        
        if (responseData['success']) {
          final userData = responseData['data']['user'];
          final token = responseData['data']['token'];

          // Auto-login after registration
          _currentUser = User(
            id: userData['id'],
            name: userData['name'],
            email: userData['email'],
            role: userData['role'] ?? 'user',
            phone: userData['phone']?.isEmpty ?? true ? null : userData['phone'],
            address: userData['address']?.isEmpty ?? true ? null : userData['address'],
          );

          _authToken = token;
          await _saveUserToPreferences(_currentUser!, token);

          _isLoading = false;
          notifyListeners();
          return true;
        }
      } else {
        final errorData = jsonDecode(response.body);
        _errorMessage = errorData['message'] ?? 'Greška pri registraciji';
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('Error during registration: $e');
      _errorMessage = 'Greška pri povezivanju sa serverom: $e';
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
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        if (responseData['success']) {
          final userData = responseData['data']['user'];
          final token = responseData['data']['token'];

          _currentUser = User(
            id: userData['id'],
            name: userData['name'],
            email: userData['email'],
            role: userData['role'] ?? 'user',
            phone: userData['phone']?.isEmpty ?? true ? null : userData['phone'],
            address: userData['address']?.isEmpty ?? true ? null : userData['address'],
          );

          _authToken = token;
          await _saveUserToPreferences(_currentUser!, token);

          _isLoading = false;
          notifyListeners();
          return true;
        }
      } else {
        final errorData = jsonDecode(response.body);
        _errorMessage = errorData['message'] ?? 'Pogrešan email ili lozinka';
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('Error during login: $e');
      _errorMessage = 'Greška pri povezivanju sa serverom: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Login as guest
  void loginAsGuest() {
    _isGuest = true;
    _currentUser = null;
    _authToken = null;
    notifyListeners();
  }

  // Logout user
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _clearUserFromPreferences();
      _currentUser = null;
      _authToken = null;
      _isGuest = false;
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
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = _currentUser!.copyWith(
        name: name,
        phone: phone,
        address: address,
      );

      await _saveUserToPreferences(_currentUser!, _authToken!);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error updating profile: $e');
      _errorMessage = 'Greška pri ažuriranju profila';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  @override
  String toString() => 'AuthProvider(user: $_currentUser, authenticated: $isAuthenticated)';
}

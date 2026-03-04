import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ProductProvider extends ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;
  final String _apiBaseUrl = 
      String.fromEnvironment('API_BASE_URL', defaultValue: 'http://172.16.106.11:5000/api/products');

  List<Product> get products => List.unmodifiable(_products);
  bool get isLoading => _isLoading;
  String? get error => _error;

  ProductProvider() {
    // Auto-fetch products on initialization
    fetchProducts();
  }

  // Fetch all products from API
  Future<void> fetchProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('🔵 Fetching products from: $_apiBaseUrl');
      
      final response = await http.get(
        Uri.parse(_apiBaseUrl),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      debugPrint('🔵 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> productsJson = data['data'];
          _products = productsJson.map((json) => Product.fromJson(json)).toList();
          
          debugPrint('✅ Loaded ${_products.length} products from API');
          _error = null;
        } else {
          _error = 'Greška pri učitavanju proizvoda';
          debugPrint('❌ API returned success=false');
        }
      } else {
        _error = 'Greška pri učitavanju proizvoda (${response.statusCode})';
        debugPrint('❌ Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      _error = 'Greška pri povezivanju sa serverom';
      debugPrint('❌ Exception while fetching products: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get products by category
  List<Product> getProductsByCategory(String category) {
    if (category == 'All') {
      return _products;
    }
    return _products.where((product) => product.category == category).toList();
  }

  // Get single product by ID
  Product? getProductById(String id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  // Search products
  List<Product> searchProducts(String query) {
    if (query.isEmpty) return _products;
    
    final lowerQuery = query.toLowerCase();
    return _products.where((product) {
      return product.name.toLowerCase().contains(lowerQuery) ||
             product.description.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // Filter available products
  List<Product> get availableProducts {
    return _products.where((product) => product.inStock).toList();
  }
}

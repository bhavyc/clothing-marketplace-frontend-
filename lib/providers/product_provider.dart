import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';

class ProductProvider with ChangeNotifier {
  final ProductService _productService = ProductService();

  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  List<String> _categories = [];
  List<String> _collections = [];
  bool _isLoading = false;
  String _selectedCategory = '';
  String _selectedCollection = '';
  String _searchQuery = '';
  String _selectedSort = ''; // 'price_low_to_high', 'price_high_to_low', or ''

  List<Product> get products => _products;
  List<Product> get filteredProducts => _filteredProducts;
  List<String> get categories => _categories;
  List<String> get collections => _collections;
  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;
  String get selectedCollection => _selectedCollection;
  String get selectedSort => _selectedSort;

  ProductProvider() {
    loadCatalog();
  }

  // Load catalog list and categories navigation metadata
  Future<void> loadCatalog() async {
    _isLoading = true;
    notifyListeners();

    // 1. Fetch products lists
    _products = await _productService.fetchProducts();
    applyFilters();

    // 2. Fetch categories and collections navigation data
    final nav = await _productService.fetchNavigationData();
    _categories = nav['categories'] ?? [];
    _collections = nav['collections'] ?? [];

    _isLoading = false;
    notifyListeners();
  }

  // Filter and sort local array dynamically
  void applyFilters({
    String? category,
    String? collection,
    String? search,
    String? sort,
  }) {
    if (category != null) _selectedCategory = category;
    if (collection != null) _selectedCollection = collection;
    if (search != null) _searchQuery = search.toLowerCase().trim();
    if (sort != null) _selectedSort = sort;

    // Filter
    List<Product> results = _products.where((product) {
      final matchesCategory = _selectedCategory.isEmpty || 
          product.category.toLowerCase() == _selectedCategory.toLowerCase();
      
      final matchesCollection = _selectedCollection.isEmpty || 
          (product.collection != null && 
           product.collection!.toLowerCase() == _selectedCollection.toLowerCase());
      
      final matchesSearch = _searchQuery.isEmpty || 
          product.title.toLowerCase().contains(_searchQuery) || 
          product.description.toLowerCase().contains(_searchQuery) ||
          product.category.toLowerCase().contains(_searchQuery);

      return matchesCategory && 
          matchesCollection && 
          matchesSearch;
    }).toList();

    // Sort
    if (_selectedSort == 'price_low_to_high') {
      results.sort((a, b) {
        final priceA = a.variants.isNotEmpty ? a.variants[0].price * (1 - a.discountPercent / 100) : 0.0;
        final priceB = b.variants.isNotEmpty ? b.variants[0].price * (1 - b.discountPercent / 100) : 0.0;
        return priceA.compareTo(priceB);
      });
    } else if (_selectedSort == 'price_high_to_low') {
      results.sort((a, b) {
        final priceA = a.variants.isNotEmpty ? a.variants[0].price * (1 - a.discountPercent / 100) : 0.0;
        final priceB = b.variants.isNotEmpty ? b.variants[0].price * (1 - b.discountPercent / 100) : 0.0;
        return priceB.compareTo(priceA);
      });
    }

    _filteredProducts = results;
    notifyListeners();
  }

  // Reset all filters back to default
  void clearFilters() {
    _selectedCategory = '';
    _selectedCollection = '';
    _searchQuery = '';
    _selectedSort = '';
    _filteredProducts = List.from(_products);
    notifyListeners();
  }

  // Reload products lists from server directly (e.g. pull to refresh)
  Future<void> refreshCatalog() async {
    _products = await _productService.fetchProducts();
    applyFilters();
  }
}

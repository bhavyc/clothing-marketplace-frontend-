import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item.dart';
import '../services/cart_service.dart';

class CartProvider with ChangeNotifier {
  final CartService _cartService = CartService();

  List<CartItem> _items = [];
  bool _isLoading = false;
  String? _couponCode;
  double _couponDiscountPercent = 0.0;
  double _couponDiscountAmount = 0.0;
  double _couponMinOrderValue = 0.0;
  List<dynamic> _availableCoupons = [];

  List<CartItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get couponCode => _couponCode;
  double get couponDiscountPercent => _couponDiscountPercent;
  List<dynamic> get availableCoupons => _availableCoupons;

  int get cartCount => _items.fold(0, (sum, item) => sum + item.quantity);
  
  double get cartSubtotal => _items.fold(0.0, (sum, item) => sum + (item.unitPrice * item.quantity));

  double get discountAmount {
    if (_couponCode == null || cartSubtotal < _couponMinOrderValue) return 0.0;
    if (_couponDiscountPercent > 0) {
      return (cartSubtotal * (_couponDiscountPercent / 100));
    }
    return _couponDiscountAmount;
  }

  double get finalTotal => cartSubtotal - discountAmount;

  CartProvider() {
    _loadLocalCart();
    loadAvailableCoupons();
  }

  // Load cart from local storage cache on startup
  Future<void> _loadLocalCart() async {
    final prefs = await SharedPreferences.getInstance();
    final localCartStr = prefs.getString('boutique_cart');
    
    if (localCartStr != null) {
      try {
        final List decoded = json.decode(localCartStr);
        _items = decoded.map((e) => CartItem.fromJson(e)).toList();
      } catch (e) {
        print('CartProvider _loadLocalCart error: $e');
      }
    }
    notifyListeners();
  }

  // Fetch available coupon codes list from server
  Future<void> loadAvailableCoupons() async {
    final list = await _cartService.fetchCoupons();
    _availableCoupons = list;
    notifyListeners();
  }

  // Sync state to local storage and DB if token exists
  Future<void> _syncState() async {
    // 1. Cache locally
    final prefs = await SharedPreferences.getInstance();
    final encoded = json.encode(_items.map((i) => i.toJson()).toList());
    await prefs.setString('boutique_cart', encoded);

    // 2. Sync to backend DB if authenticated
    final token = prefs.getString('auth_token');
    if (token != null && token.isNotEmpty) {
      await _cartService.syncCart(_items);
    }
  }

  // Fetch verified database cart (refreshes prices/discounts)
  Future<void> refreshCartFromServer() async {
    _isLoading = true;
    notifyListeners();

    final serverItems = await _cartService.fetchCart();
    if (serverItems.isNotEmpty) {
      _items = serverItems;
      // Update local cache
      final prefs = await SharedPreferences.getInstance();
      final encoded = json.encode(_items.map((i) => i.toJson()).toList());
      await prefs.setString('boutique_cart', encoded);
    }

    _isLoading = false;
    notifyListeners();
  }

  // Adds an item to the bag
  Future<void> addItem(CartItem newItem) async {
    final existingIndex = _items.indexWhere((i) => i.id == newItem.id);

    if (existingIndex > -1) {
      _items[existingIndex].quantity += newItem.quantity;
    } else {
      _items.add(newItem);
    }
    
    notifyListeners();
    await _syncState();
  }

  // Updates item quantity
  Future<void> updateQuantity(String id, int qty) async {
    if (qty <= 0) {
      await removeItem(id);
      return;
    }

    final index = _items.indexWhere((i) => i.id == id);
    if (index > -1) {
      _items[index].quantity = qty;
      notifyListeners();
      await _syncState();
    }
  }

  // Removes item from the bag
  Future<void> removeItem(String id) async {
    _items.removeWhere((i) => i.id == id);
    notifyListeners();
    await _syncState();
  }

  // Clears the cart completely after order placement
  Future<void> clearCart() async {
    _items = [];
    _couponCode = null;
    _couponDiscountPercent = 0.0;
    _couponDiscountAmount = 0.0;
    _couponMinOrderValue = 0.0;
    
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('boutique_cart');
    
    final token = prefs.getString('auth_token');
    if (token != null && token.isNotEmpty) {
      await _cartService.syncCart([]);
    }
  }

  // Apply Coupon Code
  Future<bool> applyCoupon(String code) async {
    _isLoading = true;
    notifyListeners();

    try {
      final coupon = await _cartService.verifyCoupon(code);
      if (coupon != null && coupon['isActive'] == true) {
        final double minOrder = (coupon['minOrderValue'] as num?)?.toDouble() ?? 0.0;
        if (cartSubtotal >= minOrder) {
          _couponCode = coupon['code']?.toString().toUpperCase();
          _couponDiscountPercent = (coupon['discountPercent'] as num?)?.toDouble() ?? 0.0;
          _couponDiscountAmount = (coupon['discountAmount'] as num?)?.toDouble() ?? 0.0;
          _couponMinOrderValue = minOrder;
          
          _isLoading = false;
          notifyListeners();
          return true;
        }
      }
    } catch (e) {
      print('CartProvider verifyCoupon on server error: $e');
    }

    // Default fallback mock support for general boutique testing coupons
    if (code.toUpperCase() == 'PAY5') {
      _couponCode = 'PAY5';
      _couponDiscountPercent = 5.0;
      _couponDiscountAmount = 0.0;
      _couponMinOrderValue = 1000.0;
      _isLoading = false;
      notifyListeners();
      return true;
    }
    
    if (code.toUpperCase() == 'WELCOME10') {
      _couponCode = 'WELCOME10';
      _couponDiscountPercent = 10.0;
      _couponDiscountAmount = 0.0;
      _couponMinOrderValue = 2000.0;
      _isLoading = false;
      notifyListeners();
      return true;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  void removeCoupon() {
    _couponCode = null;
    _couponDiscountPercent = 0.0;
    _couponDiscountAmount = 0.0;
    _couponMinOrderValue = 0.0;
    notifyListeners();
  }
}

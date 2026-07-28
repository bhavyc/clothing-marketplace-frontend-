import 'dart:convert';
import '../core/network/api_client.dart';
import '../models/cart_item.dart';

class CartService {
  // Retrieves active cart items list from database (recalculated prices)
  Future<List<CartItem>> fetchCart() async {
    try {
      final res = await ApiClient.get('/cart');
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final List list = data['items'] ?? [];
        return list.map((i) => CartItem.fromJson(i)).toList();
      }
      return [];
    } catch (e) {
      print('CartService fetchCart error: $e');
      return [];
    }
  }

  // Uploads/syncs local items state array back into database
  Future<bool> syncCart(List<CartItem> items) async {
    try {
      final bodyItems = items.map((i) => i.toJson()).toList();
      final res = await ApiClient.post('/cart', {'items': bodyItems});
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      print('CartService syncCart error: $e');
      return false;
    }
  }

  // Fetch list of active coupons from server
  Future<List<dynamic>> fetchCoupons() async {
    try {
      final res = await ApiClient.get('/coupons');
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        return data['coupons'] ?? [];
      }
      return [];
    } catch (e) {
      print('CartService fetchCoupons error: $e');
      return [];
    }
  }

  // Verify single coupon code details on server
  Future<Map<String, dynamic>?> verifyCoupon(String code) async {
    try {
      final res = await ApiClient.get('/coupons?code=${Uri.encodeComponent(code)}');
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        return data['coupon'];
      }
      return null;
    } catch (e) {
      print('CartService verifyCoupon error: $e');
      return null;
    }
  }
}

import 'dart:convert';
import '../core/network/api_client.dart';
import '../models/order.dart';
import '../models/cart_item.dart';

class OrderService {
  // Places order transaction in database
  Future<Map<String, dynamic>?> placeOrder({
    required String name,
    required String email,
    required String phone,
    required String address,
    required String city,
    required String state,
    required String pincode,
    required List<CartItem> items,
    required bool useWallet,
    String? couponId,
  }) async {
    try {
      final body = {
        'customerName': name,
        'customerEmail': email,
        'customerPhone': phone,
        'shippingAddress': address,
        'city': city,
        'state': state,
        'pincode': pincode,
        'paymentType': 'PREPAID',
        'couponId': couponId,
        'useWallet': useWallet,
        'items': items.map((item) => {
          'variantId': item.variantId,
          'quantity': item.quantity,
          'priceAtPurchase': item.unitPrice,
          'selectedOptions': json.encode(item.selectedOptions.map((o) => o.toJson()).toList()),
        }).toList(),
      };

      final res = await ApiClient.post('/orders', body);
      if (res.statusCode == 200) {
        return json.decode(res.body);
      } else {
        final data = json.decode(res.body);
        throw Exception(data['error'] ?? 'Order submission failed.');
      }
    } catch (e) {
      print('OrderService placeOrder error: $e');
      rethrow;
    }
  }

  // Verifies signature (real or mock)
  Future<bool> verifyPayment({
    required String orderNumber,
    required String paymentId,
    required String orderId,
    required String signature,
  }) async {
    try {
      final res = await ApiClient.post('/orders/verify', {
        'orderNumber': orderNumber,
        'razorpayPaymentId': paymentId,
        'razorpayOrderId': orderId,
        'razorpaySignature': signature,
      });

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      print('OrderService verifyPayment error: $e');
      return false;
    }
  }

  // Fetch past orders list of customer
  Future<List<OrderModel>> fetchOrders() async {
    try {
      final res = await ApiClient.get('/orders');
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final List list = data['orders'] ?? [];
        return list.map((o) => OrderModel.fromJson(o)).toList();
      }
      return [];
    } catch (e) {
      print('OrderService fetchOrders error: $e');
      return [];
    }
  }

  // Fetch specific order details (e.g. for success tracking)
  Future<OrderModel?> fetchOrderDetail(String orderNumber) async {
    try {
      final res = await ApiClient.get('/orders?orderNumber=$orderNumber');
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data['order'] != null) {
          return OrderModel.fromJson(data['order']);
        }
      }
      return null;
    } catch (e) {
      print('OrderService fetchOrderDetail error: $e');
      return null;
    }
  }

  // Request order return
  Future<bool> requestReturn({
    required String orderId,
    required List<Map<String, dynamic>> returnItems,
  }) async {
    try {
      final res = await ApiClient.post('/orders/$orderId/return', {
        'items': returnItems,
      });
      return res.statusCode == 200;
    } catch (e) {
      print('OrderService requestReturn error: $e');
      return false;
    }
  }
}

import 'dart:convert';
import 'package:clothing_app/core/network/api_client.dart';

class OrderModel {
  final String id;
  final String orderNumber;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String shippingAddress;
  final String city;
  final String state;
  final String pincode;
  final double subtotal;
  final double discountAmount;
  final double totalAmount;
  final double walletPaid;
  final String paymentType;
  final String paymentStatus;
  final String status; // PLACED, CONFIRMED, SHIPPED, DELIVERED, CANCELLED
  final String? trackingCompany;
  final String? trackingNumber;
  final String createdAt;
  final List<OrderItemModel> items;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.shippingAddress,
    required this.city,
    required this.state,
    required this.pincode,
    required this.subtotal,
    required this.discountAmount,
    required this.totalAmount,
    required this.walletPaid,
    required this.paymentType,
    required this.paymentStatus,
    required this.status,
    this.trackingCompany,
    this.trackingNumber,
    required this.createdAt,
    required this.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? '',
      orderNumber: json['orderNumber'] ?? '',
      customerName: json['customerName'] ?? '',
      customerEmail: json['customerEmail'] ?? '',
      customerPhone: json['customerPhone'] ?? '',
      shippingAddress: json['shippingAddress'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      pincode: json['pincode'] ?? '',
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      walletPaid: (json['walletPaid'] as num?)?.toDouble() ?? 0.0,
      paymentType: json['paymentType'] ?? 'PREPAID',
      paymentStatus: json['paymentStatus'] ?? 'PENDING',
      status: json['status'] ?? 'PLACED',
      trackingCompany: json['trackingCompany'],
      trackingNumber: json['trackingNumber'],
      createdAt: json['createdAt'] ?? '',
      items: (json['items'] as List?)
              ?.map((i) => OrderItemModel.fromJson(i))
              .toList() ??
          [],
    );
  }
}

class OrderItemModel {
  final String id;
  final String variantId;
  final int quantity;
  final double priceAtPurchase;
  final String? selectedOptions;
  final String productTitle;
  final String productImage;

  OrderItemModel({
    required this.id,
    required this.variantId,
    required this.quantity,
    required this.priceAtPurchase,
    this.selectedOptions,
    required this.productTitle,
    required this.productImage,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    String title = 'Designer Apparel';
    String image = '';

    if (json['variant'] != null && json['variant']['product'] != null) {
      final product = json['variant']['product'];
      title = product['title'] ?? 'Designer Apparel';
      
      // Parse product images
      var imageVal = product['images'];
      if (imageVal is List && imageVal.isNotEmpty) {
        image = imageVal[0].toString();
      } else if (imageVal is String && imageVal.isNotEmpty) {
        try {
          if (imageVal.startsWith('[')) {
            // parsed as array string
            var decoded = jsonDecode(imageVal);
            if (decoded is List && decoded.isNotEmpty) {
              image = decoded[0].toString();
            }
          } else {
            image = imageVal;
          }
        } catch (e) {
          image = imageVal;
        }
      }
    }

    return OrderItemModel(
      id: json['id'] ?? '',
      variantId: json['variantId'] ?? '',
      quantity: json['quantity'] ?? 1,
      priceAtPurchase: (json['priceAtPurchase'] as num?)?.toDouble() ?? 0.0,
      selectedOptions: json['selectedOptions'],
      productTitle: title,
      productImage: ApiClient.formatImageUrl(image),
    );
  }
}

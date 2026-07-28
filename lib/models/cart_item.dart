import 'package:clothing_app/core/network/api_client.dart';
import 'product.dart';

// ... (rest of model details)

class SelectedOption {
  final String id;
  final String optionName;
  final String optionValue;
  final double priceAdjustment;

  SelectedOption({
    required this.id,
    required this.optionName,
    required this.optionValue,
    required this.priceAdjustment,
  });

  factory SelectedOption.fromJson(Map<String, dynamic> json) {
    return SelectedOption(
      id: json['id'] ?? '',
      optionName: json['optionName'] ?? '',
      optionValue: json['optionValue'] ?? '',
      priceAdjustment: (json['priceAdjustment'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'optionName': optionName,
      'optionValue': optionValue,
      'priceAdjustment': priceAdjustment,
    };
  }
}

class CartItem {
  final String id; // Compound unique key: variantId_topSize_bottomSize_sortedOptions
  final String productId;
  final String productTitle;
  final String productImage;
  final String category;
  final String sellerShopName;
  final String variantId;
  final String? topSize;
  final String? bottomSize;
  final double basePrice; // Base price of variant
  final List<SelectedOption> selectedOptions;
  int quantity;
  final double unitPrice; // basePrice + options priceAdjustment sum
  final String deliveryTimeline;

  CartItem({
    required this.id,
    required this.productId,
    required this.productTitle,
    required this.productImage,
    required this.category,
    required this.sellerShopName,
    required this.variantId,
    this.topSize,
    this.bottomSize,
    required this.basePrice,
    required this.selectedOptions,
    required this.quantity,
    required this.unitPrice,
    required this.deliveryTimeline,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] ?? '',
      productId: json['productId'] ?? '',
      productTitle: json['productTitle'] ?? '',
      productImage: ApiClient.formatImageUrl(json['productImage'] ?? ''),
      category: json['category'] ?? '',
      sellerShopName: json['sellerShopName'] ?? '',
      variantId: json['variantId'] ?? '',
      topSize: json['topSize'],
      bottomSize: json['bottomSize'],
      basePrice: (json['basePrice'] as num?)?.toDouble() ?? 0.0,
      selectedOptions: (json['selectedOptions'] as List?)
              ?.map((o) => SelectedOption.fromJson(o))
              .toList() ??
          [],
      quantity: json['quantity'] ?? 1,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      deliveryTimeline: json['deliveryTimeline'] ?? '10-15 Days',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productTitle': productTitle,
      'productImage': productImage,
      'category': category,
      'sellerShopName': sellerShopName,
      'variantId': variantId,
      'topSize': topSize,
      'bottomSize': bottomSize,
      'basePrice': basePrice,
      'selectedOptions': selectedOptions.map((o) => o.toJson()).toList(),
      'quantity': quantity,
      'unitPrice': unitPrice,
      'deliveryTimeline': deliveryTimeline,
    };
  }
}

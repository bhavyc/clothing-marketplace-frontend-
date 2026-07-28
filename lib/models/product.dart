import 'dart:convert';
import 'package:clothing_app/core/network/api_client.dart';

class Product {
  final String id;
  final String title;
  final String description;
  final List<String> images;
  final String category;
  final String? collection;
  final String? fabricDetails;
  final String? careInstructions;
  final String deliveryTimeline;
  final bool isSet;
  final String tier;
  final String? topLength;
  final String? pantLength;
  final String? sleeveLength;
  final bool isBestseller;
  final double discountPercent;
  final String sizeChartType;
  final String? sizeChartData;
  final String sellerId;
  final String? sellerShopName;
  final List<ProductVariant> variants;
  final List<ProductOption> options;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.images,
    required this.category,
    this.collection,
    this.fabricDetails,
    this.careInstructions,
    required this.deliveryTimeline,
    required this.isSet,
    required this.tier,
    this.topLength,
    this.pantLength,
    this.sleeveLength,
    required this.isBestseller,
    required this.discountPercent,
    required this.sizeChartType,
    this.sizeChartData,
    required this.sellerId,
    this.sellerShopName,
    required this.variants,
    required this.options,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Robust parsing for images list
    var imageVal = json['images'];
    List<String> imageList = [];
    if (imageVal is String) {
      try {
        var decoded = jsonDecode(imageVal);
        if (decoded is List) {
          imageList = decoded.map((e) => e.toString()).toList();
        } else {
          imageList = [imageVal];
        }
      } catch (e) {
        imageList = [imageVal];
      }
    } else if (imageVal is List) {
      imageList = imageVal.map((e) => e.toString()).toList();
    }

    // Format all image URLs to be absolute network references
    imageList = imageList.map((url) => ApiClient.formatImageUrl(url)).toList();

    return Product(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      images: imageList,
      category: json['category'] ?? '',
      collection: json['collection'],
      fabricDetails: json['fabricDetails'],
      careInstructions: json['careInstructions'],
      deliveryTimeline: json['deliveryTimeline'] ?? '10-15 Days',
      isSet: json['isSet'] ?? false,
      tier: json['tier'] ?? 'LUXE',
      topLength: json['topLength']?.toString(),
      pantLength: json['pantLength']?.toString(),
      sleeveLength: json['sleeveLength']?.toString(),
      isBestseller: json['isBestseller'] ?? false,
      discountPercent: (json['discountPercent'] as num?)?.toDouble() ?? 0.0,
      sizeChartType: json['sizeChartType'] ?? 'STANDARD',
      sizeChartData: json['sizeChartData']?.toString(),
      sellerId: json['sellerId'] ?? '',
      sellerShopName: json['seller'] != null ? json['seller']['shopName'] : null,
      variants: (json['variants'] as List?)
              ?.map((v) => ProductVariant.fromJson(v))
              .toList() ??
          [],
      options: (json['options'] as List?)
              ?.map((o) => ProductOption.fromJson(o))
              .toList() ??
          [],
    );
  }
}

class ProductVariant {
  final String id;
  final String productId;
  final String? topSize;
  final String? bottomSize;
  final double price;
  final int stock;

  ProductVariant({
    required this.id,
    required this.productId,
    this.topSize,
    this.bottomSize,
    required this.price,
    required this.stock,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['id'] ?? '',
      productId: json['productId'] ?? '',
      topSize: json['topSize'],
      bottomSize: json['bottomSize'],
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      stock: json['stock'] ?? 0,
    );
  }
}

class ProductOption {
  final String id;
  final String productId;
  final String optionName;
  final String optionValue;
  final double priceAdjustment;

  ProductOption({
    required this.id,
    required this.productId,
    required this.optionName,
    required this.optionValue,
    required this.priceAdjustment,
  });

  factory ProductOption.fromJson(Map<String, dynamic> json) {
    return ProductOption(
      id: json['id'] ?? '',
      productId: json['productId'] ?? '',
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
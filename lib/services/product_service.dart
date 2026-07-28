import 'dart:convert';
import '../core/network/api_client.dart';
import '../models/product.dart';

class ProductService {
  // Fetch products lists with optional category/collection query
  Future<List<Product>> fetchProducts({String? category, String? collection}) async {
    try {
      String query = '';
      if (category != null && category.isNotEmpty) {
        query += '?category=${Uri.encodeComponent(category)}';
      }
      if (collection != null && collection.isNotEmpty) {
        query += query.isEmpty 
            ? '?collection=${Uri.encodeComponent(collection)}' 
            : '&collection=${Uri.encodeComponent(collection)}';
      }

      final res = await ApiClient.get('/products$query');
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final List list = data['products'] ?? [];
        return list.map((p) => Product.fromJson(p)).toList();
      }
      return [];
    } catch (e) {
      print('ProductService fetchProducts error: $e');
      return [];
    }
  }

  // Fetch single product details with options and variants
  Future<Product?> fetchProductDetail(String id) async {
    try {
      final res = await ApiClient.get('/products?id=$id');
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data['product'] != null) {
          return Product.fromJson(data['product']);
        }
      }
      return null;
    } catch (e) {
      print('ProductService fetchProductDetail error: $e');
      return null;
    }
  }

  // Fetch unique categories and collections list for navigation
  Future<Map<String, List<String>>> fetchNavigationData() async {
    try {
      final res = await ApiClient.get('/navigation');
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final List categories = data['categories'] ?? [];
        final List collections = data['collections'] ?? [];
        return {
          'categories': categories.map((e) => e.toString()).toList(),
          'collections': collections.map((e) => e.toString()).toList(),
        };
      }
      return {'categories': [], 'collections': []};
    } catch (e) {
      print('ProductService fetchNavigationData error: $e');
      return {'categories': [], 'collections': []};
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ApiService {
  // Agar aap local machine par test kar rahe hain:
  // Android Emulator ke liye local host IP: 'http://10.0.2.2:3000' hoti hai.
  // iOS Simulator ke liye: 'http://localhost:3000'
  static const String baseUrl = 'http://10.54.220.121:3000'; 

  // 1. OTP Send Request
  static Future<Map<String, dynamic>> sendOtp(String phoneNumber) async {
    final url = Uri.parse('$baseUrl/api/auth/otp/send');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phoneNumber}),
      );

      final decodedData = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': decodedData['message'] ?? 'OTP sent successfully',
          'devOtp': decodedData['devOtp'], // Dev environment ke liye bypass OTP
        };
      } else {
        return {
          'success': false,
          'error': decodedData['error'] ?? 'Failed to send OTP'
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Network connection failed.'};
    }
  }

  // 2. OTP Verification Request
  static Future<Map<String, dynamic>> verifyOtp({
    required String phoneNumber,
    required String otp,
    required bool optInWhatsApp,
  }) async {
    final url = Uri.parse('$baseUrl/api/auth/otp/verify');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': phoneNumber,
          'otp': otp,
          'optInWhatsApp': optInWhatsApp,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'message': data['message']};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Verification failed.'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error, please try again.'};
    }
  }



   static Future<Map<String, List<String>>> fetchNavigation(String mode) async {
    final url = Uri.parse('$baseUrl/api/navigation?mode=$mode');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return {
          'categories': List<String>.from(decoded['categories'] ?? []),
          'collections': List<String>.from(decoded['collections'] ?? []),
        };
      }
    } catch (e) {
      print('Navigation error: $e');
    }
    return {'categories': [], 'collections': []};
  }

  // 4. Products List Fetch (by active segment/tier and category)
  static Future<List<Product>> fetchProducts({
    required String tier,
    String? category,
  }) async {
    String query = 'tier=$tier';
    if (category != null && category.isNotEmpty) {
      query += '&category=${Uri.encodeComponent(category)}';
    }

    final url = Uri.parse('$baseUrl/api/products?$query');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = jsonDecode(response.body);
        final List data = decoded['products'] ?? [];
        return data.map((json) => Product.fromJson(json)).toList();
      }
    } catch (e) {
      print('Fetch products error: $e');
    }
    return [];
  }
}
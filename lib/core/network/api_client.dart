import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static String baseUrl = 'http://10.54.220.121:3000/api';

  static String formatImageUrl(String url) {
    if (url.isEmpty) return 'https://via.placeholder.com/150';
    
    // Replace localhost or 127.0.0.1 references with active host IP
    if (url.contains('localhost:3000')) {
      return url.replaceAll('http://localhost:3000', baseUrl.replaceAll('/api', ''));
    }
    if (url.contains('127.0.0.1:3000')) {
      return url.replaceAll('http://127.0.0.1:3000', baseUrl.replaceAll('/api', ''));
    }
    
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    
    final path = url.startsWith('/') ? url : '/$url';
    return '${baseUrl.replaceAll('/api', '')}$path';
  }

  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  static Future<http.Response> get(String path) async {
    final url = Uri.parse('$baseUrl$path');
    final headers = await _getHeaders();
    return http.get(url, headers: headers);
  }

  static Future<http.Response> post(String path, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl$path');
    final headers = await _getHeaders();
    return http.post(url, headers: headers, body: json.encode(body));
  }

  static Future<http.Response> put(String path, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl$path');
    final headers = await _getHeaders();
    return http.put(url, headers: headers, body: json.encode(body));
  }

  static Future<http.Response> delete(String path) async {
    final url = Uri.parse('$baseUrl$path');
    final headers = await _getHeaders();
    return http.delete(url, headers: headers);
  }
}

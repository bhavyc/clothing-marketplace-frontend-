import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/network/api_client.dart';
import '../models/user.dart';

class AuthService {
  // Requests OTP to be sent via SMS/Console
  Future<String?> sendOtp(String phone) async {
    try {
      final res = await ApiClient.post('/auth/otp/send', {'phone': phone});
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data['success'] == true) {
          return data['devOtp']?.toString() ?? "";
        }
      }
      return null;
    } catch (e) {
      print('AuthService sendOtp error: $e');
      return null;
    }
  }

  // Verifies OTP and returns user profile & JWT token
  Future<Map<String, dynamic>?> verifyOtp(String phone, String otp) async {
    try {
      final res = await ApiClient.post('/auth/otp/verify', {
        'phone': phone,
        'otp': otp,
      });

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data['success'] == true) {
          final String token = data['token'] ?? '';
          
          // Save JWT token locally
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', token);
          await prefs.setString('user_phone', phone);
          
          // Return user profile data and token
          return data;
        }
      }
      return null;
    } catch (e) {
      print('AuthService verifyOtp error: $e');
      return null;
    }
  }

  // Fetch current user wallet and profile details
  Future<UserModel?> getProfile() async {
    try {
      final res = await ApiClient.get('/user/wallet');
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        // Next.js returns { walletBalance: 1200, user: { id: '...', email: '...' } }
        if (data['user'] != null) {
          final userJson = Map<String, dynamic>.from(data['user']);
          userJson['walletBalance'] = data['walletBalance'] ?? 0.0;
          return UserModel.fromJson(userJson);
        }
      }
      return null;
    } catch (e) {
      print('AuthService getProfile error: $e');
      return null;
    }
  }

  // Log out by clearing token from storage
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_phone');
  }

  // Deletes user account from backend and clears session locally
  Future<bool> deleteAccount() async {
    try {
      final res = await ApiClient.post('/user/delete', {});
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data['success'] == true) {
          await logout();
          return true;
        }
      }
      return false;
    } catch (e) {
      print('AuthService deleteAccount error: $e');
      return false;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  UserModel? _user;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _phone;
  String? _devOtp;

  UserModel? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get phone => _phone;
  String? get devOtp => _devOtp;

  AuthProvider() {
    _loadSession();
  }

  // Load session from SharedPreferences on startup
  Future<void> _loadSession() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    _phone = prefs.getString('user_phone');

    if (token != null && token.isNotEmpty) {
      _isAuthenticated = true;
      await fetchUserProfile();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Fetch updated profile (wallet balance) from server
  Future<void> fetchUserProfile() async {
    final profile = await _authService.getProfile();
    if (profile != null) {
      _user = profile;
      _isAuthenticated = true;
    } else {
      // Token is likely expired/invalid, clear it
      await logout();
    }
    notifyListeners();
  }

  // Send verification OTP to phone
  Future<bool> sendOtp(String phone) async {
    _isLoading = true;
    _devOtp = null;
    notifyListeners();
    final otpResult = await _authService.sendOtp(phone);
    _isLoading = false;
    if (otpResult != null) {
      _devOtp = otpResult.isEmpty ? null : otpResult;
      notifyListeners();
      return true;
    }
    notifyListeners();
    return false;
  }

  // Verify OTP and complete login
  Future<bool> verifyOtp(String phone, String otp) async {
    _isLoading = true;
    notifyListeners();

    final response = await _authService.verifyOtp(phone, otp);
    if (response != null && response['success'] == true) {
      _phone = phone;
      _isAuthenticated = true;
      await fetchUserProfile();
      _isLoading = false;
      notifyListeners();
      return true;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Log out session
  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _phone = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  // Delete user account permanently
  Future<bool> deleteAccount() async {
    _isLoading = true;
    notifyListeners();
    final success = await _authService.deleteAccount();
    if (success) {
      _user = null;
      _phone = null;
      _isAuthenticated = false;
    }
    _isLoading = false;
    notifyListeners();
    return success;
  }
}

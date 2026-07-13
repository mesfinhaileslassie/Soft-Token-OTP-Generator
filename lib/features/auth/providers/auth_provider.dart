// lib/features/auth/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _username;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get username => _username;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token != null && token.isNotEmpty) {
        _isAuthenticated = true;
        _username = prefs.getString('username');
        notifyListeners();
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> login({
    required String username,
    required String password,
    required bool rememberMe,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 2));

      if (username.isNotEmpty && password.isNotEmpty) {
        if (rememberMe) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(
            'auth_token',
            'dummy_token_${DateTime.now().millisecondsSinceEpoch}',
          );
          await prefs.setString('username', username);
        }

        _isAuthenticated = true;
        _username = username;
      } else {
        _errorMessage = 'Invalid credentials';
      }
    } catch (e) {
      _errorMessage = 'An error occurred during login';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('username');
      _isAuthenticated = false;
      _username = null;
      notifyListeners();
    } catch (e) {
      // Handle error silently
    }
  }
}

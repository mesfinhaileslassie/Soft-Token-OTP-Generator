// lib/features/auth/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _username;
  String? _errorMessage;
  BuildContext? _navigationContext;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get username => _username;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _checkAuthStatus();
  }

  void setNavigationContext(BuildContext context) {
    _navigationContext = context;
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
        notifyListeners();

        // Navigate to home screen
        if (_navigationContext != null) {
          GoRouter.of(_navigationContext!).go('/home');
        }
      } else {
        _errorMessage = 'Invalid credentials';
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'An error occurred during login';
      notifyListeners();
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

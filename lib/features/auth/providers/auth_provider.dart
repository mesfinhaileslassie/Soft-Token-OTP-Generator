// lib/features/auth/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:payroll_soft_token_app/core/services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _username;
  String? _errorMessage;
  BuildContext? _navigationContext;
  bool _isDisposed = false;

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

  @override
  void dispose() {
    _isDisposed = true;
    _navigationContext = null;
    super.dispose();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final storage = await StorageService.getInstance();
      final session = await storage.getSession();
      if (session != null && session['username'] != null) {
        final user = await storage.getUser(session['username']);
        if (user != null) {
          _isAuthenticated = true;
          _username = session['username'];
          notifyListeners();

          // Check if device is already registered
          final deviceId = await storage.getDeviceId(session['username']);
          final isRegistered = deviceId != null;

          if (_navigationContext != null && !_isDisposed) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!_isDisposed && _navigationContext != null) {
                try {
                  GoRouter.of(_navigationContext!).go('/home');
                } catch (e) {
                  print('❌ Navigation error: $e');
                }
              }
            });
          }
        } else {
          await storage.clearSession();
        }
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
      if (username.isEmpty || password.isEmpty) {
        _errorMessage = 'Please enter username and password';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final storage = await StorageService.getInstance();
      final user = await storage.getUser(username);

      if (user == null) {
        _errorMessage = 'User not found. Please register first.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      if (user['password'] != password) {
        _errorMessage = 'Invalid password. Please try again.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final token = 'session_${DateTime.now().millisecondsSinceEpoch}';
      await storage.saveSession(username, token);

      if (rememberMe) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('remember_username', username);
      }

      _isAuthenticated = true;
      _username = username;
      _isLoading = false;
      notifyListeners();

      if (_navigationContext != null && !_isDisposed) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_isDisposed && _navigationContext != null) {
            GoRouter.of(_navigationContext!).go('/home');
          }
        });
      }
    } catch (e) {
      _errorMessage = 'An error occurred during login: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      final storage = await StorageService.getInstance();
      await storage.clearSession();

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('remember_username');

      _isAuthenticated = false;
      _username = null;
      notifyListeners();

      if (_navigationContext != null && !_isDisposed) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_isDisposed && _navigationContext != null) {
            GoRouter.of(_navigationContext!).go('/login');
          }
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Check if device is registered
  Future<bool> isDeviceRegistered() async {
    try {
      final storage = await StorageService.getInstance();
      final session = await storage.getSession();
      if (session != null && session['username'] != null) {
        final deviceId = await storage.getDeviceId(session['username']);
        return deviceId != null;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}

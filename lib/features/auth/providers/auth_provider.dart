// lib/features/auth/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:payroll_soft_token_app/core/services/storage_service.dart';
import 'package:payroll_soft_token_app/app/routes/app_router.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _username;
  String? _role;
  String? _errorMessage;
  BuildContext? _navigationContext;
  bool _isDisposed = false;
  bool _isNavigating = false;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get username => _username;
  String? get role => _role;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    autoLogin();
  }

  void setNavigationContext(BuildContext context) {
    if (!_isDisposed) _navigationContext = context;
  }

  @override
  void dispose() {
    _isDisposed = true;
    _navigationContext = null;
    super.dispose();
  }

  // ==================== AUTO LOGIN (offline) ====================

  Future<void> autoLogin() async {
    final storage = await StorageService.getInstance();
    final creds = await storage.getAuthCredentials();
    if (creds != null) {
      _username = creds['username'];
      _role = creds['role'];
      _isAuthenticated = true;
      notifyListeners();
      _navigateToDashboard();
    }
  }

  // ==================== OFFLINE LOGIN (called from login_form) ====================

  Future<bool> offlineLogin(String username, String password) async {
    final storage = await StorageService.getInstance();
    final creds = await storage.getAuthCredentials();
    if (creds == null || creds['username'] != username) return false;

    // Hash the entered password and compare
    final enteredHash = sha256.convert(utf8.encode(password)).toString();
    if (enteredHash != creds['passwordHash']) return false;

    // Success
    _username = username;
    _role = creds['role'] ?? 'Employee';
    _isAuthenticated = true;
    notifyListeners();
    _navigateToDashboard();
    return true;
  }

  // ==================== ONLINE LOGIN (from backend) ====================

  Future<void> login({
    required String username,
    required String password,
    required bool rememberMe,
    required Map<String, dynamic> userData, // from backend response
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final storage = await StorageService.getInstance();

      // Save session
      final token = 'session_${DateTime.now().millisecondsSinceEpoch}';
      await storage.saveSession(username, token);

      // Save auth credentials for offline login
      final passwordHash = sha256.convert(utf8.encode(password)).toString();
      final role = userData['role'] ?? 'Employee';
      await storage.saveAuthCredentials(username, passwordHash, role);

      // Save user profile
      if (userData['userId'] != null) {
        await storage.saveUserId(userData['userId']);
        await storage.saveUsername(username);
        // Save profile if we have it (from the response or we'll fetch later)
        if (userData['firstName'] != null) {
          await storage.saveUserProfile(userData);
        }
      }

      _username = username;
      _role = role;
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();

      _navigateToDashboard();
    } catch (e) {
      _errorMessage = 'An error occurred: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    final storage = await StorageService.getInstance();
    await storage.clearSession();
    await storage.clearAuthCredentials();
    _isAuthenticated = false;
    _username = null;
    _role = null;
    notifyListeners();
    _navigateToLogin();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ==================== NAVIGATION ====================

  void _navigateToDashboard() {
    if (_isDisposed || _isNavigating || _navigationContext == null) return;
    _isNavigating = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed && _navigationContext != null) {
        try {
          final role = _role ?? 'Employee';
          final path = role == 'Admin'
              ? '/admin/dashboard'
              : role == 'PayrollOfficer'
              ? '/payroll-officer/dashboard'
              : role == 'FinanceManager'
              ? '/finance-manager/dashboard'
              : '/token';
          GoRouter.of(_navigationContext!).go(path);
        } catch (e) {
          print('Navigation error: $e');
        }
      }
      _isNavigating = false;
    });
  }

  void _navigateToLogin() {
    if (_isDisposed || _isNavigating || _navigationContext == null) return;
    _isNavigating = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed && _navigationContext != null) {
        try {
          GoRouter.of(_navigationContext!).go('/login');
        } catch (e) {
          print('Navigation error: $e');
        }
      }
      _isNavigating = false;
    });
  }
}

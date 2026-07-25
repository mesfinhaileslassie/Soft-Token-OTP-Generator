// lib/features/auth/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:payroll_soft_token_app/core/services/storage_service.dart';
import 'package:go_router/go_router.dart';

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
    // No auto-login
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

  // ==================== LOGIN (with local + backend fallback) ====================

  Future<void> login({
    required String username,
    required String password,
    required bool rememberMe,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final storage = await StorageService.getInstance();

      // Step 1: Check local credentials (offline)
      final localCreds = await storage.getAuthCredentials();
      if (localCreds != null) {
        final storedUsername = localCreds['username'];
        final storedHash = localCreds['passwordHash'];
        final enteredHash = sha256.convert(utf8.encode(password)).toString();

        if (storedUsername == username && storedHash == enteredHash) {
          // Local validation success
          _username = username;
          _role = localCreds['role'] ?? 'Employee';
          _isAuthenticated = true;
          _isLoading = false;

          // Save session
          final token = 'session_${DateTime.now().millisecondsSinceEpoch}';
          await storage.saveSession(username, token);

          notifyListeners();
          _navigateToDashboard();
          return;
        }
      }

      // Step 2: Fallback to backend validation (online)
      // (We need to call the backend API – but we don't have a real backend here, so simulate)
      // For demo, we'll simulate with the existing storage service, but you should replace with actual API call.
      // In a real app, you would call ApiService.loginUser()
      final user = await storage.getUser(username);
      if (user == null) {
        _errorMessage = 'Invalid username or password';
        _isLoading = false;
        notifyListeners();
        return;
      }
      if (user['password'] != password) {
        _errorMessage = 'Invalid password';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Step 3: Save credentials locally for offline use
      final passwordHash = sha256.convert(utf8.encode(password)).toString();
      await storage.saveAuthCredentials(
        username,
        passwordHash,
        user['role'] ?? 'Employee',
      );

      // Save session
      final token = 'session_${DateTime.now().millisecondsSinceEpoch}';
      await storage.saveSession(username, token);

      _username = username;
      _role = user['role'] ?? 'Employee';
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();

      // Associate global device (if any)
      final isActiveGlobal = await storage.isDeviceActiveGlobal();
      if (isActiveGlobal) {
        final globalCreds = await storage.getDeviceCredentialsGlobal();
        if (globalCreds != null) {
          await storage.saveDeviceCredentials(
            username,
            globalCreds['deviceToken']!,
            globalCreds['secretKey']!,
          );
          await storage.markDeviceActive(username);
        }
      }

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
    // Optionally: keep credentials stored so user can login offline later.
    // If you want to clear credentials on logout, uncomment:
    // await storage.clearAuthCredentials();
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

  // ==================== NAVIGATION HELPERS ====================

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
              : '/employee/dashboard';
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

// lib/features/token/providers/token_provider.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:payroll_soft_token_app/core/services/storage_service.dart';
import 'package:payroll_soft_token_app/core/services/api_service.dart';

class TokenProvider extends ChangeNotifier {
  String _token = '';
  bool _hasToken = false;
  bool _isGenerating = false;
  int _secondsRemaining = 30;
  Timer? _timer;
  String _errorMessage = '';
  bool _canGenerate = false;
  bool _isChecking = false;

  String get token => _token;
  bool get hasToken => _hasToken;
  bool get isGenerating => _isGenerating;
  int get secondsRemaining => _secondsRemaining;
  String get errorMessage => _errorMessage;
  bool get canGenerate => _canGenerate;
  bool get isChecking => _isChecking;

  TokenProvider() {
    _checkDeviceStatus();
  }

  Future<void> _checkDeviceStatus() async {
    setState(() {
      _isChecking = true;
      _canGenerate = false;
    });

    try {
      final storage = await StorageService.getInstance();

      final isActiveGlobal = await storage.isDeviceActiveGlobal();
      if (isActiveGlobal) {
        final creds = await storage.getDeviceCredentialsGlobal();
        if (creds != null && creds['secretKey'] != null) {
          setState(() {
            _isChecking = false;
            _canGenerate = true;
            _errorMessage = '';
          });
          return;
        }
      }

      final session = await storage.getSession();
      if (session != null && session['username'] != null) {
        final username = session['username'];
        final isActive = await storage.isDeviceTrusted(username);
        final status = await storage.getDeviceStatus(username);
        if (isActive && status == 'ACTIVE') {
          setState(() {
            _isChecking = false;
            _canGenerate = true;
            _errorMessage = '';
          });
          return;
        }
      }

      setState(() {
        _isChecking = false;
        _canGenerate = false;
        _errorMessage =
            'Device is not active. Please activate your device first.';
      });
    } catch (e) {
      setState(() {
        _isChecking = false;
        _canGenerate = false;
        _errorMessage = 'Error checking device status';
      });
    }
  }

  Future<void> generateToken() async {
    if (!_canGenerate) {
      _errorMessage =
          'Device is not active. Please activate your device first.';
      notifyListeners();
      return;
    }

    if (_isGenerating) return;

    setState(() {
      _isGenerating = true;
      _errorMessage = '';
    });
    notifyListeners();

    try {
      final storage = await StorageService.getInstance();

      // Get secret key
      String? secretKey;
      final globalCreds = await storage.getDeviceCredentialsGlobal();
      if (globalCreds != null && globalCreds['secretKey'] != null) {
        secretKey = globalCreds['secretKey'];
      } else {
        final session = await storage.getSession();
        if (session != null && session['username'] != null) {
          final userCreds = await storage.getDeviceCredentials(
            session['username'],
          );
          if (userCreds != null && userCreds['secretKey'] != null) {
            secretKey = userCreds['secretKey'];
          }
        }
      }

      if (secretKey == null) {
        setState(() {
          _isGenerating = false;
          _errorMessage = 'Secret key not found. Please re-activate device.';
        });
        return;
      }

      // Calculate counter
      final timeInSeconds =
          DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
      final counter = timeInSeconds ~/ 30;

      // Send counter to backend – fire-and-forget with timeout
      String? installationId;
      final globalKeys = await storage.getTemporaryKeysGlobal();
      if (globalKeys != null && globalKeys['installationId'] != null) {
        installationId = globalKeys['installationId'];
      } else {
        final session = await storage.getSession();
        if (session != null && session['username'] != null) {
          installationId = await storage.getInstallationId(session['username']);
        }
      }
      if (installationId != null) {
        // Non-blocking: don't await, just fire and log errors
        final apiService = ApiService();
        apiService
            .storeCounter(installationId: installationId, counter: counter)
            .timeout(const Duration(seconds: 3))
            .catchError((e) => print('⚠️ Failed to sync counter: $e'));
      } else {
        print('⚠️ Installation ID not found, cannot store counter');
      }

      // Generate OTP immediately
      final combined = '$secretKey:$counter';
      final bytes = utf8.encode(combined);
      final hash = sha256.convert(bytes);
      final hashString = hash.toString();

      String tokenValue = '';
      for (int i = 0; i < hashString.length && tokenValue.length < 6; i++) {
        if (hashString[i].contains(RegExp(r'[0-9]'))) {
          tokenValue += hashString[i];
        }
      }
      while (tokenValue.length < 6) {
        tokenValue = '0$tokenValue';
      }
      tokenValue = tokenValue.substring(0, 6);

      // Update UI
      setState(() {
        _token = tokenValue;
        _hasToken = true;
        _isGenerating = false;
        _secondsRemaining = 30;
        _errorMessage = '';
      });
      notifyListeners();
      _startTimer();
    } catch (e) {
      setState(() {
        _isGenerating = false;
        _errorMessage = 'Error: ${e.toString()}';
      });
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        _secondsRemaining--;
        notifyListeners();
      } else {
        timer.cancel();
        _hasToken = false;
        _token = '';
        notifyListeners();
      }
    });
  }

  void reset() {
    _timer?.cancel();
    _token = '';
    _hasToken = false;
    _isGenerating = false;
    _secondsRemaining = 30;
    _errorMessage = '';
    notifyListeners();
    _checkDeviceStatus();
  }

  void setState(VoidCallback fn) {
    fn();
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

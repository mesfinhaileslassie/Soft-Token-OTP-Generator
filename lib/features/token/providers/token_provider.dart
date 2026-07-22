// lib/features/token/providers/token_provider.dart
import 'package:flutter/material.dart';
import 'dart:async';
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
      final session = await storage.getSession();

      if (session == null || session['username'] == null) {
        setState(() {
          _isChecking = false;
          _canGenerate = false;
          _errorMessage = 'Please login first';
        });
        return;
      }

      final username = session['username'];

      // Check if device is active and trusted
      final isActive = await storage.isDeviceTrusted(username);
      final status = await storage.getDeviceStatus(username);

      setState(() {
        _isChecking = false;
        _canGenerate = isActive && status == 'ACTIVE';
        _errorMessage = _canGenerate
            ? ''
            : 'Device is not active. Please activate your device first.';
      });
    } catch (e) {
      setState(() {
        _isChecking = false;
        _canGenerate = false;
        _errorMessage = 'Error checking device status';
      });
    }
  }

  void generateToken() {
    // Step 1: Check if device can generate token
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

    // Simulate generation delay
    Future.delayed(const Duration(milliseconds: 500), () {
      // Generate a random 6-digit token
      final random = DateTime.now().millisecondsSinceEpoch;
      final tokenValue = (random % 900000 + 100000).toString();

      setState(() {
        _token = tokenValue;
        _hasToken = true;
        _isGenerating = false;
        _secondsRemaining = 30;
        _errorMessage = '';
      });
      notifyListeners();

      // Start timer
      _startTimer();
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        _secondsRemaining--;
        notifyListeners();
      } else {
        timer.cancel();
        // When timer expires, clear the token
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

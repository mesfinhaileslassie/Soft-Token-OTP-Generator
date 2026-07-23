// lib/features/token/providers/token_provider.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:payroll_soft_token_app/core/services/storage_service.dart';

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
      final session = await storage.getSession();

      if (session == null || session['username'] == null) {
        setState(() {
          _isGenerating = false;
          _errorMessage = 'Please login first';
        });
        return;
      }

      final username = session['username'];
      final credentials = await storage.getDeviceCredentials(username);

      if (credentials == null || credentials['secretKey'] == null) {
        setState(() {
          _isGenerating = false;
          _errorMessage = 'Secret key not found. Please re-activate device.';
        });
        return;
      }

      final secretKey = credentials['secretKey']!;

      // ✅ Use UTC time to match backend
      final timeInSeconds =
          DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
      final counter = timeInSeconds ~/ 30;

      print('🔑 SECRET KEY: $secretKey');
      print('⏰ Flutter UTC Time: ${DateTime.now().toUtc()}');
      print('🔄 Flutter Counter: $counter');

      // ✅ Same algorithm as backend: SHA256(secretKey + counter)
      final combined = '$secretKey:$counter';
      final bytes = utf8.encode(combined);
      final hash = sha256.convert(bytes);
      final hashString = hash.toString();

      // ✅ Extract 6 digits (same as backend)
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

      print('🎫 FLUTTER TOKEN: $tokenValue');

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

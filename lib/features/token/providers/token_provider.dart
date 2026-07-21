// lib/features/token/providers/token_provider.dart
import 'package:flutter/material.dart';
import 'dart:async';

class TokenProvider extends ChangeNotifier {
  String _token = '';
  bool _hasToken = false;
  bool _isGenerating = false;
  int _secondsRemaining = 30;
  Timer? _timer;

  String get token => _token;
  bool get hasToken => _hasToken;
  bool get isGenerating => _isGenerating;
  int get secondsRemaining => _secondsRemaining;

  void generateToken() {
    if (_isGenerating) return;

    _isGenerating = true;
    notifyListeners();

    // Simulate generation delay
    Future.delayed(const Duration(milliseconds: 500), () {
      // Generate a random 6-digit token
      final random = DateTime.now().millisecondsSinceEpoch;
      final tokenValue = (random % 900000 + 100000).toString();

      _token = tokenValue;
      _hasToken = true;
      _isGenerating = false;
      _secondsRemaining = 30;

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
        // When timer expires, clear the token (don't auto-generate)
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
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

// lib/features/token/presentation/widgets/token_display.dart
import 'package:flutter/material.dart';
import 'package:payroll_soft_token_app/core/theme/app_theme.dart';
import 'dart:async';

class TokenDisplay extends StatefulWidget {
  const TokenDisplay({super.key});

  @override
  State<TokenDisplay> createState() => TokenDisplayState();
}

class TokenDisplayState extends State<TokenDisplay> {
  String _token = 'No token generated yet';
  int _secondsRemaining = 30;
  Timer? _timer;
  bool _hasToken = false;

  @override
  void initState() {
    super.initState();
    generateToken();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void generateToken() {
    // Generate a random 6-digit token
    final random = DateTime.now().millisecondsSinceEpoch;
    final tokenValue = (random % 900000 + 100000).toString();

    setState(() {
      _token = tokenValue;
      _hasToken = true;
      _secondsRemaining = 30;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          timer.cancel();
          // Auto-generate new token when timer reaches 0
          generateToken();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Welcome Message
          const Text(
            'Welcome Abebe Berhe',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Click the button below to generate a new token',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Token Display Area
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                // Token Number
                Text(
                  _token,
                  style: TextStyle(
                    fontSize: _hasToken ? 40 : 24,
                    fontWeight: FontWeight.bold,
                    color: _hasToken
                        ? AppTheme.primaryColor
                        : Colors.grey.shade400,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 12),
                // Timer
                if (_hasToken) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        color: _secondsRemaining < 10
                            ? Colors.red
                            : Colors.grey.shade600,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Expires in ${_secondsRemaining} seconds',
                        style: TextStyle(
                          fontSize: 14,
                          color: _secondsRemaining < 10
                              ? Colors.red
                              : Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  // Progress indicator
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: _secondsRemaining / 30,
                    backgroundColor: Colors.grey.shade200,
                    color: _secondsRemaining < 10
                        ? Colors.red
                        : AppTheme.primaryColor,
                    minHeight: 4,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ] else ...[
                  Text(
                    'Generate a new token to get started',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  ),
                ],
              ],
            ),
          ),

          // Security Note
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.primaryColor.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Icon(Icons.security, color: AppTheme.primaryColor, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Keep your account secure. Never share your token with anyone',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

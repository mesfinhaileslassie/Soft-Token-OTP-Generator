// lib/features/activation/presentation/widgets/activation_timer.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:payroll_soft_token_app/core/theme/app_theme.dart';

class ActivationTimer extends StatefulWidget {
  final VoidCallback? onResend;

  const ActivationTimer({super.key, this.onResend});

  @override
  State<ActivationTimer> createState() => _ActivationTimerState();
}

class _ActivationTimerState extends State<ActivationTimer> {
  static const Color _pillColor = Color(0xFFFDECC8);
  static const Color _timeColor = Color(0xFFE0447B);

  int _secondsRemaining = 118; // 01:58
  Timer? _timer;
  bool _isExpired = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _isExpired = true;
          timer.cancel();
        }
      });
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _reset() {
    setState(() {
      _secondsRemaining = 118;
      _isExpired = false;
      _timer?.cancel();
      _startTimer();
    });
    widget.onResend?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: _pillColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.access_time, color: Colors.orange.shade800, size: 18),
          const SizedBox(width: 8),
          Text(
            _isExpired ? 'Code has expired' : 'Code expires in ',
            style: const TextStyle(
              color: Color(0xFF4A4A4A),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (!_isExpired)
            Text(
              _formatTime(_secondsRemaining),
              style: const TextStyle(
                color: _timeColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          if (_isExpired) ...[
            const SizedBox(width: 6),
            GestureDetector(
              onTap: _reset,
              child: Text(
                'Resend',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

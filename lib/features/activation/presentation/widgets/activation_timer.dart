// lib/features/activation/presentation/widgets/activation_timer.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:payroll_soft_token_app/core/theme/app_theme.dart';
class ActivationTimer extends StatefulWidget {
  const ActivationTimer({super.key});

  @override
  State<ActivationTimer> createState() => _ActivationTimerState();
}

class _ActivationTimerState extends State<ActivationTimer> {
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: _isExpired ? Colors.red.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _isExpired ? Colors.red.shade200 : Colors.orange.shade200,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timer_outlined,
            color: _isExpired ? Colors.red : Colors.orange.shade700,
            size: 20,
          ),
          const SizedBox(width: 10),
          Text(
            'Code expires in ',
            style: TextStyle(
              color: _isExpired ? Colors.red.shade700 : Colors.orange.shade700,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            _isExpired ? 'Expired!' : _formatTime(_secondsRemaining),
            style: TextStyle(
              color: _isExpired ? Colors.red.shade700 : Colors.orange.shade700,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (_isExpired) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                setState(() {
                  _secondsRemaining = 118;
                  _isExpired = false;
                  _timer?.cancel();
                  _startTimer();
                });
              },
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

// lib/features/auth/presentation/widgets/login_header.dart
import 'package:flutter/material.dart';
import 'package:payroll_soft_token_app/core/constants/app_constants.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Shield Icon - EXACTLY as design (white background with red shield)
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.shield, size: 34, color: Color(0xFF9E0000)),
        ),
        const SizedBox(height: 14),
        // Welcome Back - EXACTLY as design
        const Text(
          'Welcome Back',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 6),
        // Subtitle - EXACTLY as design
        Text(
          'Please login to continue',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.8),
            fontWeight: FontWeight.w400,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

// lib/features/auth/presentation/widgets/login_header.dart
import 'package:flutter/material.dart';
import 'package:payroll_soft_token_app/core/constants/app_constants.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Soft Token text
        const Text(
          'Soft Token',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.white70,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 6),
        // Shield Icon
        Container(
          width: 48,
          height: 48,
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
          child: const Icon(Icons.shield, size: 24, color: Color(0xFF9E0000)),
        ),
        const SizedBox(height: 8),
        // Title
        const Text(
          'Welcome Back',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        // Subtitle
        Text(
          'Please login to continue',
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.85),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

// lib/features/auth/presentation/widgets/register_header.dart
import 'package:flutter/material.dart';

class RegisterHeader extends StatelessWidget {
  const RegisterHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Shield Icon - Smaller
        Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.person_add,
            size: 28,
            color: Color(0xFF9E0000),
          ),
        ),
        const SizedBox(height: 10),
        // Create Your Account - Smaller font
        const Text(
          'Create Your Account',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        // Subtitle - Smaller font
        Text(
          'Join soft token and unlock a secure experience',
          style: TextStyle(
            fontSize: 13,
            color: Colors.white.withOpacity(0.85),
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

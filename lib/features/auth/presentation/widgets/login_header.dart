// lib/features/auth/presentation/widgets/login_header.dart
import 'package:flutter/material.dart';
import 'package:payroll_soft_token_app/core/theme/app_theme.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  static const Color _subtitleColor = Color(0xFFF5A623);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Shield badge sits centered on the red/white boundary.
        const _ShieldBadge(),
        const SizedBox(height: 18),

        // Title
        const Text(
          'Welcome Back',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 8),

        // Subtitle
        const Text(
          'Please login to continue',
          style: TextStyle(
            fontSize: 14,
            color: _subtitleColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ShieldBadge extends StatelessWidget {
  const _ShieldBadge();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 116,
      height: 116,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // White fill so the red banner doesn't show through the outline.
          const Icon(Icons.shield, size: 116, color: Colors.white),
          Icon(Icons.shield_outlined, size: 116, color: AppTheme.primaryColor),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              'Soft\nToken',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                height: 1.2,
                color: const Color(0xFF1A1A1A),
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

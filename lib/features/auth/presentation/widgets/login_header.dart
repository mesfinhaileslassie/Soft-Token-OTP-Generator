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
        // Shield badge (white fill, primary-colored outline, "Soft Token"
        // wordmark inside). Sits centered on the red/white boundary.
        const _ShieldBadge(),
        const SizedBox(height: 14),

        // Title
        const Text(
          'Welcome Back',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 6),

        // Subtitle
        const Text(
          'Please login to continue',
          style: TextStyle(
            fontSize: 13,
            color: _subtitleColor,
            fontWeight: FontWeight.w500,
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
    return Container(
      width: 92,
      height: 92,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Center(
        child: SizedBox(
          width: 62,
          height: 62,
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(Icons.shield, size: 62, color: Colors.white),
              Icon(
                Icons.shield_outlined,
                size: 62,
                color: AppTheme.primaryColor,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'Soft\nToken',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.bold,
                    height: 1.15,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

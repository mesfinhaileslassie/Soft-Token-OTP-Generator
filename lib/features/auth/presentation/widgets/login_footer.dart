// lib/features/auth/presentation/widgets/login_footer.dart

import 'package:flutter/material.dart';

class LoginFooter extends StatelessWidget {
  const LoginFooter({super.key});

  static const Color _linkColor = Color(0xFFF5A623);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Secured by soft token
        const Text(
          'Secured by soft token',
          style: TextStyle(
            color: Color(0xFF9E9E9E),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 20),
        // ❌ REMOVED: The "Don't have an account? Sign Up" row was here.
        // The sign-up link is no longer displayed.
      ],
    );
  }
}

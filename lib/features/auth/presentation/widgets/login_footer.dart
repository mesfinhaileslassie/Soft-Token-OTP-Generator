// lib/features/auth/presentation/widgets/login_footer.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:payroll_soft_token_app/app/routes/app_router.dart';

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

        // Don't have an account? Sign Up
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Don't have an account? ",
              style: TextStyle(
                color: Color(0xFF666666),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            GestureDetector(
              onTap: () {
                context.push(AppRouter.register);
              },
              child: const Text(
                'Sign Up',
                style: TextStyle(
                  color: _linkColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

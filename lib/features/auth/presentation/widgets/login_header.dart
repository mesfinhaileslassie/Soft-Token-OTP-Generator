// lib/features/auth/presentation/widgets/login_header.dart
import 'package:flutter/material.dart';
import 'package:payroll_soft_token_app/core/constants/app_constants.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // App Logo/Icon Placeholder
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.shield, size: 40, color: Colors.white),
        ),
        const SizedBox(height: 24),
        Text(
          AppConstants.welcomeBack,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          AppConstants.loginSubtitle,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

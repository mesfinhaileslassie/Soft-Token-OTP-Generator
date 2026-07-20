// lib/features/activation/presentation/screens/activation_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:payroll_soft_token_app/app/routes/app_router.dart';
import 'package:payroll_soft_token_app/core/theme/app_theme.dart';
import 'package:payroll_soft_token_app/features/activation/presentation/widgets/activation_form.dart';
import 'package:payroll_soft_token_app/features/activation/presentation/widgets/activation_header.dart';
import 'package:payroll_soft_token_app/features/activation/presentation/widgets/activation_timer.dart';

class ActivationScreen extends StatelessWidget {
  const ActivationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header with #9E0000 background - Pushed UP with less padding
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                top: 8, // Reduced from 24 to 8
                bottom: 16, // Reduced from 20 to 16
              ),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const ActivationHeader(),
            ),
            // Form and Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const ActivationForm(),
                    const SizedBox(height: 12),
                    const ActivationTimer(),
                    const SizedBox(height: 16),
                    // Back to Home
                    Center(
                      child: TextButton(
                        onPressed: () {
                          context.go(AppRouter.home);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: const Text(
                          'Back to Home',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

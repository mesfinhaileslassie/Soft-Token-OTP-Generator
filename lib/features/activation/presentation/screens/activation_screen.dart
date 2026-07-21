// lib/features/activation/presentation/screens/activation_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:payroll_soft_token_app/app/routes/app_router.dart';
import 'package:payroll_soft_token_app/core/theme/app_theme.dart';
import 'package:payroll_soft_token_app/features/activation/presentation/widgets/activation_footer.dart';
import 'package:payroll_soft_token_app/features/activation/presentation/widgets/activation_form.dart';
import 'package:payroll_soft_token_app/features/activation/presentation/widgets/activation_header.dart';

class ActivationScreen extends StatelessWidget {
  const ActivationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Remove SafeArea so header goes behind status bar
      body: Column(
        children: [
          // Header with primary color background — goes behind status bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 48, bottom: 20),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Device verification, digit boxes, expiry timer, resend
                  // row, and the Activate button all live inside the form
                  // widget so their order stays in sync with the countdown.
                  const ActivationForm(),
                  const SizedBox(height: 12),

                  // Back to home — outlined button
                  OutlinedButton(
                    onPressed: () {
                      context.go(AppRouter.home);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1A1A1A),
                      side: BorderSide(
                        color: Colors.orange.shade300,
                        width: 1.5,
                      ),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: const Text('Back to home'),
                  ),
                  const SizedBox(height: 24),

                  const ActivationTrustDivider(),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

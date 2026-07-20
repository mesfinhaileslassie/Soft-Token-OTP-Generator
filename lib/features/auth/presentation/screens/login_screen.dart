// lib/features/auth/presentation/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:payroll_soft_token_app/core/theme/app_theme.dart';
import 'package:payroll_soft_token_app/features/auth/presentation/widgets/login_footer.dart';
import 'package:payroll_soft_token_app/features/auth/presentation/widgets/login_form.dart';
import 'package:payroll_soft_token_app/features/auth/presentation/widgets/login_header.dart';
import 'package:payroll_soft_token_app/features/auth/providers/auth_provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Set navigation context for AuthProvider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.setNavigationContext(context);

    return Scaffold(
      backgroundColor: Colors.white,
      // Remove SafeArea so header goes behind status bar
      body: Column(
        children: [
          // Header with #9E0000 background - Goes behind status bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 40, // Space for status bar (time, wifi, battery)
              bottom: 16,
            ),
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
            child: const LoginHeader(),
          ),
          // Form and Footer
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: const [
                  SizedBox(height: 24),
                  LoginForm(),
                  SizedBox(height: 24),
                  LoginFooter(),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

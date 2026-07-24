// lib/features/auth/presentation/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:payroll_soft_token_app/core/theme/app_theme.dart';
import 'package:payroll_soft_token_app/core/services/storage_service.dart';
import 'package:payroll_soft_token_app/core/services/api_service.dart';
import 'package:payroll_soft_token_app/features/auth/providers/auth_provider.dart';
import 'package:payroll_soft_token_app/features/auth/presentation/widgets/login_form.dart';
import 'package:payroll_soft_token_app/features/auth/presentation/widgets/login_header.dart';
import 'package:payroll_soft_token_app/features/auth/presentation/widgets/login_footer.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  static const double _bannerHeight = 130;

  @override
  Widget build(BuildContext context) {
    // Set navigation context for AuthProvider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.setNavigationContext(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background split: red banner on top, white for the rest.
          Column(
            children: [
              Container(
                height: _bannerHeight,
                width: double.infinity,
                color: AppTheme.primaryColor,
              ),
              const Expanded(child: ColoredBox(color: Colors.white)),
            ],
          ),
          // Foreground scrollable content
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        const LoginHeader(),
                        const SizedBox(height: 32),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            children: [
                              const LoginForm(),
                              const SizedBox(height: 28),
                              const LoginFooter(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

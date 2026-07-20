// lib/features/token/presentation/screens/token_screen.dart
import 'package:flutter/material.dart';
import 'package:payroll_soft_token_app/core/theme/app_theme.dart';
import 'package:payroll_soft_token_app/features/token/presentation/widgets/token_header.dart';
import 'package:payroll_soft_token_app/features/token/presentation/widgets/token_display.dart';
import 'package:payroll_soft_token_app/features/token/presentation/widgets/token_actions.dart';

class TokenScreen extends StatelessWidget {
  const TokenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header with #9E0000 background
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
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
              child: const TokenHeader(),
            ),
            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Column(
                  children: const [
                    TokenDisplay(),
                    SizedBox(height: 24),
                    TokenActions(),
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

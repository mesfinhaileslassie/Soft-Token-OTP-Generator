// lib/features/auth/presentation/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:payroll_soft_token_app/core/theme/app_theme.dart';
import 'package:payroll_soft_token_app/features/auth/presentation/widgets/login_footer.dart';
import 'package:payroll_soft_token_app/features/auth/presentation/widgets/login_form.dart';
import 'package:payroll_soft_token_app/features/auth/presentation/widgets/login_header.dart';

/// Full login page.
///
/// Layout: a fixed red banner sits behind the top of the screen, the rest
/// of the screen is white, and the shield badge is positioned so it
/// straddles the red/white boundary — matching the design mock.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  static const double _bannerHeight = 130;

  @override
  Widget build(BuildContext context) {
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

          // Foreground scrollable content, laid on top of the split
          // background so the shield badge can overlap both halves.
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 32),
              child: Column(
                children: [
                  const SizedBox(height: 46),
                  const LoginHeader(),
                  const SizedBox(height: 28),
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
          ),
        ],
      ),
    );
  }
}

// lib/features/token/presentation/widgets/token_actions.dart
import 'package:flutter/material.dart';
import 'package:payroll_soft_token_app/core/theme/app_theme.dart';
import 'token_display.dart';

class TokenActions extends StatelessWidget {
  const TokenActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Generate Token Button
        ElevatedButton(
          onPressed: () {
            // The token will be regenerated in TokenDisplay
            // We need to find and refresh the TokenDisplay widget
            final tokenDisplayState = context
                .findAncestorStateOfType<TokenDisplayState>();
            tokenDisplayState?.generateToken();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          child: const Text('Generate Token'),
        ),
        const SizedBox(height: 16),

        // Security Note
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.amber.shade200),
          ),
          child: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.amber.shade700,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Keep your account secure\nNever share your token with anyone',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.amber.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

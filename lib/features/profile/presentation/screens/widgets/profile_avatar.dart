// lib/features/profile/presentation/widgets/profile_avatar.dart
import 'package:flutter/material.dart';
import 'package:payroll_soft_token_app/core/theme/app_theme.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Large Avatar
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.primaryColor, width: 4),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.person,
            size: 60,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 16),
        // User Name
        const Text(
          'Abebe Berhe',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'abebe.berhe@example.com',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:payroll_soft_token_app/core/theme/app_theme.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.12),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.person, size: 56, color: AppTheme.primaryColor),
    );
  }
}

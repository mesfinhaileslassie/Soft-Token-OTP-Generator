import 'package:flutter/material.dart';
import 'package:payroll_soft_token_app/core/theme/app_theme.dart';

class ProfileInfo extends StatelessWidget {
  const ProfileInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: const [
          Text(
            'Abebe Berhe',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 8),
          Text(
            'employee@payroll.com',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          SizedBox(height: 6),
          Text(
            'Staff Member',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

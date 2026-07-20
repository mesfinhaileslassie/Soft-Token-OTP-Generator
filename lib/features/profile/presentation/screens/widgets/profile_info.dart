// lib/features/profile/presentation/widgets/profile_info.dart
import 'package:flutter/material.dart';
import 'package:payroll_soft_token_app/core/theme/app_theme.dart';

class ProfileInfo extends StatelessWidget {
  const ProfileInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: const Text(
              'Your Account Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          // Account Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoRow('Full Name', 'Abebe Berhe'),
                const Divider(color: Color(0xFFE0E0E0)),
                _buildInfoRow('Email', 'abebe.berhe@example.com'),
                const Divider(color: Color(0xFFE0E0E0)),
                _buildInfoRow('Phone', '+251 912 345 678'),
                const Divider(color: Color(0xFFE0E0E0)),
                _buildInfoRow('Gender', 'Male'),
                const Divider(color: Color(0xFFE0E0E0)),
                _buildInfoRow('Device Status', 'Active'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A1A1A),
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

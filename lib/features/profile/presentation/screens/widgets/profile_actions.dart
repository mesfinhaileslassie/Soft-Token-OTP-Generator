// lib/features/profile/presentation/widgets/profile_actions.dart
import 'package:flutter/material.dart';
import 'package:payroll_soft_token_app/core/theme/app_theme.dart';

class ProfileActions extends StatelessWidget {
  const ProfileActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Change Password Button
        _buildActionCard(
          context,
          icon: Icons.lock_outline,
          title: 'Change Password',
          subtitle: 'Update your account password',
          color: AppTheme.primaryColor,
          onTap: () {
            // TODO: Navigate to Change Password screen
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Change Password screen coming soon!'),
                duration: Duration(seconds: 2),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        // Device Management
        _buildActionCard(
          context,
          icon: Icons.devices_outlined,
          title: 'Device Management',
          subtitle: 'Manage your registered devices',
          color: Colors.green.shade700,
          onTap: () {
            // TODO: Navigate to Device Management screen
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Device Management coming soon!'),
                duration: Duration(seconds: 2),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey.shade400,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

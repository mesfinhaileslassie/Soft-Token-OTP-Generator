import 'package:flutter/material.dart';
import 'package:payroll_soft_token_app/core/theme/app_theme.dart';

class ProfileActions extends StatelessWidget {
  const ProfileActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.lock_outline, color: AppTheme.primaryColor),
          title: const Text('Change Password'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {},
        ),
        const Divider(),
        ListTile(
          leading: const Icon(
            Icons.settings_outlined,
            color: AppTheme.primaryColor,
          ),
          title: const Text('Settings'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {},
        ),
      ],
    );
  }
}

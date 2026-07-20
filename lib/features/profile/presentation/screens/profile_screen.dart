// lib/features/profile/presentation/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:payroll_soft_token_app/app/routes/app_router.dart';
import 'package:payroll_soft_token_app/core/theme/app_theme.dart';
import 'package:payroll_soft_token_app/features/profile/presentation/widgets/profile_avatar.dart';
import 'package:payroll_soft_token_app/features/profile/presentation/widgets/profile_info.dart';
import 'package:payroll_soft_token_app/features/profile/presentation/widgets/profile_actions.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            context.go(AppRouter.home);
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              _showLogoutDialog(context);
            },
            child: const Text(
              'Log out',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Avatar
            const ProfileAvatar(),
            const SizedBox(height: 24),
            // Profile Information
            const ProfileInfo(),
            const SizedBox(height: 24),
            // Profile Actions
            const ProfileActions(),
            const SizedBox(height: 16),
            // Back to Home Button
            _buildBackToHomeButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBackToHomeButton(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () {
          context.go(AppRouter.home);
        },
        borderRadius: BorderRadius.circular(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.home_outlined, color: AppTheme.primaryColor, size: 20),
            const SizedBox(width: 8),
            Text(
              'Back to Home',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward, color: AppTheme.primaryColor, size: 16),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Navigate to login screen
                context.go(AppRouter.login);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}

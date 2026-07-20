// lib/features/home/presentation/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:payroll_soft_token_app/app/routes/app_router.dart';
import 'package:payroll_soft_token_app/core/theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Soft Token',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            const Text(
              'Welcome!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Manage your device registration and security',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 32),

            // Register Device Card
            _buildMenuItem(
              context,
              icon: Icons.devices,
              title: 'Register Device',
              subtitle: 'Register your device with Payroll System',
              color: AppTheme.primaryColor,
              onTap: () {
                context.push(AppRouter.deviceRegistration);
              },
            ),

            const SizedBox(height: 16),

            // Generate Token Card
            _buildMenuItem(
              context,
              icon: Icons.security,
              title: 'Generate Token',
              subtitle: 'Generate soft token for authentication',
              color: Colors.green.shade700,
              onTap: () {
                context.push(AppRouter.token);
              },
            ),

            const SizedBox(height: 16),

            // My Profile Card
            _buildMenuItem(
              context,
              icon: Icons.person_outline,
              title: 'My Profile',
              subtitle: 'View and update your profile information',
              color: Colors.blue.shade700,
              onTap: () {
                context.push(AppRouter.profile);
              },
            ),

            const SizedBox(height: 16),

            // Settings Card
            _buildMenuItem(
              context,
              icon: Icons.settings_outlined,
              title: 'Settings',
              subtitle: 'App settings and preferences',
              color: Colors.orange.shade700,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Settings coming soon!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon Container
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              // Title and Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
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
              // Arrow Icon
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

// lib/features/profile/presentation/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:payroll_soft_token_app/app/routes/app_router.dart';
import 'package:payroll_soft_token_app/core/theme/app_theme.dart';
import 'package:payroll_soft_token_app/core/services/storage_service.dart';
import 'package:payroll_soft_token_app/features/profile/presentation/screens/change_password_screen.dart';

/// Local palette used only for the profile screen's visual redesign.
/// Kept here (instead of touching AppTheme) so no other screen is affected.
class _ProfilePalette {
  static const Color headerPillColor = Color(0xFFB05066);
  static const Color cardBorder = Color(0xFFE8A93D);
  static const Color iconAccent = Color(0xFFE8A93D);
  static const Color actionCardBg = Color(0xFFFBE6C3);
  static const Color actionTitleColor = Color(0xFF8E1B1B);
  static const Color labelGrey = Color(0xFF8A8A8A);
  static const Color valueDark = Color(0xFF1A1A1A);
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final storage = await StorageService.getInstance();
      final session = await storage.getSession();

      if (session != null && session['username'] != null) {
        final user = await storage.getUser(session['username']);
        setState(() {
          _userData = user;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // The old AppBar's title/back-button look has been replaced by the
      // custom maroon header below (built with SafeArea) so it visually
      // matches the Figma design while still sitting at the top of the
      // screen exactly as the AppBar used to.
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _userData == null
                ? const Center(child: Text('No user data found'))
                : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your account details',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Your Account Details
                        _buildAccountDetails(),
                        const SizedBox(height: 20),

                        // Change Password
                        _buildChangePassword(context),
                        const SizedBox(height: 14),

                        // Back to Home Button
                        _buildBackToHomeButton(context),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  /// Custom maroon header replacing the old AppBar look: avatar + title on
  /// top, and a "Back to Home" pill alongside "Log out" beneath it — all
  /// inside the same colored surface, matching the Figma design.
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: AppTheme.primaryColor),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'My profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildBackToHome(context),
                  TextButton.icon(
                    onPressed: () {
                      _showLogoutDialog(context);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    icon: const Icon(
                      Icons.logout,
                      size: 16,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Log out',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackToHome(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.go(AppRouter.token);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: _ProfilePalette.headerPillColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.arrow_back, color: Colors.white, size: 16),
            SizedBox(width: 6),
            Text(
              'Back to Home',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountDetails() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _ProfilePalette.cardBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(
            Icons.person_outline,
            'Firstname',
            _userData?['firstName'] ?? 'N/A',
          ),
          const SizedBox(height: 18),
          _buildInfoRow(
            Icons.person_outline,
            'Lastname',
            _userData?['lastName'] ?? 'N/A',
          ),
          const SizedBox(height: 18),
          _buildInfoRow(
            Icons.wc_outlined,
            'Gender',
            _userData?['gender'] ?? 'N/A',
          ),
          const SizedBox(height: 18),
          _buildInfoRow(
            Icons.phone_outlined,
            'Phone',
            _userData?['phone'] ?? 'N/A',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: _ProfilePalette.iconAccent, size: 22),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: _ProfilePalette.labelGrey,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _ProfilePalette.valueDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChangePassword(BuildContext context) {
    return _ActionCard(
      icon: Icons.lock_outline,
      title: 'Change Password',
      subtitle: 'Update your account password',
      onTap: () {
        context.push('/change-password');
      },
    );
  }

  Widget _buildBackToHomeButton(BuildContext context) {
    return _ActionCard(
      icon: Icons.home_outlined,
      title: 'Back to Home',
      subtitle: 'Return to Home Page',
      onTap: () {
        context.go(AppRouter.token);
      },
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

/// Reusable tan/gold action card used for "Change Password" and
/// "Back to Home" entries, matching the Figma design.
class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _ProfilePalette.actionCardBg,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _ProfilePalette.iconAccent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _ProfilePalette.actionTitleColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: _ProfilePalette.actionTitleColor,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

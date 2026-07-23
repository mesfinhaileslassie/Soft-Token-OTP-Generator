// lib/features/token/presentation/screens/token_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:payroll_soft_token_app/app/routes/app_router.dart';
import 'package:payroll_soft_token_app/core/theme/app_theme.dart';
import 'package:payroll_soft_token_app/features/token/providers/token_provider.dart';
import 'package:payroll_soft_token_app/core/services/storage_service.dart';
import 'package:provider/provider.dart';

class TokenScreen extends StatefulWidget {
  const TokenScreen({super.key});

  @override
  State<TokenScreen> createState() => _TokenScreenState();
}

class _TokenScreenState extends State<TokenScreen> {
  String _userName = 'User';

  // Shared amber palette used across the token card / security note so the
  // page reads as one cohesive design (matches the Figma reference).
  static const Color _amberBg = Color(0xFFF9E7C4);
  static const Color _amberBgSoft = Color(0xFFFBEFD6);
  static const Color _amberAccent = Color(0xFFE8A33D);
  static const Color _amberText = Color(0xFFB8790C);

  @override
  void initState() {
    super.initState();
    _loadUserName();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TokenProvider>().reset();
    });
  }

  Future<void> _loadUserName() async {
    try {
      final storage = await StorageService.getInstance();
      final session = await storage.getSession();
      if (session != null && session['username'] != null) {
        final user = await storage.getUser(session['username']);
        if (user != null) {
          final firstName = user['firstName'] ?? '';
          final lastName = user['lastName'] ?? '';
          if (firstName.isNotEmpty || lastName.isNotEmpty) {
            setState(() {
              _userName = '$firstName $lastName'.trim();
            });
          } else {
            setState(() {
              _userName = session['username'];
            });
          }
        }
      }
    } catch (e) {
      print('Error loading user name: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header with primary color background
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 40, bottom: 16),
            decoration: const BoxDecoration(color: AppTheme.primaryColor),
            child: _buildHeader(context),
          ),
          // Main Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _TokenBadge(),
                  const SizedBox(height: 18),

                  Text(
                    'Welcome $_userName',
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Click the button below to generate a new token',
                    style: TextStyle(
                      fontSize: 13.5,
                      color: Colors.grey.shade600,
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Device Status
                  Consumer<TokenProvider>(
                    builder: (context, tokenProvider, child) {
                      if (tokenProvider.isChecking) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  'Checking device status...',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),

                  // Error Message
                  Consumer<TokenProvider>(
                    builder: (context, tokenProvider, child) {
                      if (tokenProvider.errorMessage.isNotEmpty &&
                          !tokenProvider.canGenerate) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.red.shade700,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Device Not Active',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.red.shade700,
                                        ),
                                      ),
                                      Text(
                                        tokenProvider.errorMessage,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.red.shade600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      TextButton(
                                        onPressed: () {
                                          context.push(
                                            AppRouter.deviceRegistration,
                                          );
                                        },
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                          minimumSize: const Size(0, 0),
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: Text(
                                          'Go to Device Registration',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppTheme.primaryColor,
                                            fontWeight: FontWeight.w500,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),

                  // Token Display Card
                  Consumer<TokenProvider>(
                    builder: (context, tokenProvider, child) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 30,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          color: _amberBg,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          children: [
                            if (!tokenProvider.hasToken) ...[
                              const Icon(
                                Icons.mark_chat_read_outlined,
                                size: 40,
                                color: Color(0xFF1A1A1A),
                              ),
                              const SizedBox(height: 14),
                              const Text(
                                'No token generated yet',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A1A1A),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Generate a new token to get started.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ] else ...[
                              Text(
                                tokenProvider.token,
                                style: const TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A1A1A),
                                  letterSpacing: 6,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'Expires in ${tokenProvider.secondsRemaining} seconds',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: tokenProvider.secondsRemaining < 10
                                      ? Colors.red.shade700
                                      : _amberText,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: LinearProgressIndicator(
                                  value: tokenProvider.secondsRemaining / 30,
                                  backgroundColor: _amberAccent.withOpacity(
                                    0.25,
                                  ),
                                  color: tokenProvider.secondsRemaining < 10
                                      ? Colors.red.shade700
                                      : AppTheme.primaryColor,
                                  minHeight: 5,
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 18),

                  // Generate Token Button
                  Consumer<TokenProvider>(
                    builder: (context, tokenProvider, child) {
                      return ElevatedButton(
                        onPressed:
                            (!tokenProvider.canGenerate ||
                                tokenProvider.isGenerating)
                            ? null
                            : () => tokenProvider.generateToken(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: tokenProvider.canGenerate
                              ? AppTheme.primaryColor
                              : Colors.grey.shade400,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                        child: tokenProvider.isGenerating
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (tokenProvider.canGenerate) ...[
                                    const Icon(
                                      Icons.vpn_key_outlined,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                  Text(
                                    tokenProvider.canGenerate
                                        ? 'Generate token'
                                        : 'Device Not Active',
                                  ),
                                ],
                              ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Security Note
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: _amberBgSoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Keep your account secure',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  color: Color(0xFF1A1A1A),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Never share your token with anyone',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(Icons.lock_outline, color: _amberAccent, size: 22),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Profile Button
          GestureDetector(
            onTap: () {
              context.push(AppRouter.profile);
            },
            child: Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                color: AppTheme.primaryColor,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: () {
                context.push(AppRouter.profile);
              },
              child: Text(
                _userName,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          // Logout Button
          TextButton.icon(
            onPressed: () {
              _showLogoutDialog(context);
            },
            icon: const Icon(Icons.logout, color: Colors.white, size: 17),
            label: const Text(
              'Logout',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
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

/// Concentric amber "shield + lock" badge shown under the header,
/// matching the Figma reference. Purely decorative — no state involved.
class _TokenBadge extends StatelessWidget {
  const _TokenBadge();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 128,
        height: 128,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF9E7C4),
              ),
            ),
            Container(
              width: 92,
              height: 92,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFF3D28F),
              ),
            ),
            Container(
              width: 62,
              height: 62,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryColor,
              ),
              child: const Icon(Icons.lock, color: Colors.white, size: 28),
            ),
          ],
        ),
      ),
    );
  }
}

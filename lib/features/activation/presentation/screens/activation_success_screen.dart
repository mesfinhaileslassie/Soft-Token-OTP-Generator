// lib/features/activation/presentation/screens/activation_success_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:payroll_soft_token_app/app/routes/app_router.dart';
import 'package:payroll_soft_token_app/core/theme/app_theme.dart';
import 'package:payroll_soft_token_app/core/services/storage_service.dart';

class ActivationSuccessScreen extends StatelessWidget {
  const ActivationSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Set flag when this screen is shown
    _setDeviceRegisteredFlag();

    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header with #9E0000 background — extends behind status bar
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(top: statusBarHeight + 16, bottom: 16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'Soft Token',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Activation Successful',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your device is ready to use',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.85),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          // Main Content
          Expanded(
            child: SafeArea(
              top: false, // header already handles the status bar
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Tick icon with scattered star decorations, like the design
                    SizedBox(
                      width: 200,
                      height: 200,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Faint outer ring
                          Container(
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF26D560).withOpacity(0.3),
                                width: 1.5,
                              ),
                            ),
                          ),
                          // Scattered stars around the ring
                          const _Sparkle(top: 8, left: 60, size: 12),
                          const _Sparkle(top: 20, right: 30, size: 16),
                          const _Sparkle(top: 70, right: 4, size: 10),
                          const _Sparkle(bottom: 60, right: 10, size: 14),
                          const _Sparkle(bottom: 15, right: 55, size: 10),
                          const _Sparkle(bottom: 15, left: 55, size: 10),
                          const _Sparkle(bottom: 60, left: 6, size: 14),
                          const _Sparkle(top: 65, left: 0, size: 10),
                          // Center circle with tick
                          Container(
                            width: 100,
                            height: 100,
                            decoration: const BoxDecoration(
                              color: Color(0xFF26D560),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              size: 52,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Congratulations!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your Device is now activated successfully',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: 220,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          context.go(AppRouter.token);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        child: const Text('Continue to Home'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _setDeviceRegisteredFlag() async {
    try {
      final storage = await StorageService.getInstance();
      await storage.setDeviceRegisteredOffline(true);
      print('✅ Device registration flag set to true (offline)');
    } catch (e) {
      print('Error setting device registered flag: $e');
    }
  }
}

/// Small star/sparkle decoration positioned around the tick circle,
/// matching the scattered stars in the design.
class _Sparkle extends StatelessWidget {
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final double size;

  const _Sparkle({
    this.top,
    this.bottom,
    this.left,
    this.right,
    this.size = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Icon(
        Icons.auto_awesome,
        size: size,
        color: const Color(0xFF26D560).withOpacity(0.7),
      ),
    );
  }
}

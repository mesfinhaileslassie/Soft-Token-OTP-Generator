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

    _setDeviceRegisteredFlag();

    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
        
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
                          // Scattered sunny icons around the ring
                          const _Sunny(top: 8, left: 55, size: 16),
                          const _Sunny(top: 25, right: 25, size: 18),
                          const _Sunny(top: 75, right: 0, size: 16),
                          const _Sunny(bottom: 65, right: 5, size: 16),
                          const _Sunny(bottom: 10, right: 50, size: 16),
                          const _Sunny(bottom: 10, left: 50, size: 16),
                          const _Sunny(bottom: 65, left: 0, size: 16),
                          const _Sunny(top: 70, left: 0, size: 14),
                          // Shield icon with tick, like the design
                          const Icon(
                            Icons.gpp_good,
                            size: 110,
                            color: Color(0xFF26D560),
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
                        child: const Text('Continue to login'),
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
      print(' Device registration flag set to true (offline)');
    } catch (e) {
      print('Error setting device registered flag: $e');
    }
  }
}

class _Sunny extends StatelessWidget {
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final double size;

  const _Sunny({this.top, this.bottom, this.left, this.right, this.size = 16});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Icon(
        Icons.wb_sunny,
        size: size,
        color: const Color(0xFF26D560).withOpacity(0.6),
      ),
    );
  }
}

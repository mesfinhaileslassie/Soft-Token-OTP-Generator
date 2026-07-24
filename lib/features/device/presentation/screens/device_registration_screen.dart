// lib/features/device/presentation/screens/device_registration_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:payroll_soft_token_app/app/routes/app_router.dart';
import 'package:payroll_soft_token_app/core/theme/app_theme.dart';
import 'package:payroll_soft_token_app/features/device/presentation/widgets/device_info_card.dart';
import 'package:payroll_soft_token_app/features/device/presentation/widgets/device_code_generator.dart';

class DeviceRegistrationScreen extends StatelessWidget {
  const DeviceRegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _BrandAppBar(),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Slightly wider padding on larger / tablet screens, tighter on
            // small phones, so the layout stays balanced on any device size.
            final horizontalPadding = constraints.maxWidth > 600 ? 32.0 : 20.0;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 20,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Device Registration',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Register your device with the Payroll System',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 22),

                    const DeviceInfoCard(),
                    const SizedBox(height: 22),

                    const DeviceCodeGenerator(),
                    const SizedBox(height: 22),

                    // Activate Device Button
                    ElevatedButton(
                      onPressed: () {
                        context.push(AppRouter.activation);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
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
                      child: const Text('Activate Device'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Brand header used across registration flow screens: a solid primary-color
/// bar with a shield logo and "WELLCOME" wordmark, matching the Figma design.
/// The existing back-navigation behavior is preserved unchanged.
class _BrandAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _BrandAppBar();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.primaryColor,
      elevation: 0,
      centerTitle: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shield_rounded,
              color: AppTheme.primaryColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'WELLCOME',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

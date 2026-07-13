// lib/features/device/presentation/screens/device_registration_screen.dart
import 'package:flutter/material.dart';
import 'package:payroll_soft_token_app/features/device/presentation/widgets/device_info_card.dart';
import 'package:payroll_soft_token_app/features/device/presentation/widgets/device_code_generator.dart';
import 'package:payroll_soft_token_app/core/theme/app_theme.dart';

class DeviceRegistrationScreen extends StatelessWidget {
  const DeviceRegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Device Registration',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DeviceInfoCard(),
            SizedBox(height: 24),
            DeviceCodeGenerator(),
          ],
        ),
      ),
    );
  }
}

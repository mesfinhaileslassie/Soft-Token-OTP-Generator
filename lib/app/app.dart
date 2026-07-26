// lib/app/app.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:payroll_soft_token_app/app/routes/app_router.dart';
import 'package:payroll_soft_token_app/features/auth/providers/auth_provider.dart';

class SoftTokenApp extends StatelessWidget {
  const SoftTokenApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return MaterialApp.router(
      title: 'Soft Token',
      theme: ThemeData.light(),
      routerConfig: AppRouter.router(authProvider: authProvider),
    );
  }
}

// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:payroll_soft_token_app/app/app.dart';
import 'package:payroll_soft_token_app/features/auth/providers/auth_provider.dart';
import 'package:payroll_soft_token_app/features/token/providers/token_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TokenProvider()),
      ],
      child: const SoftTokenApp(),
    ),
  );
}

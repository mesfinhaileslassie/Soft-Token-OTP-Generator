// lib/app/routes/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:payroll_soft_token_app/features/auth/presentation/screens/login_screen.dart';
import 'package:payroll_soft_token_app/features/auth/presentation/screens/register_screen.dart';
// import 'package:payroll_soft_token_app/features/device/presentation/screens/device_registration_screen.dart';

class AppRouter {
  static const String login = '/login';
  static const String register = '/register';
  static const String deviceRegistration = '/device-registration';
  static const String home = '/home';

  static final GoRouter router = GoRouter(
    initialLocation: login,
    redirect: (context, state) {
      return null;
    },
    routes: [
      GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      // Comment out device registration for now
      // GoRoute(
      //   path: deviceRegistration,
      //   name: 'device-registration',
      //   builder: (context, state) => const DeviceRegistrationScreen(),
      // ),
    ],
  );
}

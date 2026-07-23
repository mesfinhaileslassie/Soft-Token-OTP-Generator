// lib/app/routes/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:payroll_soft_token_app/features/auth/presentation/screens/login_screen.dart';
import 'package:payroll_soft_token_app/features/auth/presentation/screens/register_screen.dart';
import 'package:payroll_soft_token_app/features/token/presentation/screens/token_screen.dart';
import 'package:payroll_soft_token_app/features/device/presentation/screens/device_registration_screen.dart';
import 'package:payroll_soft_token_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:payroll_soft_token_app/features/profile/presentation/screens/change_password_screen.dart';
import 'package:payroll_soft_token_app/features/activation/presentation/screens/activation_screen.dart';
import 'package:payroll_soft_token_app/features/activation/presentation/screens/activation_success_screen.dart';

class AppRouter {
  static const String login = '/login';
  static const String register = '/register';
  static const String token = '/token';
  static const String deviceRegistration = '/device-registration';
  static const String profile = '/profile';
  static const String changePassword = '/change-password';
  static const String activation = '/activation';
  static const String activationSuccess = '/activation-success';

  static final GoRouter router = GoRouter(
    initialLocation: login,  // ✅ This ensures login page is shown first
    redirect: (context, state) {
      // You can add redirect logic here if needed
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
      GoRoute(
        path: token,
        name: 'token',
        builder: (context, state) => const TokenScreen(),
      ),
      GoRoute(
        path: deviceRegistration,
        name: 'device-registration',
        builder: (context, state) => const DeviceRegistrationScreen(),
      ),
      GoRoute(
        path: profile,
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: changePassword,
        name: 'change-password',
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: activation,
        name: 'activation',
        builder: (context, state) => const ActivationScreen(),
      ),
      GoRoute(
        path: activationSuccess,
        name: 'activation-success',
        builder: (context, state) => const ActivationSuccessScreen(),
      ),
    ],
  );
}
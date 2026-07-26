// lib/app/routes/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:payroll_soft_token_app/features/auth/presentation/screens/login_screen.dart';
import 'package:payroll_soft_token_app/features/auth/presentation/screens/register_screen.dart';
import 'package:payroll_soft_token_app/features/home/presentation/screens/home_screen.dart';
import 'package:payroll_soft_token_app/features/device/presentation/screens/device_registration_screen.dart';
import 'package:payroll_soft_token_app/features/activation/presentation/screens/activation_screen.dart';
import 'package:payroll_soft_token_app/features/activation/presentation/screens/activation_success_screen.dart';
import 'package:payroll_soft_token_app/features/token/presentation/screens/token_screen.dart';
import 'package:payroll_soft_token_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:payroll_soft_token_app/features/profile/presentation/screens/change_password_screen.dart';
import 'package:payroll_soft_token_app/features/debug/presentation/screens/debug_storage_screen.dart';
import 'package:payroll_soft_token_app/features/auth/providers/auth_provider.dart';

class AppRouter {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String deviceRegistration = '/device-registration';
  static const String activation = '/activation';
  static const String activationSuccess = '/activation-success';
  static const String token = '/token';
  static const String profile = '/profile';
  static const String changePassword = '/change-password';
  static const String debugStorage = '/debug-storage';

  static GoRouter router({required AuthProvider authProvider}) {
    return GoRouter(
      initialLocation: login,
      redirect: (context, state) {
        final isAuthenticated = authProvider.isAuthenticated;
        final isLoginRoute = state.uri.path == login;
        final isRegisterRoute = state.uri.path == register;
        final isDebugRoute = state.uri.path == debugStorage;

        // Allow access to login, register, and debug without auth
        if (isLoginRoute || isRegisterRoute || isDebugRoute) return null;

        // If not authenticated, redirect to login
        if (!isAuthenticated) return login;

        // If authenticated, allow access to all other routes
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
          path: home,
          name: 'home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: deviceRegistration,
          name: 'device-registration',
          builder: (context, state) => const DeviceRegistrationScreen(),
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
        GoRoute(
          path: token,
          name: 'token',
          builder: (context, state) => const TokenScreen(),
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
          path: debugStorage,
          name: 'debug-storage',
          builder: (context, state) => const DebugStorageScreen(),
        ),
      ],
    );
  }
}

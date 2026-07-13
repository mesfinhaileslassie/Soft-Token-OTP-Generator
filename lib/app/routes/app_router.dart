// lib/app/routes/app_router.dart
import 'package:go_router/go_router.dart';
import 'package:payroll_soft_token_app/features/auth/presentation/screens/login_screen.dart';

class AppRouter {
  static const String login = '/login';
  static const String home = '/home';
  static const String signUp = '/signup';

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
    ],
  );
}

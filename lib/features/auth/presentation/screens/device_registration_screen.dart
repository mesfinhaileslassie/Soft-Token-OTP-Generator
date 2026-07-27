// lib/features/auth/presentation/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:payroll_soft_token_app/core/theme/app_theme.dart';
import 'package:payroll_soft_token_app/core/services/storage_service.dart';
import 'package:payroll_soft_token_app/core/services/api_service.dart';
import 'package:payroll_soft_token_app/features/auth/providers/auth_provider.dart';
import 'package:payroll_soft_token_app/features/auth/presentation/widgets/login_form.dart';
import 'package:payroll_soft_token_app/features/auth/presentation/widgets/login_header.dart';
import 'package:payroll_soft_token_app/features/auth/presentation/widgets/login_footer.dart';
import 'package:go_router/go_router.dart';
import 'package:payroll_soft_token_app/app/routes/app_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isDeviceRegistered = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkDeviceRegistration();
  }

  Future<void> _checkDeviceRegistration() async {
    setState(() => _isLoading = true);
    try {
      final storage = await StorageService.getInstance();

      // 1️⃣ Check offline flag first
      final isRegisteredOffline = await storage.isDeviceRegisteredOffline();
      if (isRegisteredOffline) {
        _isDeviceRegistered = true;
        print('✅ Device registered (offline flag)');
        setState(() => _isLoading = false);
        return;
      }

      // 2️⃣ If not flagged, check API (online)
      String? installationId = await storage.getInstallationIdGlobal();
      if (installationId == null) {
        final tempKeys = await storage.getTemporaryKeysGlobal();
        if (tempKeys != null && tempKeys['installationId'] != null) {
          installationId = tempKeys['installationId'];
          await storage.saveInstallationIdGlobal(installationId!);
        }
      }
      if (installationId == null) {
        _isDeviceRegistered = false;
      } else {
        final apiService = ApiService();
        final result = await apiService.checkDeviceRegistration(installationId);
        if (result['success'] && result['data']['registered'] == true) {
          _isDeviceRegistered = true;
          // Also set the offline flag for future
          await storage.setDeviceRegisteredOffline(true);
        } else {
          _isDeviceRegistered = false;
        }
      }
    } catch (e) {
      print('⚠️ Error checking registration: $e');
      // Fallback to offline flag if available
      final storage = await StorageService.getInstance();
      _isDeviceRegistered = await storage.isDeviceRegisteredOffline();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.setNavigationContext(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                height: 130,
                width: double.infinity,
                color: AppTheme.primaryColor,
              ),
              const Expanded(child: ColoredBox(color: Colors.white)),
            ],
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        const LoginHeader(),
                        const SizedBox(height: 32),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            children: [
                              const LoginForm(),
                              const SizedBox(height: 16),
                              if (!_isLoading && !_isDeviceRegistered)
                                OutlinedButton(
                                  onPressed: () {
                                    context.push(AppRouter.deviceRegistration);
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppTheme.primaryColor,
                                    side: const BorderSide(
                                      color: AppTheme.primaryColor,
                                    ),
                                    minimumSize: const Size(
                                      double.infinity,
                                      48,
                                    ),
                                  ),
                                  child: const Text('Register Device'),
                                ),
                              if (_isLoading)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 28),
                              const LoginFooter(),
                              const SizedBox(height: 16),
                              GestureDetector(
                                onTap: () {
                                  context.push('/debug-storage');
                                },
                                child: Text(
                                  '🔧 Debug Storage',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

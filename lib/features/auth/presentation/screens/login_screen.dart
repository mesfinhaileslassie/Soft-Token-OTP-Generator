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
      String? installationId;

      // 1️⃣ Try permanent global storage
      installationId = await storage.getInstallationIdGlobal();
      if (installationId != null) {
        print('📱 Permanent installation ID found: $installationId');
      }

      // 2️⃣ If not found, try temporary global keys (may have been set during generation)
      if (installationId == null) {
        final tempKeys = await storage.getTemporaryKeysGlobal();
        if (tempKeys != null && tempKeys['installationId'] != null) {
          installationId = tempKeys['installationId'];
          print('📱 Temporary installation ID found: $installationId');
          // Save it permanently
          await storage.saveInstallationIdGlobal(installationId!);
        }
      }

      // 3️⃣ If still null, try to get from user-specific storage (if a session exists)
      if (installationId == null) {
        final session = await storage.getSession();
        if (session != null && session['username'] != null) {
          final username = session['username'];
          final userInstallationId = await storage.getInstallationId(username);
          if (userInstallationId != null) {
            installationId = userInstallationId;
            print('📱 User-specific installation ID found: $installationId');
            await storage.saveInstallationIdGlobal(installationId!);
          }
        }
      }

      if (installationId == null) {
        print('❌ No installation ID found');
        _isDeviceRegistered = false;
      } else {
        print('📱 Final installation ID: $installationId');
        final apiService = ApiService();
        final result = await apiService.checkDeviceRegistration(installationId);
        if (result['success'] && result['data']['registered'] == true) {
          _isDeviceRegistered = true;
          print('✅ Device is registered');
        } else {
          _isDeviceRegistered = false;
          print('❌ Device is NOT registered (backend check)');
        }
      }
    } catch (e) {
      print('⚠️ Error checking registration: $e');
      _isDeviceRegistered = false;
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

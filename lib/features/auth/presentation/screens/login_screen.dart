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

  // ---- UNCHANGED LOGIC ----
  Future<void> _checkDeviceRegistration() async {
    setState(() => _isLoading = true);
    try {
      final storage = await StorageService.getInstance();

      final isRegisteredOffline = await storage.isDeviceRegisteredOffline();
      if (isRegisteredOffline) {
        _isDeviceRegistered = true;
        setState(() => _isLoading = false);
        return;
      }

      String? installationId = await storage.getInstallationIdGlobal();
      if (installationId == null) {
        final tempKeys = await storage.getTemporaryKeysGlobal();
        if (tempKeys != null && tempKeys['installationId'] != null) {
          installationId = tempKeys['installationId'];
          await storage.saveInstallationIdGlobal(installationId!);
        }
      }
      if (installationId == null) {
        final session = await storage.getSession();
        if (session != null && session['username'] != null) {
          final username = session['username'];
          final userInstallationId = await storage.getInstallationId(username);
          if (userInstallationId != null) {
            installationId = userInstallationId;
            await storage.saveInstallationIdGlobal(installationId!);
          }
        }
      }

      if (installationId == null) {
        _isDeviceRegistered = false;
      } else {
        final apiService = ApiService();
        final result = await apiService.checkDeviceRegistration(installationId);
        if (result['success'] && result['data']['registered'] == true) {
          await storage.setDeviceRegisteredOffline(true);
          _isDeviceRegistered = true;
        } else {
          _isDeviceRegistered = false;
        }
      }
    } catch (e) {
      final storage = await StorageService.getInstance();
      final isRegisteredOffline = await storage.isDeviceRegisteredOffline();
      _isDeviceRegistered = isRegisteredOffline;
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  // ---- END UNCHANGED LOGIC ----

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.setNavigationContext(context);

    // Responsive banner height: scales gently with screen width so it
    // doesn't look oversized on small phones or squashed on tablets.
    final screenWidth = MediaQuery.of(context).size.width;
    final bannerHeight = (screenWidth * 0.34).clamp(110.0, 170.0);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Plain red banner behind the status bar — matches Figma
          // (no overlaid copy; the shield/title live in LoginHeader below).
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: bannerHeight,
              decoration: const BoxDecoration(color: AppTheme.primaryColor),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  SizedBox(height: bannerHeight - 60),
                  const LoginHeader(),
                  const SizedBox(height: 20),
                  const LoginForm(),
                  const SizedBox(height: 14),
                  if (!_isLoading && !_isDeviceRegistered)
                    _RegisterDeviceButton(
                      onPressed: () =>
                          context.push(AppRouter.deviceRegistration),
                    ),
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  const SizedBox(height: 20),
                  const LoginFooter(),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Extracted purely for readability — same OutlinedButton, same
/// onPressed/navigation behavior, just pill-shaped to match the new
/// button language used across the app.
class _RegisterDeviceButton extends StatelessWidget {
  const _RegisterDeviceButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppTheme.primaryColor,
        side: const BorderSide(color: AppTheme.primaryColor, width: 1.4),
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
      child: const Text('Register Device'),
    );
  }
}

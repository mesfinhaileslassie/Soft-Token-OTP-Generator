import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:payroll_soft_token_app/core/theme/app_theme.dart';
import 'package:payroll_soft_token_app/core/utils/validators.dart';
import 'package:payroll_soft_token_app/core/services/storage_service.dart';
import 'package:payroll_soft_token_app/core/services/api_service.dart';
import 'package:payroll_soft_token_app/features/auth/providers/auth_provider.dart';
import 'package:payroll_soft_token_app/features/auth/presentation/widgets/remember_me_checkbox.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ---- UNCHANGED LOGIC ----
  Future<void> _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      FocusScope.of(context).unfocus();
      setState(() => _isLoading = true);

      final username = _usernameController.text.trim();
      final password = _passwordController.text;
      final authProvider = context.read<AuthProvider>();

      // 1️⃣ Try offline login first
      final offlineSuccess = await authProvider.offlineLogin(
        username,
        password,
      );
      if (offlineSuccess) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      // 2️⃣ Check connectivity
      bool hasInternet = false;
      try {
        await Future.delayed(const Duration(seconds: 1), () => true);
        hasInternet = true;
      } catch (_) {}

      if (!hasInternet) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No internet connection and no stored credentials.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // 3️⃣ Online login
      try {
        final apiService = ApiService();
        final result = await apiService.loginUser(
          username: username,
          password: password,
        );

        if (result['success']) {
          final data = result['data'];
          final profile = {
            'userId': data['userId'],
            'username': data['username'],
            'role': data['role'],
            'firstName': data['firstName'] ?? '',
            'lastName': data['lastName'] ?? '',
            'email': data['email'] ?? '',
          };
          await authProvider.login(
            username: username,
            password: password,
            rememberMe: true,
            userData: profile,
          );
          if (data['userId'] != null) {
            final profileResult = await apiService.getUserProfile(
              data['userId'],
            );
            if (profileResult['success']) {
              final storage = await StorageService.getInstance();
              await storage.saveUserProfile(profileResult['data']);
            }
          }
          final storage = await StorageService.getInstance();
          final isActiveGlobal = await storage.isDeviceActiveGlobal();
          if (isActiveGlobal) {
            final globalCreds = await storage.getDeviceCredentialsGlobal();
            if (globalCreds != null) {
              await storage.saveDeviceCredentials(
                username,
                globalCreds['deviceToken']!,
                globalCreds['secretKey']!,
              );
              await storage.markDeviceActive(username);
            }
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Login failed'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() => _isLoading = false);
        }
      } catch (e) {
        print('Login error: $e');
        if (e is SocketException ||
            e.toString().contains('Failed host lookup')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'No internet connection. Please connect to the internet to login.',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() => _isLoading = false);
      }
    }
  }
  // ---- END UNCHANGED LOGIC ----

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 2),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF333333),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration({
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    final radius = BorderRadius.circular(16);
    return InputDecoration(
      hintText: hintText,
      prefixIcon: Icon(prefixIcon, color: const Color(0xFF1A1A1A), size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1.2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: const BorderSide(color: Colors.red, width: 1.6),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: TextStyle(
        color: Colors.grey.shade400,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _fieldLabel('Username'),
          TextFormField(
            controller: _usernameController,
            decoration: _fieldDecoration(
              hintText: 'enter your username',
              prefixIcon: Icons.person_outline,
            ),
            validator: Validators.validateUsername,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.text,
            autocorrect: false,
            style: const TextStyle(fontSize: 15, color: Color(0xFF1A1A1A)),
          ),
          const SizedBox(height: 16),
          _fieldLabel('Password'),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: _fieldDecoration(
              hintText: 'Enter password',
              prefixIcon: Icons.lock_outline,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.grey.shade500,
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            validator: Validators.validatePassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleLogin(),
            style: const TextStyle(fontSize: 15, color: Color(0xFF1A1A1A)),
          ),
          const SizedBox(height: 8),
          RememberMeCheckbox(
            value: _rememberMe,
            onChanged: (value) => setState(() => _rememberMe = value ?? false),
          ),
          const SizedBox(height: 20),
          _LoginButton(isLoading: _isLoading, onPressed: _handleLogin),
        ],
      ),
    );
  }
}

/// Pill-shaped primary button matching the Figma login button —
/// same onPressed/loading behavior as before, just restyled.
class _LoginButton extends StatelessWidget {
  const _LoginButton({required this.isLoading, required this.onPressed});

  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppTheme.primaryColor.withOpacity(0.6),
        minimumSize: const Size(double.infinity, 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 3,
        shadowColor: AppTheme.primaryColor.withOpacity(0.4),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
      child: isLoading
          ? const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white,
              ),
            )
          : const Text('Login'),
    );
  }
}

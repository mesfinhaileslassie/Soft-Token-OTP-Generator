import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:payroll_soft_token_app/app/routes/app_router.dart';
import 'package:payroll_soft_token_app/core/theme/app_theme.dart';
import 'package:payroll_soft_token_app/core/services/storage_service.dart';
import 'package:payroll_soft_token_app/core/services/api_service.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

enum _PasswordStrength { empty, weak, medium, strong }

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String? _error;
  String? _successMessage;

  _PasswordStrength _strength = _PasswordStrength.empty;

  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(_updateStrength);
  }

  void _updateStrength() {
    setState(() {
      _strength = _calculateStrength(_newPasswordController.text);
    });
  }

  _PasswordStrength _calculateStrength(String value) {
    if (value.isEmpty) return _PasswordStrength.empty;
    int score = 0;
    if (value.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(value)) score++;
    if (RegExp(r'[0-9]').hasMatch(value)) score++;
    if (RegExp(r'[!@#$&*~%^()_\-+=]').hasMatch(value)) score++;
    if (score <= 1) return _PasswordStrength.weak;
    if (score <= 3) return _PasswordStrength.medium;
    return _PasswordStrength.strong;
  }

  @override
  void dispose() {
    _newPasswordController.removeListener(_updateStrength);
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleChangePassword() async {
    if (_formKey.currentState?.validate() ?? false) {
      // ✅ Enforce password strength
      if (_strength == _PasswordStrength.weak ||
          _strength == _PasswordStrength.empty) {
        setState(() {
          _error =
              'Password is too weak. Please choose a stronger password (at least 8 characters, include uppercase, number, and special character).';
        });
        return;
      }

      setState(() {
        _isLoading = true;
        _error = null;
        _successMessage = null;
      });

      try {
        final storage = await StorageService.getInstance();
        final userId = await storage.getUserId();
        if (userId == null) {
          setState(() {
            _error = 'User not logged in';
            _isLoading = false;
          });
          return;
        }

        final apiService = ApiService();
        final result = await apiService.changePassword(
          userId: userId,
          currentPassword: _currentPasswordController.text,
          newPassword: _newPasswordController.text,
        );

        if (result['success']) {
          final username = await storage.getUsername();
          if (username != null) {
            final newHash = sha256
                .convert(utf8.encode(_newPasswordController.text))
                .toString();
            await storage.updateAuthPasswordHash(newHash);
            await storage.updateUserPassword(
              username,
              _newPasswordController.text,
            );
          }

          setState(() {
            _successMessage = 'Password updated successfully!';
            _isLoading = false;
            _currentPasswordController.clear();
            _newPasswordController.clear();
            _confirmPasswordController.clear();
            _strength = _PasswordStrength.empty;
          });

          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              context.go(AppRouter.profile);
            }
          });
        } else {
          setState(() {
            _error = result['message'] ?? 'Password change failed';
            _isLoading = false;
          });
        }
      } catch (e) {
        setState(() {
          _error = 'Error: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth < 360 ? 16.0 : 20.0;

    // Determine if the password is too weak to submit
    final bool isPasswordValid =
        _strength != _PasswordStrength.empty &&
        _strength != _PasswordStrength.weak;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        extendBodyBehindAppBar: true,
        body: Column(
          children: [
            _Header(
              onBack: () => context.go(AppRouter.profile),
              onLogout: () => context.go(AppRouter.profile),
            ),
            Expanded(
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: 24,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_error != null)
                          _StatusBanner(
                            message: _error!,
                            backgroundColor: Colors.red.shade50,
                            borderColor: Colors.red.shade200,
                            textColor: Colors.red.shade700,
                          ),
                        if (_successMessage != null)
                          _StatusBanner(
                            message: _successMessage!,
                            backgroundColor: Colors.green.shade50,
                            borderColor: Colors.green.shade200,
                            textColor: Colors.green.shade700,
                          ),

                        // Card containing all password fields
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildPasswordField(
                                label: 'Current Password',
                                hint: 'Enter your current password',
                                controller: _currentPasswordController,
                                obscure: _obscureCurrent,
                                onToggle: () => setState(
                                  () => _obscureCurrent = !_obscureCurrent,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your current password';
                                  }
                                  if (value.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 22),

                              _buildPasswordField(
                                label: 'New Password',
                                hint: 'Enter your new password',
                                controller: _newPasswordController,
                                obscure: _obscureNew,
                                onToggle: () =>
                                    setState(() => _obscureNew = !_obscureNew),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a new password';
                                  }
                                  if (value.length < 8) {
                                    return 'Password must be at least 8 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 8),
                              _PasswordStrengthMeter(strength: _strength),
                              if (_strength == _PasswordStrength.weak ||
                                  _strength == _PasswordStrength.empty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    'Password is too weak. Use at least 8 characters with uppercase, number, and special character.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.red.shade600,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 22),

                              _buildPasswordField(
                                label: 'Confirm Password',
                                hint: 'Re-enter your new password',
                                controller: _confirmPasswordController,
                                obscure: _obscureConfirm,
                                onToggle: () => setState(
                                  () => _obscureConfirm = !_obscureConfirm,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please confirm your password';
                                  }
                                  if (value != _newPasswordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        const _PasswordTipsBanner(),
                        const SizedBox(height: 24),

                        ElevatedButton(
                          onPressed: (_isLoading || !isPasswordValid)
                              ? null
                              : _handleChangePassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            elevation: 4,
                            shadowColor: AppTheme.primaryColor.withOpacity(0.4),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Update Password',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle,
    required FormFieldValidator<String> validator,
  }) {
    final amber = Colors.orange.shade600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.lock_outline, size: 18, color: amber),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            suffixIcon: IconButton(
              icon: Icon(
                obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: Colors.grey.shade500,
              ),
              onPressed: onToggle,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: amber.withOpacity(0.5), width: 1.2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: amber.withOpacity(0.5), width: 1.2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: amber, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}

/// Red header with badge icon, title, back and logout actions.
class _Header extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onLogout;

  const _Header({required this.onBack, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, statusBarHeight + 16, 20, 20),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_outline,
                  color: AppTheme.primaryColor,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Text(
                  'Update your password',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: onBack,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.zero,
                ),
                icon: const Icon(Icons.arrow_back, size: 18),
                label: const Text(
                  'Back',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              TextButton.icon(
                onPressed: onLogout,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.zero,
                ),
                icon: const Icon(Icons.logout, size: 18),
                label: const Text(
                  'Logout',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final String message;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;

  const _StatusBanner({
    required this.message,
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Text(message, style: TextStyle(color: textColor)),
    );
  }
}

/// Visual password strength meter
class _PasswordStrengthMeter extends StatelessWidget {
  final _PasswordStrength strength;

  const _PasswordStrengthMeter({required this.strength});

  Color _segmentColor(int index) {
    final activeSegments = switch (strength) {
      _PasswordStrength.empty => 0,
      _PasswordStrength.weak => 1,
      _PasswordStrength.medium => 3,
      _PasswordStrength.strong => 4,
    };
    if (index >= activeSegments) return Colors.grey.shade300;
    return switch (strength) {
      _PasswordStrength.weak => Colors.red.shade400,
      _PasswordStrength.medium => Colors.orange.shade400,
      _PasswordStrength.strong => Colors.green.shade500,
      _PasswordStrength.empty => Colors.grey.shade300,
    };
  }

  String get _label => switch (strength) {
    _PasswordStrength.empty => '',
    _PasswordStrength.weak => 'weak',
    _PasswordStrength.medium => 'medium',
    _PasswordStrength.strong => 'strong',
  };

  Color get _labelColor => switch (strength) {
    _PasswordStrength.weak => Colors.red.shade400,
    _PasswordStrength.medium => Colors.orange.shade600,
    _PasswordStrength.strong => Colors.green.shade600,
    _PasswordStrength.empty => Colors.grey.shade500,
  };

  @override
  Widget build(BuildContext context) {
    if (strength == _PasswordStrength.empty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(4, (i) {
            return Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(right: i == 3 ? 0 : 6),
                decoration: BoxDecoration(
                  color: _segmentColor(i),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Text(
              'Password strength: ',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
            Text(
              _label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _labelColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PasswordTipsBanner extends StatelessWidget {
  const _PasswordTipsBanner();

  @override
  Widget build(BuildContext context) {
    final amber = Colors.orange.shade600;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.orange.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.verified_outlined, color: amber, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Password tips',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Use at least 8 characters with a mix of letters, numbers and symbols',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

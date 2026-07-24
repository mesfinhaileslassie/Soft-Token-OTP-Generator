// lib/features/activation/presentation/widgets/activation_form.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:payroll_soft_token_app/app/routes/app_router.dart';
import 'package:payroll_soft_token_app/core/theme/app_theme.dart';
import 'package:payroll_soft_token_app/core/services/storage_service.dart';
import 'package:payroll_soft_token_app/core/services/api_service.dart';
import 'package:payroll_soft_token_app/core/crypto/crypto_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ActivationForm extends StatefulWidget {
  const ActivationForm({super.key});

  @override
  State<ActivationForm> createState() => _ActivationFormState();
}

class _ActivationFormState extends State<ActivationForm> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false;

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _debugPrint(String message) {
    print('╔═══════════════════════════════════════════════════════════');
    print('║ DEBUG: $message');
    print('╚═══════════════════════════════════════════════════════════');
  }

  void _debugPrintData(String label, dynamic data) {
    print('╔═══════════════════════════════════════════════════════════');
    print('║ DEBUG: $label');
    print('║ DATA: $data');
    print('╚═══════════════════════════════════════════════════════════');
  }

  void _onKeyEvent(int index, String value) {
    if (value.isEmpty && index > 0) {
      if (_controllers[index - 1].text.isEmpty) {
        _focusNodes[index - 1].requestFocus();
      }
    }
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
  }

  Future<void> _handleActivate() async {
    final code = _controllers.map((c) => c.text).join();

    _debugPrint('═══════════════════════════════════════════════════════════');
    _debugPrint('🚀 ACTIVATE DEVICE BUTTON CLICKED');
    _debugPrintData('Activation Code Entered', code);
    _debugPrintData('Code Length', code.length);
    _debugPrint('═══════════════════════════════════════════════════════════');

    if (code.length < 6) {
      _debugPrint(
        '❌ ERROR: Activation code must be 6 digits, got ${code.length} digits',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter all 6 digits of the activation code'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final storage = await StorageService.getInstance();
      final apiService = ApiService();

      // ============================================================
      // REMOVED LOGIN CHECK – Activation works without logging in
      // ============================================================

      _debugPrint('📱 Step 1: Getting Device ID from Payroll System...');
      _debugPrintData('Activation Code being sent', code);

      final deviceResult = await apiService.getDeviceIdByActivationCode(code);
      _debugPrintData('Device Result', deviceResult);

      if (!deviceResult['success']) {
        _debugPrint('❌ ERROR: Failed to get Device ID');
        _debugPrintData(
          'Error Message',
          deviceResult['message'] ?? 'Unknown error',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(deviceResult['message'] ?? 'Invalid activation code'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final deviceId = deviceResult['data']['deviceId'];
      _debugPrintData('✅ Device ID found', deviceId);

      _debugPrint('📱 Step 2: Getting challenge from Payroll System...');
      _debugPrintData('Device ID for challenge', deviceId);

      final challengeResult = await apiService.getChallenge(deviceId: deviceId);
      _debugPrintData('Challenge Result', challengeResult);

      if (!challengeResult['success']) {
        _debugPrint('❌ ERROR: Failed to get challenge');
        _debugPrintData(
          'Error Message',
          challengeResult['message'] ?? 'Unknown error',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              challengeResult['message'] ?? 'Failed to get challenge',
            ),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final challenge = challengeResult['data']['challenge'];
      _debugPrintData('✅ Challenge received', challenge);

      // Get private key from GLOBAL storage
      _debugPrint('📱 Step 3: Getting private key from global storage...');
      final tempKeys = await storage.getTemporaryKeysGlobal();
      _debugPrintData('Temporary Keys (Global)', tempKeys);

      if (tempKeys == null || tempKeys['privateKey'] == null) {
        _debugPrint('❌ ERROR: Private key not found in global storage');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Private key not found. Please regenerate device code.',
            ),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      _debugPrint('✅ Private key found');

      // Sign challenge
      _debugPrint('📱 Step 4: Signing challenge with private key...');
      final cryptoService = CryptoService();
      final signature = cryptoService.signChallenge(
        challenge,
        tempKeys['privateKey']!,
      );
      _debugPrintData('✅ Challenge signed', signature);

      // Send signature
      _debugPrint('📱 Step 5: Sending signature to Payroll System...');
      _debugPrintData('Signature', signature);
      _debugPrintData('Device ID', deviceId);

      final verifyResult = await apiService.verifySignature(
        deviceId: deviceId,
        signature: signature,
      );
      _debugPrintData('Verify Result', verifyResult);

      setState(() {
        _isLoading = false;
      });

      if (verifyResult['success']) {
        _debugPrint('✅✅✅ DEVICE ACTIVATED SUCCESSFULLY! ✅✅✅');
        final data = verifyResult['data'];
        _debugPrintData('Device Token', data['deviceToken']);
        _debugPrintData('Secret Key', data['secretKey']);

        // Store credentials globally
        await storage.saveDeviceCredentialsGlobal(
          data['deviceToken'] ?? '',
          data['secretKey'] ?? '',
        );
        await storage.markDeviceActiveGlobal();
        _debugPrint('✅ Device credentials stored globally');
        _debugPrint('✅ Device marked as ACTIVE and TRUSTED');

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('activation_code', code);
        await prefs.setInt('device_id', deviceId);

        _debugPrint(
          '🎉🎉🎉 ACTIVATION COMPLETE! NAVIGATING TO SUCCESS SCREEN 🎉🎉🎉',
        );

        if (mounted) {
          context.go(AppRouter.activationSuccess);
        }
      } else {
        _debugPrint('❌❌❌ SIGNATURE VERIFICATION FAILED ❌❌❌');
        _debugPrintData(
          'Error Message',
          verifyResult['message'] ?? 'Unknown error',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              verifyResult['message'] ?? 'Signature verification failed',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      _debugPrint('💥💥💥 EXCEPTION CAUGHT 💥💥💥');
      _debugPrintData('Error Type', e.runtimeType);
      _debugPrintData('Error Message', e.toString());
      _debugPrintData('Stack Trace', StackTrace.current);

      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _onCodeChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Device Verification',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Enter the activation code from the Payroll System',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter Activation Code',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return Container(
                    width: 44,
                    height: 54,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _controllers[index].text.isNotEmpty
                            ? AppTheme.primaryColor
                            : Colors.grey.shade300,
                        width: _controllers[index].text.isNotEmpty ? 2 : 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _controllers[index].text.isNotEmpty
                              ? AppTheme.primaryColor.withOpacity(0.15)
                              : Colors.grey.shade100,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        counterText: '',
                        contentPadding: EdgeInsets.zero,
                        fillColor: Colors.white,
                        filled: true,
                      ),
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                      onChanged: (value) {
                        setState(() {
                          if (value.isNotEmpty &&
                              !RegExp(r'^[0-9]$').hasMatch(value)) {
                            _controllers[index].clear();
                            return;
                          }
                          if (value.isEmpty && index > 0) {
                            if (_controllers[index].text.isEmpty) {
                              _focusNodes[index - 1].requestFocus();
                            }
                          }
                          _onCodeChanged(value, index);
                        });
                      },
                      onTap: () {
                        _controllers[index].selection = TextSelection(
                          baseOffset: 0,
                          extentOffset: _controllers[index].text.length,
                        );
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  '000000',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade400,
                    letterSpacing: 18,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        ElevatedButton(
          onPressed: _isLoading ? null : _handleActivate,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
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
              : const Text('Activate Device'),
        ),
      ],
    );
  }
}

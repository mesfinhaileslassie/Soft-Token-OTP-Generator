// lib/features/activation/presentation/widgets/activation_form.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:payroll_soft_token_app/app/routes/app_router.dart';
import 'package:payroll_soft_token_app/core/theme/app_theme.dart';
import 'package:payroll_soft_token_app/core/services/storage_service.dart';
import 'package:payroll_soft_token_app/core/services/api_service.dart';
import 'package:payroll_soft_token_app/core/crypto/crypto_service.dart';

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

  // ============================================================
  // DEBUG FUNCTION - Prints to terminal
  // ============================================================
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

  // ============================================================
  // FIXED: Backspace handling
  // ============================================================
  void _onKeyEvent(int index, String value) {
    // If the field is cleared (backspace was pressed) and it's not the first field
    if (value.isEmpty && index > 0) {
      // Check if the previous field is empty, then move focus to previous
      if (_controllers[index - 1].text.isEmpty) {
        _focusNodes[index - 1].requestFocus();
      }
    }

    // If a digit is entered and it's not the last field, move to next
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
      _debugPrint('📱 Step 1: Getting session...');
      final storage = await StorageService.getInstance();
      final session = await storage.getSession();

      _debugPrintData('Session Data', session);

      if (session == null || session['username'] == null) {
        _debugPrint('❌ ERROR: No session found. User not logged in.');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please login first'),
            backgroundColor: Colors.orange,
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final username = session['username'];
      _debugPrintData('Username', username);

      final apiService = ApiService();
      _debugPrint('📱 Step 2: Getting Device ID from Payroll System...');
      _debugPrintData('Activation Code being sent', code);

      // Step 14-15: Get Device ID from Payroll System using Activation Code
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

      // Save Device ID to local storage
      await storage.saveDeviceId(username, deviceId);
      _debugPrint('✅ Device ID saved to local storage');

      // Step 15: Store activation code temporarily and mark as pending
      await storage.setActivationPending(username, code);
      _debugPrint('✅ Activation pending set in storage');

      // Step 16: Get challenge from Payroll System
      _debugPrint('📱 Step 3: Getting challenge from Payroll System...');
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

      // Step 17: Get private key from storage
      _debugPrint('📱 Step 4: Getting private key from storage...');
      final tempKeys = await storage.getTemporaryKeys(username);
      _debugPrintData('Temporary Keys', tempKeys);

      if (tempKeys == null || tempKeys['privateKey'] == null) {
        _debugPrint('❌ ERROR: Private key not found in storage');
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

      // Step 17: Sign challenge using Private Key
      _debugPrint('📱 Step 5: Signing challenge with private key...');
      final cryptoService = CryptoService();
      final signature = cryptoService.signChallenge(
        challenge,
        tempKeys['privateKey']!,
      );

      _debugPrintData('✅ Challenge signed', signature);

      // Step 18-19: Send signature to Payroll System
      _debugPrint('📱 Step 6: Sending signature to Payroll System...');
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

        // Step 22: Store Device Token and Secret Key
        await storage.saveDeviceCredentials(
          username,
          data['deviceToken'] ?? '',
          data['secretKey'] ?? '',
        );
        _debugPrint('✅ Device credentials stored');

        // Step 20: Mark device as active and trusted
        await storage.markDeviceActive(username);
        _debugPrint('✅ Device marked as ACTIVE and TRUSTED');

        // Step 22: Store all keys permanently
        await storage.savePrivateKey(username, tempKeys['privateKey']!);
        await storage.savePublicKey(username, tempKeys['publicKey']!);
        await storage.saveInstallationId(username, tempKeys['installationId']!);
        _debugPrint('✅ All keys stored permanently');

        // Clear activation pending
        await storage.clearActivationPending(username);
        _debugPrint('✅ Activation pending cleared');

        _debugPrint(
          '🎉🎉🎉 ACTIVATION COMPLETE! NAVIGATING TO SUCCESS SCREEN 🎉🎉🎉',
        );

        // Navigate to Activation Success
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
    // Auto-advance to next field when digit is entered
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
                          // Only allow digits
                          if (value.isNotEmpty &&
                              !RegExp(r'^[0-9]$').hasMatch(value)) {
                            _controllers[index].clear();
                            return;
                          }

                          // Handle backspace: if value is empty (backspace pressed)
                          // and current field is empty, move to previous field
                          if (value.isEmpty && index > 0) {
                            // If current field is empty, move focus to previous
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

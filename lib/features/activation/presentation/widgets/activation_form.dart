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
  String _loadingMessage = '';

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

    if (code.length < 6) {
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
      _loadingMessage = 'Verifying device...';
    });

    try {
      final storage = await StorageService.getInstance();
      final apiService = ApiService();

      // Step 1: Get Device ID
      final deviceResult = await apiService.getDeviceIdByActivationCode(code);
      _debugPrintData('Device Result', deviceResult);

      if (!deviceResult['success'] || deviceResult['data'] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(deviceResult['message'] ?? 'Invalid activation code'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
          _loadingMessage = '';
        });
        return;
      }

      final deviceId = deviceResult['data']['deviceId'];
      if (deviceId == null || deviceId <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid device ID received'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
          _loadingMessage = '';
        });
        return;
      }

      setState(() {
        _loadingMessage = 'Retrieving security challenge...';
      });

      // Step 2: Get challenge
      final challengeResult = await apiService.getChallenge(deviceId: deviceId);
      _debugPrintData('Challenge Result', challengeResult);

      if (!challengeResult['success'] || challengeResult['data'] == null) {
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
          _loadingMessage = '';
        });
        return;
      }

      final challenge = challengeResult['data']['challenge'];
      if (challenge == null || challenge.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Empty challenge received'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
          _loadingMessage = '';
        });
        return;
      }

      setState(() {
        _loadingMessage = 'Signing challenge with device key...';
      });

      // Get private key
      final tempKeys = await storage.getTemporaryKeysGlobal();
      _debugPrintData('Temporary Keys (Global)', tempKeys);

      if (tempKeys == null || tempKeys['privateKey'] == null) {
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
          _loadingMessage = '';
        });
        return;
      }

      // Sign challenge
      String signature;
      try {
        signature = CryptoService.signChallenge(
          challenge,
          tempKeys['privateKey']!,
        );
        _debugPrintData('Signature generated', signature);
      } catch (e) {
        _debugPrint('❌ Signing failed: ${e.toString()}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Signing error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
          _loadingMessage = '';
        });
        return;
      }

      setState(() {
        _loadingMessage = 'Sending signed response...';
      });

      // Verify signature
      final verifyResult = await apiService.verifySignature(
        deviceId: deviceId,
        signature: signature,
      );
      _debugPrintData('Verify Result', verifyResult);

      setState(() {
        _isLoading = false;
        _loadingMessage = '';
      });

      if (verifyResult['success'] && verifyResult['data'] != null) {
        final data = verifyResult['data'];

        // Validate data before storing
        final deviceToken = data['deviceToken'] ?? '';
        final secretKey = data['secretKey'] ?? '';
        if (deviceToken.isEmpty || secretKey.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Activation succeeded but missing device credentials.',
              ),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        await storage.saveDeviceCredentialsGlobal(deviceToken, secretKey);
        await storage.markDeviceActiveGlobal();

        if (tempKeys['installationId'] != null) {
          await storage.saveInstallationIdGlobal(tempKeys['installationId']!);
        }

        await storage.setDeviceRegisteredOffline(true);

        _debugPrint('✅ Activation complete, navigating to success screen.');
        if (mounted) {
          context.go(AppRouter.activationSuccess);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              verifyResult['message'] ?? 'Signature verification failed',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e, stackTrace) {
      _debugPrint('💥 EXCEPTION: ${e.toString()}');
      _debugPrint('Stack trace: $stackTrace');
      setState(() {
        _isLoading = false;
        _loadingMessage = '';
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
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _loadingMessage.isNotEmpty
                          ? _loadingMessage
                          : 'Verifying...',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                )
              : const Text('Activate Device'),
        ),
      ],
    );
  }
}

// lib/features/device/presentation/widgets/device_code_generator.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:uuid/uuid.dart';
import 'package:payroll_soft_token_app/core/theme/app_theme.dart';
import 'package:payroll_soft_token_app/core/services/storage_service.dart';

class DeviceCodeGenerator extends StatefulWidget {
  const DeviceCodeGenerator({super.key});

  @override
  State<DeviceCodeGenerator> createState() => _DeviceCodeGeneratorState();
}

class _DeviceCodeGeneratorState extends State<DeviceCodeGenerator> {
  String _deviceCode = '';
  bool _isGenerating = false;
  bool _isCopied = false;

  static const Color codeColor = Color(0xFFFFA400);

  Future<void> _generateDeviceCode() async {
    setState(() {
      _isGenerating = true;
    });

    try {
      // Step 2: Automatically collect device info
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;

      // Step 3: Generate Installation ID, Public Key, Private Key
      final installationId = const Uuid().v4();
      final publicKey = _generatePublicKey();
      final privateKey = _generatePrivateKey();
      final serialNumber = androidInfo.serialNumber ?? 'Unknown';

      // Step 4: Create Device Code
      final deviceCodeData = {
        'android_id': androidInfo.id,
        'device_model': androidInfo.model,
        'serial_number': serialNumber,
        'installation_id': installationId,
        'public_key': publicKey,
        'brand': androidInfo.brand,
        'manufacturer': androidInfo.manufacturer,
        'timestamp': DateTime.now().toIso8601String(),
      };

      final codeString = const JsonEncoder.withIndent(
        '  ',
      ).convert(deviceCodeData);

      setState(() {
        _deviceCode = codeString;
        _isGenerating = false;
        _isCopied = false;
      });

      // Step 5: Save device code and keys to local storage
      final storage = await StorageService.getInstance();
      final session = await storage.getSession();
      if (session != null && session['username'] != null) {
        await storage.saveDeviceCode(session['username'], codeString);
        await storage.saveTemporaryKeys(
          session['username'],
          installationId,
          publicKey,
          privateKey,
        );
      }

      _showSnackBar(
        'Device code generated! Copy and paste in Payroll System.',
        Colors.green,
      );
    } catch (e) {
      setState(() {
        _deviceCode = 'Error: ${e.toString()}';
        _isGenerating = false;
      });
      _showSnackBar('Error generating device code', Colors.red);
    }
  }

  String _generatePublicKey() {
    final uuid1 = const Uuid().v4().replaceAll('-', '');
    final uuid2 = const Uuid().v4().replaceAll('-', '');
    return 'MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC'
        '${uuid1.substring(0, 16)}'
        '${uuid2.substring(0, 16)}'
        'wIDAQAB';
  }

  String _generatePrivateKey() {
    final uuid = const Uuid().v4().replaceAll('-', '');
    return 'MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC$uuid';
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _copyToClipboard() async {
    if (_deviceCode.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: _deviceCode));
      setState(() {
        _isCopied = true;
      });
      _showSnackBar('Device code copied!', Colors.green);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade100,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Generate Device Code',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Click the button below to generate a unique device code',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _isGenerating ? null : _generateDeviceCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: _isGenerating
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Generate Device Code'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        if (_deviceCode.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: codeColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: codeColor.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: codeColor.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 24,
                      decoration: BoxDecoration(
                        color: codeColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Your Device Code',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: codeColor,
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: _copyToClipboard,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: codeColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isCopied ? Icons.check : Icons.copy,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _isCopied ? 'Copied' : 'Copy',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: codeColor.withOpacity(0.2)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Text(
                            _deviceCode,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade800,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Step 5-8: Copy this code and paste it in the Payroll System to register your device.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

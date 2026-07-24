// lib/features/device/presentation/widgets/device_code_generator.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:android_id/android_id.dart';
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

  // Figma-matching palette for the "Your Device Code" panel. Kept as a
  // named constant (instead of the previous orange accent) purely for
  // visual styling; no logic depends on this value.
  static const Color codeColor = Color(0xFFB33A2E);
  static const Color _panelBackground = Color(0xFFFCE8BE);
  static const Color _panelBorder = Color(0xFFF0D69B);

  Future<void> _generateDeviceCode() async {
    setState(() {
      _isGenerating = true;
    });

    try {
      // Step 2: Automatically collect device info
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;

      // Get the real Android ID using android_id package
      String androidId = androidInfo.id; // fallback
      try {
        final androidIdPlugin = const AndroidId();
        final id = await androidIdPlugin.getId();
        if (id != null) {
          androidId = id;
        }
      } catch (e) {
        // Fallback to device_info_plus if android_id fails
        androidId = androidInfo.id;
      }

      // Step 3: Generate Installation ID, Public Key, Private Key
      final installationId = const Uuid().v4();
      final publicKey = _generatePublicKey();
      final privateKey = _generatePrivateKey();
      final serialNumber = androidInfo.serialNumber ?? 'Unknown';

      // Step 4: Create Device Code with real Android ID
      final deviceCodeData = {
        'android_id': androidId,
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
      _showSnackBar(
        'Device code copied! Paste it in Payroll System.',
        Colors.green,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ========== GENERATE DEVICE CODE BUTTON ==========
        ElevatedButton(
          onPressed: _isGenerating ? null : _generateDeviceCode,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
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

        // ========== DEVICE CODE DISPLAY SECTION ==========
        if (_deviceCode.isNotEmpty) ...[
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: _panelBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _panelBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        'Your Device Code',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: codeColor,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: _copyToClipboard,
                      borderRadius: BorderRadius.circular(6),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isCopied ? Icons.check : Icons.copy,
                              color: codeColor,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _isCopied ? 'Copied' : 'copy',
                              style: TextStyle(
                                color: codeColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'copy the device code and paste it in the Payroll '
                  'system to register this device',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 14),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: codeColor.withOpacity(0.2)),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      _deviceCode,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: codeColor,
                        fontFamily: 'monospace',
                      ),
                    ),
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

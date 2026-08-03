// lib/features/device/presentation/widgets/device_code_generator.dart

import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:android_id/android_id.dart';
import 'package:uuid/uuid.dart';
import 'package:payroll_soft_token_app/core/theme/app_theme.dart';
import 'package:payroll_soft_token_app/core/services/storage_service.dart';
import 'package:payroll_soft_token_app/core/crypto/crypto_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pointycastle/asymmetric/rsa.dart';

class DeviceCodeGenerator extends StatefulWidget {
  const DeviceCodeGenerator({super.key});

  @override
  State<DeviceCodeGenerator> createState() => _DeviceCodeGeneratorState();
}

class _DeviceCodeGeneratorState extends State<DeviceCodeGenerator> {
  String _deviceCode = '';
  bool _isGenerating = false;
  bool _isCopied = false;

  static const Color codeColor = Color(0xFFB33A2E);
  static const Color _panelBackground = Color(0xFFFCE8BE);
  static const Color _panelBorder = Color(0xFFF0D69B);

  Future<void> _generateDeviceCode() async {
    setState(() {
      _isGenerating = true;
    });

    try {
      final deviceInfo = DeviceInfoPlugin();

      // -------- Platform‑specific identifiers --------
      String deviceId = ''; // will be Android ID or IDFV
      String deviceModel = '';
      String brand = '';
      String manufacturer = '';

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceModel = androidInfo.model;
        brand = androidInfo.brand;
        manufacturer = androidInfo.manufacturer;

        // Get the Android ID (using android_id plugin, fallback to device_info_plus)
        try {
          final androidIdPlugin = const AndroidId();
          final id = await androidIdPlugin.getId();
          if (id != null) deviceId = id;
        } catch (e) {
          deviceId = androidInfo.id;
        }
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceModel = iosInfo.model;
        brand = 'Apple';
        manufacturer = 'Apple';

        // Use identifierForVendor – the only stable, non‑permanent ID on iOS
        deviceId = iosInfo.identifierForVendor ?? 'unknown-ios-device';
      } else {
        // Fallback for other platforms (web, macOS, etc.)
        deviceModel = 'Unknown Device';
        brand = 'Unknown';
        manufacturer = 'Unknown';
        deviceId = 'unknown-platform';
      }

      // -------- Generate RSA keys --------
      final keyPair = CryptoService.generateRSAKeyPair();
      final publicKeyPEM = CryptoService.exportPublicKeyToPEM(
        keyPair.publicKey,
      );
      final privateKeyPEM = CryptoService.exportPrivateKeyToPEM(
        keyPair.privateKey,
      );

      // -------- Create a unique installation ID --------
      final installationId = const Uuid().v4();

      // -------- Build the device code JSON --------
      // Important: the key 'android_id' is kept for backward compatibility
      // with the backend. On iOS we store the IDFV there.
      final deviceCodeData = {
        'android_id': deviceId,
        'device_model': deviceModel,
        'installation_id': installationId,
        'public_key': publicKeyPEM,
        'brand': brand,
        'manufacturer': manufacturer,
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

      // -------- Persist keys globally --------
      final storage = await StorageService.getInstance();
      await storage.saveTemporaryKeysGlobal(
        installationId,
        publicKeyPEM,
        privateKeyPEM,
      );

      // Save permanent installation ID (if not already present)
      final existingId = await storage.getInstallationIdGlobal();
      if (existingId == null) {
        await storage.saveInstallationIdGlobal(installationId);
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('device_code_global', codeString);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Device code generated! Copy and paste in Payroll System.',
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 4),
        ),
      );
    } catch (e) {
      setState(() {
        _deviceCode = 'Error: ${e.toString()}';
        _isGenerating = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating device code: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _copyToClipboard() async {
    if (_deviceCode.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: _deviceCode));
      setState(() => _isCopied = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Device code copied! Paste it in Payroll System.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
                  'copy the device code and paste it in the Payroll system to register this device',
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

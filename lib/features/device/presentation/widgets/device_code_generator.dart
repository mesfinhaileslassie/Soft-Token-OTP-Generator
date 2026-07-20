// lib/features/device/presentation/widgets/device_code_generator.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:uuid/uuid.dart';
import 'package:payroll_soft_token_app/core/theme/app_theme.dart';

class DeviceCodeGenerator extends StatefulWidget {
  const DeviceCodeGenerator({super.key});

  @override
  State<DeviceCodeGenerator> createState() => _DeviceCodeGeneratorState();
}

class _DeviceCodeGeneratorState extends State<DeviceCodeGenerator> {
  String _deviceCode = '';
  bool _isGenerating = false;
  bool _isCopied = false;

  // Store generated keys for display
  String _androidId = '';
  String _deviceModel = '';
  String _serialNumber = '';
  String _installationId = '';
  String _publicKey = '';

  Future<void> _generateDeviceCode() async {
    setState(() {
      _isGenerating = true;
    });

    try {
      // Get device info
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;

      // Generate Installation ID (UUID) - ALWAYS 36 CHARACTERS
      final installationId = const Uuid().v4();

      // Generate Public Key using UUID - SAFE, NO SUBSTRING
      final publicKey = _generatePublicKey();

      // Get device serial number
      final serialNumber = androidInfo.serialNumber ?? 'Unknown';

      // Store values for display
      _androidId = androidInfo.id;
      _deviceModel = androidInfo.model;
      _serialNumber = serialNumber;
      _installationId = installationId;
      _publicKey = publicKey;

      // Create device code in JSON format
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

      // Convert to pretty JSON string
      final codeString = const JsonEncoder.withIndent('  ').convert(deviceCodeData);

      setState(() {
        _deviceCode = codeString;
        _isGenerating = false;
        _isCopied = false;
      });
    } catch (e) {
      setState(() {
        _deviceCode = 'Error generating device code: ${e.toString()}';
        _isGenerating = false;
      });
    }
  }

  // SAFE: Uses UUID which is always 36 characters - NO SUBSTRING
  String _generatePublicKey() {
    final uuid1 = const Uuid().v4().replaceAll('-', '');
    final uuid2 = const Uuid().v4().replaceAll('-', '');
    // Both uuid1 and uuid2 are always 32 characters (after removing hyphens)
    // Total: 16 + 16 = 32 characters for the middle part
    return 'MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC'
        '${uuid1.substring(0, 16)}'
        '${uuid2.substring(0, 16)}'
        'wIDAQAB';
  }

  Future<void> _copyToClipboard() async {
    if (_deviceCode.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: _deviceCode));
      setState(() {
        _isCopied = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Device code copied to clipboard'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  String _safeTruncate(String str, int maxLength) {
    if (str.isEmpty) return 'N/A';
    if (str.length <= maxLength) return str;
    return '${str.substring(0, maxLength)}...';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title
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
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 20),

            // Generate Button
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

            const SizedBox(height: 20),

            // Device Code Display
            if (_deviceCode.isNotEmpty) ...[
              const Divider(color: Color(0xFFE0E0E0)),
              const SizedBox(height: 16),

              // Generated Code Summary
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      ' Device Code Generated Successfully',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildSummaryRow('Android ID', _androidId),
                    _buildSummaryRow('Device Model', _deviceModel),
                    _buildSummaryRow('Serial Number', _serialNumber),
                    _buildSummaryRow('Installation ID', _installationId),
                    _buildSummaryRow('Public Key', _safeTruncate(_publicKey, 30)),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Device Code Header
              const Text(
                'Your Device Code (JSON)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 8),

              // Device Code Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          _deviceCode,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1A1A1A),
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _copyToClipboard,
                      icon: Icon(
                        _isCopied ? Icons.check : Icons.copy,
                        color: _isCopied ? Colors.green : AppTheme.primaryColor,
                        size: 22,
                      ),
                      tooltip: 'Copy to clipboard',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Instruction Text
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
                        'Copy the device code and paste it in the Payroll system to register this device',
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
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A1A1A),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

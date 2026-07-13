// lib/features/device/presentation/widgets/device_code_generator.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:payroll_soft_token_app/core/theme/app_theme.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:uuid/uuid.dart';

class DeviceCodeGenerator extends StatefulWidget {
  const DeviceCodeGenerator({super.key});

  @override
  State<DeviceCodeGenerator> createState() => _DeviceCodeGeneratorState();
}

class _DeviceCodeGeneratorState extends State<DeviceCodeGenerator> {
  String _deviceCode = '';
  bool _isGenerating = false;
  bool _isCopied = false;

  Future<void> _generateDeviceCode() async {
    setState(() {
      _isGenerating = true;
    });

    try {
      // Get device info
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;

      // Generate Installation ID
      final installationId = const Uuid().v4();

      // Create device code with all information
      final codeData = {
        'android_id': androidInfo.id,
        'device_model': androidInfo.model,
        'installation_id': installationId,
        'brand': androidInfo.brand,
        'manufacturer': androidInfo.manufacturer,
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
      };

      // Convert to base64 or simple string format
      final codeString = _encodeDeviceCode(codeData);

      setState(() {
        _deviceCode = codeString;
        _isGenerating = false;
        _isCopied = false;
      });
    } catch (e) {
      setState(() {
        _deviceCode = 'Error generating device code';
        _isGenerating = false;
      });
    }
  }

  String _encodeDeviceCode(Map<String, String> data) {
    // Simple encoding - in production, use proper encryption
    final parts = <String>[];
    data.forEach((key, value) {
      parts.add('$key:$value');
    });
    return parts.join('|');
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
              'Generate a unique device code to register this device with the Payroll System',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
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

              // Device Code Header
              const Text(
                'Your Device Code',
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
                  children: [
                    Expanded(
                      child: Text(
                        _deviceCode,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1A1A1A),
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
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
}

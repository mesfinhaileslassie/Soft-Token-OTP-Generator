// lib/features/device/presentation/widgets/device_info_card.dart
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:android_id/android_id.dart';

class DeviceInfoCard extends StatefulWidget {
  const DeviceInfoCard({super.key});

  @override
  State<DeviceInfoCard> createState() => _DeviceInfoCardState();
}

class _DeviceInfoCardState extends State<DeviceInfoCard> {
  Map<String, String> _deviceInfo = {};
  bool _isLoading = true;

  // Figma-matching palette for the "Device Information" panel.
  static const Color _panelBackground = Color(0xFFFCE8BE);
  static const Color _panelBorder = Color(0xFFF0D69B);
  static const Color _textColor = Color(0xFF1A1A1A);

  @override
  void initState() {
    super.initState();
    _loadDeviceInfo();
  }

  Future<void> _loadDeviceInfo() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;

      // Get the real Android ID using android_id package
      String androidId = 'Unable to fetch';
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

      setState(() {
        _deviceInfo = {
          'Device ID': androidId,
          'Brand': androidInfo.brand,
          'Manufacturer': androidInfo.manufacturer,
          'Model': androidInfo.model,
          'Device Codename': androidInfo.device,
          'Product Name': androidInfo.product,
          'Android Version': androidInfo.version.release,
          'SDK Level': androidInfo.version.sdkInt.toString(),
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _deviceInfo = {
          'Device ID': 'Unable to fetch',
          'Brand': 'Unable to fetch',
          'Manufacturer': 'Unable to fetch',
          'Model': 'Unable to fetch',
          'Device Codename': 'Unable to fetch',
          'Product Name': 'Unable to fetch',
          'Android Version': 'Unable to fetch',
          'SDK Level': 'Unable to fetch',
        };
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Device Information',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: _textColor,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: _panelBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _panelBorder),
          ),
          child: _isLoading
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: CircularProgressIndicator(),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _deviceInfo.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '•  ',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: _textColor,
                            ),
                          ),
                          Expanded(
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: '${entry.key}: ',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: _textColor,
                                    ),
                                  ),
                                  TextSpan(
                                    text: entry.value,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: _textColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }
}

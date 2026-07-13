// lib/features/device/presentation/widgets/device_info_card.dart
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:payroll_soft_token_app/core/theme/app_theme.dart';

class DeviceInfoCard extends StatefulWidget {
  const DeviceInfoCard({super.key});

  @override
  State<DeviceInfoCard> createState() => _DeviceInfoCardState();
}

class _DeviceInfoCardState extends State<DeviceInfoCard> {
  Map<String, String> _deviceInfo = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDeviceInfo();
  }

  Future<void> _loadDeviceInfo() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;

      setState(() {
        _deviceInfo = {
          'Device ID': androidInfo.id,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with #9E0000
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: const Text(
              'Device Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          // Device Info List
          Padding(
            padding: const EdgeInsets.all(16),
            child: _isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Column(
                    children: _deviceInfo.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 120,
                              child: Text(
                                '${entry.key}:',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                entry.value,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF1A1A1A),
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
      ),
    );
  }
}

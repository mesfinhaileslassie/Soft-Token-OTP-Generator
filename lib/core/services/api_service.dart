// lib/core/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:payroll_soft_token_app/core/services/storage_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();

  // ════════════════════════════════════════════════
  String _baseUrl = 'https://radial-settle-docile.ngrok-free.dev/api';
  factory ApiService() {
    return _instance;
  }

  ApiService._internal();

  // Debug function
  void _debugPrint(String message) {
    print('🌐 API: $message');
  }

  void _debugPrintData(String label, dynamic data) {
    print('🌐 API: $label');
    print('🌐 API: DATA: $data');
  }

  Future<String> getBaseUrl() async {
    final storage = await StorageService.getInstance();
    _baseUrl = await storage.getApiBaseUrl();
    _debugPrintData('Using Base URL', _baseUrl);
    return _baseUrl;
  }

  // ==================== DEVICE ENDPOINTS ====================

  /// Get Device ID by Activation Code (Step 14-15)
  Future<Map<String, dynamic>> getDeviceIdByActivationCode(
    String activationCode,
  ) async {
    _debugPrint('═══════════════════════════════════════════════════════════');
    _debugPrint('📡 getDeviceIdByActivationCode CALLED');
    _debugPrintData('Activation Code', activationCode);

    try {
      final baseUrl = await getBaseUrl();
      final url = Uri.parse('$baseUrl/device/get-device-id/$activationCode');

      _debugPrintData('Request URL', url.toString());

      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      _debugPrintData('Response Status Code', response.statusCode);
      _debugPrintData('Response Body', response.body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _debugPrint('✅ API Success: Device found');
        _debugPrintData('Device Data', data);
        return {'success': true, 'data': data};
      } else if (response.statusCode == 404) {
        _debugPrint('❌ API Error: Device not found (404)');
        return {
          'success': false,
          'message': 'Device not found for this activation code',
        };
      } else {
        String errorMessage;
        try {
          final data = jsonDecode(response.body);
          errorMessage = data['message'] ?? 'Failed to get device';
        } catch (e) {
          errorMessage = 'Server error: ${response.statusCode}';
        }
        _debugPrintData('❌ API Error', errorMessage);
        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      _debugPrintData('❌ Network Exception', e.toString());
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  /// Activate device and get challenge (Step 14-16)
  Future<Map<String, dynamic>> activateDevice({
    required int deviceId,
    required String activationCode,
  }) async {
    _debugPrint('═══════════════════════════════════════════════════════════');
    _debugPrint('📡 activateDevice CALLED');
    _debugPrintData('Device ID', deviceId);
    _debugPrintData('Activation Code', activationCode);

    try {
      final baseUrl = await getBaseUrl();
      final url = Uri.parse('$baseUrl/device/activate');

      final body = {'deviceId': deviceId, 'activationCode': activationCode};

      _debugPrintData('Request URL', url.toString());
      _debugPrintData('Request Body', body);

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      _debugPrintData('Response Status Code', response.statusCode);
      _debugPrintData('Response Body', response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _debugPrint('✅ API Success: Device activated');
        return {'success': true, 'data': data};
      } else {
        String errorMessage;
        try {
          final data = jsonDecode(response.body);
          errorMessage = data['message'] ?? 'Activation failed';
        } catch (e) {
          errorMessage = 'Server error: ${response.statusCode}';
        }
        _debugPrintData('❌ API Error', errorMessage);
        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      _debugPrintData('❌ Network Exception', e.toString());
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  /// Get challenge (Step 16)
  Future<Map<String, dynamic>> getChallenge({required int deviceId}) async {
    _debugPrint('═══════════════════════════════════════════════════════════');
    _debugPrint('📡 getChallenge CALLED');
    _debugPrintData('Device ID', deviceId);

    try {
      final baseUrl = await getBaseUrl();
      final url = Uri.parse('$baseUrl/device/$deviceId/challenge');

      _debugPrintData('Request URL', url.toString());

      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      _debugPrintData('Response Status Code', response.statusCode);
      _debugPrintData('Response Body', response.body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _debugPrint('✅ API Success: Challenge received');
        _debugPrintData('Challenge', data['challenge']);
        return {'success': true, 'data': data};
      } else {
        String errorMessage;
        try {
          final data = jsonDecode(response.body);
          errorMessage = data['message'] ?? 'Failed to get challenge';
        } catch (e) {
          errorMessage = 'Server error: ${response.statusCode}';
        }
        _debugPrintData('❌ API Error', errorMessage);
        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      _debugPrintData('❌ Network Exception', e.toString());
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  /// Verify signature (Step 17-20)
  Future<Map<String, dynamic>> verifySignature({
    required int deviceId,
    required String signature,
  }) async {
    _debugPrint('═══════════════════════════════════════════════════════════');
    _debugPrint('📡 verifySignature CALLED');
    _debugPrintData('Device ID', deviceId);
    _debugPrintData('Signature', signature.substring(0, 50) + '...');

    try {
      final baseUrl = await getBaseUrl();
      final url = Uri.parse('$baseUrl/device/verify-signature');

      final body = {'deviceId': deviceId, 'signature': signature};

      _debugPrintData('Request URL', url.toString());

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      _debugPrintData('Response Status Code', response.statusCode);
      _debugPrintData('Response Body', response.body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _debugPrint('✅ API Success: Signature verified');
        _debugPrintData('Device Token', data['deviceToken']);
        _debugPrintData('Secret Key', data['secretKey']);
        return {'success': true, 'data': data};
      } else {
        String errorMessage;
        try {
          final data = jsonDecode(response.body);
          errorMessage = data['message'] ?? 'Signature verification failed';
        } catch (e) {
          errorMessage = 'Server error: ${response.statusCode}';
        }
        _debugPrintData('❌ API Error', errorMessage);
        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      _debugPrintData('❌ Network Exception', e.toString());
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }
}

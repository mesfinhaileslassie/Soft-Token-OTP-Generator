// lib/core/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:payroll_soft_token_app/core/services/storage_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();

  // ════════════════════════════════════════════════
  //  REPLACE WITH YOUR NGROK URL
  // ════════════════════════════════════════════════
  String _baseUrl = 'https://radial-settle-docile.ngrok-free.dev/api';

  factory ApiService() {
    return _instance;
  }

  ApiService._internal();

  Future<String> getBaseUrl() async {
    final storage = await StorageService.getInstance();
    _baseUrl = await storage.getApiBaseUrl();
    return _baseUrl;
  }

  // ==================== AUTH ENDPOINTS ====================

  /// Register a new user in the database
  Future<Map<String, dynamic>> registerUser({
    required String username,
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    String? phone,
    String? gender,
  }) async {
    try {
      final baseUrl = await getBaseUrl();
      final url = Uri.parse('$baseUrl/auth/register');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
          'firstName': firstName ?? '',
          'lastName': lastName ?? '',
          'phone': phone ?? '',
          'gender': gender ?? '',
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  /// Login user
  Future<Map<String, dynamic>> loginUser({
    required String username,
    required String password,
  }) async {
    try {
      final baseUrl = await getBaseUrl();
      final url = Uri.parse('$baseUrl/auth/login');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final data = jsonDecode(response.body);
        return {'success': false, 'message': data['message'] ?? 'Login failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // ==================== DEVICE ENDPOINTS ====================

  /// Register a device with the Payroll System
  Future<Map<String, dynamic>> registerDevice({
    required String deviceCode,
    required String deviceName,
  }) async {
    try {
      final baseUrl = await getBaseUrl();
      final url = Uri.parse('$baseUrl/device/register');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
        body: jsonEncode({'deviceCode': deviceCode, 'deviceName': deviceName}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  /// Get Device ID by Activation Code
  Future<Map<String, dynamic>> getDeviceIdByActivationCode(
    String activationCode,
  ) async {
    try {
      final baseUrl = await getBaseUrl();
      final url = Uri.parse('$baseUrl/device/get-device-id/$activationCode');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Device not found'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  /// Activate device and get challenge
  Future<Map<String, dynamic>> activateDevice({
    required int deviceId,
    required String activationCode,
  }) async {
    try {
      final baseUrl = await getBaseUrl();
      final url = Uri.parse('$baseUrl/device/activate');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
        body: jsonEncode({
          'deviceId': deviceId,
          'activationCode': activationCode,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Activation failed',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  /// Get challenge
  Future<Map<String, dynamic>> getChallenge({required int deviceId}) async {
    try {
      final baseUrl = await getBaseUrl();
      final url = Uri.parse('$baseUrl/device/$deviceId/challenge');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Failed to get challenge'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  /// Verify signature
  Future<Map<String, dynamic>> verifySignature({
    required int deviceId,
    required String signature,
  }) async {
    try {
      final baseUrl = await getBaseUrl();
      final url = Uri.parse('$baseUrl/device/verify-signature');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
        body: jsonEncode({'deviceId': deviceId, 'signature': signature}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Signature verification failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  /// Verify OTP
  Future<Map<String, dynamic>> verifyOTP({
    required String secretKey,
    required String token,
  }) async {
    try {
      final baseUrl = await getBaseUrl();
      final url = Uri.parse('$baseUrl/device/verify-otp');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
        body: jsonEncode({'secretKey': secretKey, 'token': token}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'OTP verification failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }
}

// lib/core/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:payroll_soft_token_app/core/services/storage_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();

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

  /// Helper to get Authorization header
  Future<Map<String, String>> _getHeaders() async {
    final storage = await StorageService.getInstance();
    final session = await storage.getSession();
    final token = session?['token'] ?? '';
    return {
      'Content-Type': 'application/json',
      'ngrok-skip-browser-warning': 'true',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  // ==================== AUTH ENDPOINTS ====================

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

  Future<Map<String, dynamic>> changePassword({
    required int userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final baseUrl = await getBaseUrl();
      final url = Uri.parse('$baseUrl/auth/change-password');

      final headers = await _getHeaders();
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({
          'userId': userId,
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Password change failed',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // ==================== USER PROFILE ====================

  Future<Map<String, dynamic>> getUserProfile(int userId) async {
    try {
      final baseUrl = await getBaseUrl();
      final url = Uri.parse('$baseUrl/users/$userId');

      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data['data']};
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to load profile',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // ==================== DEVICE ENDPOINTS ====================

  Future<Map<String, dynamic>> registerDevice({
    required String deviceCode,
    required String deviceName,
  }) async {
    try {
      final baseUrl = await getBaseUrl();
      final url = Uri.parse('$baseUrl/device/register');

      final headers = await _getHeaders();
      final response = await http.post(
        url,
        headers: headers,
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

  Future<Map<String, dynamic>> getDeviceIdByActivationCode(
    String activationCode,
  ) async {
    try {
      final baseUrl = await getBaseUrl();
      final url = Uri.parse('$baseUrl/device/get-device-id/$activationCode');

      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);

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

  Future<Map<String, dynamic>> activateDevice({
    required int deviceId,
    required String activationCode,
  }) async {
    try {
      final baseUrl = await getBaseUrl();
      final url = Uri.parse('$baseUrl/device/activate');

      final headers = await _getHeaders();
      final response = await http.post(
        url,
        headers: headers,
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

  Future<Map<String, dynamic>> getChallenge({required int deviceId}) async {
    try {
      final baseUrl = await getBaseUrl();
      final url = Uri.parse('$baseUrl/device/$deviceId/challenge');

      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);

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

  Future<Map<String, dynamic>> verifySignature({
    required int deviceId,
    required String signature,
  }) async {
    try {
      final baseUrl = await getBaseUrl();
      final url = Uri.parse('$baseUrl/device/verify-signature');

      final headers = await _getHeaders();
      final response = await http.post(
        url,
        headers: headers,
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

  Future<Map<String, dynamic>> verifyOTP({
    required String secretKey,
    required String token,
  }) async {
    try {
      final baseUrl = await getBaseUrl();
      final url = Uri.parse('$baseUrl/device/verify-otp');

      final headers = await _getHeaders();
      final response = await http.post(
        url,
        headers: headers,
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

  Future<Map<String, dynamic>> storeCounter({
    required String installationId,
    required int counter,
  }) async {
    try {
      final baseUrl = await getBaseUrl();
      final url = Uri.parse('$baseUrl/device/store-counter');

      final headers = await _getHeaders();
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({
          'installationId': installationId,
          'counter': counter,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to store counter',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> checkDeviceRegistration(
    String installationId,
  ) async {
    try {
      final baseUrl = await getBaseUrl();
      final url = Uri.parse(
        '$baseUrl/device/check-registration?installationId=$installationId',
      );

      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Failed to check registration'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }
}

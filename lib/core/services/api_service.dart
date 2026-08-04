// lib/core/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:async';
import 'package:payroll_soft_token_app/core/services/storage_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();

  // ✅ CHANGED: Default to production server
  String _baseUrl = 'http://102.208.98.85:7201/api';

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
      'ngrok-skip-browser-warning': 'true', // Keep for compatibility
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  /// Centralised error handler – converts exceptions into user‑friendly messages
  Map<String, dynamic> _handleError(dynamic e, [String? defaultMessage]) {
    String message =
        defaultMessage ?? 'Something went wrong. Please try again.';
    if (e is SocketException || e.toString().contains('Failed host lookup')) {
      message = 'Network error. Please check your internet connection.';
    } else if (e is TimeoutException) {
      message = 'Connection timeout. Please try again.';
    } else if (e is http.ClientException) {
      message = 'Network error. Please check your internet connection.';
    } else if (e.toString().contains('401') || e.toString().contains('403')) {
      message = 'Authentication failed. Please log in again.';
    }
    return {'success': false, 'message': message};
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
      final response = await http
          .post(
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
          )
          .timeout(const Duration(seconds: 15));

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
      return _handleError(e, 'Registration failed. Please try again.');
    }
  }

  Future<Map<String, dynamic>> loginUser({
    required String username,
    required String password,
  }) async {
    try {
      final baseUrl = await getBaseUrl();
      final url = Uri.parse('$baseUrl/auth/login');
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'ngrok-skip-browser-warning': 'true',
            },
            body: jsonEncode({'username': username, 'password': password}),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final data = jsonDecode(response.body);
        return {'success': false, 'message': data['message'] ?? 'Login failed'};
      }
    } catch (e) {
      return _handleError(e, 'Login failed. Please try again.');
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
      final response = await http
          .post(
            url,
            headers: headers,
            body: jsonEncode({
              'userId': userId,
              'currentPassword': currentPassword,
              'newPassword': newPassword,
            }),
          )
          .timeout(const Duration(seconds: 15));

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
      return _handleError(e, 'Password change failed. Please try again.');
    }
  }

  // ==================== USER PROFILE ====================

  Future<Map<String, dynamic>> getUserProfile(int userId) async {
    try {
      final baseUrl = await getBaseUrl();
      final url = Uri.parse('$baseUrl/users/$userId');
      final headers = await _getHeaders();
      final response = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 15));

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
      return _handleError(e, 'Failed to load profile. Please try again.');
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
      final response = await http
          .post(
            url,
            headers: headers,
            body: jsonEncode({
              'deviceCode': deviceCode,
              'deviceName': deviceName,
            }),
          )
          .timeout(const Duration(seconds: 15));

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
      return _handleError(e, 'Device registration failed. Please try again.');
    }
  }

  Future<Map<String, dynamic>> getDeviceIdByActivationCode(
    String activationCode,
  ) async {
    try {
      final baseUrl = await getBaseUrl();
      final url = Uri.parse('$baseUrl/device/get-device-id/$activationCode');
      final headers = await _getHeaders();
      final response = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        try {
          final data = jsonDecode(response.body);
          return {
            'success': false,
            'message': data['message'] ?? 'Device not found',
          };
        } catch (_) {
          return {'success': false, 'message': 'Device not found'};
        }
      }
    } catch (e) {
      return _handleError(
        e,
        'Network error. Please check your internet connection.',
      );
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
      final response = await http
          .post(
            url,
            headers: headers,
            body: jsonEncode({
              'deviceId': deviceId,
              'activationCode': activationCode,
            }),
          )
          .timeout(const Duration(seconds: 15));

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
      return _handleError(e, 'Activation failed. Please try again.');
    }
  }

  Future<Map<String, dynamic>> getChallenge({required int deviceId}) async {
    try {
      final baseUrl = await getBaseUrl();
      final url = Uri.parse('$baseUrl/device/$deviceId/challenge');
      final headers = await _getHeaders();
      final response = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Failed to get challenge'};
      }
    } catch (e) {
      return _handleError(
        e,
        'Network error. Please check your internet connection.',
      );
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
      final response = await http
          .post(
            url,
            headers: headers,
            body: jsonEncode({'deviceId': deviceId, 'signature': signature}),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Signature verification failed'};
      }
    } catch (e) {
      return _handleError(
        e,
        'Network error. Please check your internet connection.',
      );
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
      final response = await http
          .post(
            url,
            headers: headers,
            body: jsonEncode({'secretKey': secretKey, 'token': token}),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'OTP verification failed'};
      }
    } catch (e) {
      return _handleError(
        e,
        'Network error. Please check your internet connection.',
      );
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
      final response = await http
          .post(
            url,
            headers: headers,
            body: jsonEncode({
              'installationId': installationId,
              'counter': counter,
            }),
          )
          .timeout(const Duration(seconds: 15));

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
      return _handleError(
        e,
        'Network error. Please check your internet connection.',
      );
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
      final response = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Failed to check registration'};
      }
    } catch (e) {
      return _handleError(
        e,
        'Network error. Please check your internet connection.',
      );
    }
  }
}

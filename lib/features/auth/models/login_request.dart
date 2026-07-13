// lib/features/auth/models/login_request.dart
class LoginRequest {
  final String username;
  final String password;
  final bool rememberMe;
  final String? deviceId;

  LoginRequest({
    required this.username,
    required this.password,
    this.rememberMe = false,
    this.deviceId,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'rememberMe': rememberMe,
      'deviceId': deviceId,
    };
  }
}

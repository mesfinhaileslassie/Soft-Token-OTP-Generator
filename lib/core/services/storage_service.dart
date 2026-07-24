// lib/core/services/storage_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  static SharedPreferences? _preferences;

  factory StorageService() {
    return _instance;
  }

  StorageService._internal();

  static Future<StorageService> getInstance() async {
    _preferences = await SharedPreferences.getInstance();
    return _instance;
  }

  // ==================== GLOBAL DEVICE KEYS (NOT USER-SPECIFIC) ====================

  Future<void> saveTemporaryKeysGlobal(
    String installationId,
    String publicKey,
    String privateKey,
  ) async {
    await _preferences!.setString('temp_installation_id', installationId);
    await _preferences!.setString('temp_public_key', publicKey);
    await _preferences!.setString('temp_private_key', privateKey);
  }

  Future<Map<String, String>?> getTemporaryKeysGlobal() async {
    final installationId = _preferences!.getString('temp_installation_id');
    final publicKey = _preferences!.getString('temp_public_key');
    final privateKey = _preferences!.getString('temp_private_key');
    if (installationId != null && publicKey != null && privateKey != null) {
      return {
        'installationId': installationId,
        'publicKey': publicKey,
        'privateKey': privateKey,
      };
    }
    return null;
  }

  Future<void> saveDeviceCredentialsGlobal(
    String deviceToken,
    String secretKey,
  ) async {
    await _preferences!.setString('device_token_global', deviceToken);
    await _preferences!.setString('secret_key_global', secretKey);
  }

  Future<Map<String, String>?> getDeviceCredentialsGlobal() async {
    final token = _preferences!.getString('device_token_global');
    final key = _preferences!.getString('secret_key_global');
    if (token != null && key != null) {
      return {'deviceToken': token, 'secretKey': key};
    }
    return null;
  }

  Future<void> markDeviceActiveGlobal() async {
    await _preferences!.setBool('device_active_global', true);
  }

  Future<bool> isDeviceActiveGlobal() async {
    return _preferences!.getBool('device_active_global') ?? false;
  }

  // ==================== USER-SPECIFIC METHODS ====================

  // Get all users
  Future<Map<String, dynamic>> getUsers() async {
    final usersJson = _preferences!.getString('users');
    if (usersJson == null || usersJson.isEmpty) {
      return {};
    }
    try {
      return jsonDecode(usersJson) as Map<String, dynamic>;
    } catch (e) {
      return {};
    }
  }

  Future<void> saveUser(Map<String, dynamic> userData) async {
    final users = await getUsers();
    users[userData['username']] = userData;
    await _preferences!.setString('users', jsonEncode(users));
  }

  Future<Map<String, dynamic>?> getUser(String username) async {
    final users = await getUsers();
    if (users.containsKey(username)) {
      return users[username] as Map<String, dynamic>;
    }
    return null;
  }

  Future<void> updateUser(
    String username,
    Map<String, dynamic> updatedData,
  ) async {
    final users = await getUsers();
    if (users.containsKey(username)) {
      users[username] = updatedData;
      await _preferences!.setString('users', jsonEncode(users));
    }
  }

  // Session Management
  Future<void> saveSession(String username, String token) async {
    await _preferences!.setString(
      'current_session',
      jsonEncode({
        'username': username,
        'token': token,
        'loginTime': DateTime.now().toIso8601String(),
      }),
    );
  }

  Future<Map<String, dynamic>?> getSession() async {
    final sessionJson = _preferences!.getString('current_session');
    if (sessionJson == null || sessionJson.isEmpty) {
      return null;
    }
    try {
      return jsonDecode(sessionJson) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  Future<void> clearSession() async {
    await _preferences!.remove('current_session');
  }

  // Device Management (user-specific)
  Future<void> saveDeviceId(String username, int deviceId) async {
    final user = await getUser(username);
    if (user != null) {
      user['deviceId'] = deviceId;
      await updateUser(username, user);
    }
  }

  Future<int?> getDeviceId(String username) async {
    final user = await getUser(username);
    if (user != null) {
      return user['deviceId'];
    }
    return null;
  }

  Future<void> saveDeviceCode(String username, String deviceCode) async {
    await _preferences!.setString('device_code_$username', deviceCode);
  }

  // Temporary Keys (before activation) - user-specific
  Future<void> saveTemporaryKeys(
    String username,
    String installationId,
    String publicKey,
    String privateKey,
  ) async {
    final user = await getUser(username);
    if (user != null) {
      user['tempInstallationId'] = installationId;
      user['tempPublicKey'] = publicKey;
      user['tempPrivateKey'] = privateKey;
      await updateUser(username, user);
    }
  }

  Future<Map<String, String>?> getTemporaryKeys(String username) async {
    final user = await getUser(username);
    if (user != null) {
      return {
        'installationId': user['tempInstallationId'] ?? '',
        'publicKey': user['tempPublicKey'] ?? '',
        'privateKey': user['tempPrivateKey'] ?? '',
      };
    }
    return null;
  }

  // Activation Management (user-specific)
  Future<void> setActivationPending(
    String username,
    String activationCode,
  ) async {
    final user = await getUser(username);
    if (user != null) {
      user['activationPending'] = true;
      user['activationCode'] = activationCode;
      await updateUser(username, user);
    }
  }

  Future<bool> isActivationPending(String username) async {
    final user = await getUser(username);
    if (user != null) {
      return user['activationPending'] ?? false;
    }
    return false;
  }

  Future<void> clearActivationPending(String username) async {
    final user = await getUser(username);
    if (user != null) {
      user['activationPending'] = false;
      user['activationCode'] = null;
      await updateUser(username, user);
    }
  }

  // Device Credentials (after activation) - user-specific
  Future<void> saveDeviceCredentials(
    String username,
    String deviceToken,
    String secretKey,
  ) async {
    final user = await getUser(username);
    if (user != null) {
      user['deviceToken'] = deviceToken;
      user['secretKey'] = secretKey;
      await updateUser(username, user);
    }
  }

  Future<Map<String, String>?> getDeviceCredentials(String username) async {
    final user = await getUser(username);
    if (user != null) {
      return {
        'deviceToken': user['deviceToken'] ?? '',
        'secretKey': user['secretKey'] ?? '',
      };
    }
    return null;
  }

  // Device Status (user-specific)
  Future<void> markDeviceActive(String username) async {
    final user = await getUser(username);
    if (user != null) {
      user['deviceStatus'] = 'ACTIVE';
      user['deviceTrusted'] = true;
      await updateUser(username, user);
    }
  }

  Future<String> getDeviceStatus(String username) async {
    final user = await getUser(username);
    if (user != null) {
      return user['deviceStatus'] ?? 'PENDING';
    }
    return 'PENDING';
  }

  Future<bool> isDeviceTrusted(String username) async {
    final user = await getUser(username);
    if (user != null) {
      return user['deviceTrusted'] ?? false;
    }
    return false;
  }

  // Permanent Key Storage (user-specific)
  Future<void> savePrivateKey(String username, String privateKey) async {
    final user = await getUser(username);
    if (user != null) {
      user['privateKey'] = privateKey;
      await updateUser(username, user);
    }
  }

  Future<String?> getPrivateKey(String username) async {
    final user = await getUser(username);
    if (user != null) {
      return user['privateKey'];
    }
    return null;
  }

  Future<void> savePublicKey(String username, String publicKey) async {
    final user = await getUser(username);
    if (user != null) {
      user['publicKey'] = publicKey;
      await updateUser(username, user);
    }
  }

  Future<String?> getPublicKey(String username) async {
    final user = await getUser(username);
    if (user != null) {
      return user['publicKey'];
    }
    return null;
  }

  Future<void> saveInstallationId(
    String username,
    String installationId,
  ) async {
    final user = await getUser(username);
    if (user != null) {
      user['installationId'] = installationId;
      await updateUser(username, user);
    }
  }

  Future<String?> getInstallationId(String username) async {
    final user = await getUser(username);
    if (user != null) {
      return user['installationId'];
    }
    return null;
  }

  // API Configuration
  Future<String> getApiBaseUrl() async {
    return _preferences!.getString('api_base_url') ??
        'https://radial-settle-docile.ngrok-free.dev/api';
  }

  Future<void> clearAllData() async {
    await _preferences!.clear();
  }
}

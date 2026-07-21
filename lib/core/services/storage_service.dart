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

  // Save user data
  Future<void> saveUser(Map<String, dynamic> userData) async {
    final users = await getUsers();
    users[userData['username']] = userData;
    await _preferences!.setString('users', jsonEncode(users));
  }

  // Get specific user by username
  Future<Map<String, dynamic>?> getUser(String username) async {
    final users = await getUsers();
    if (users.containsKey(username)) {
      return users[username] as Map<String, dynamic>;
    }
    return null;
  }

  // Update user data
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

  // Delete user
  Future<void> deleteUser(String username) async {
    final users = await getUsers();
    users.remove(username);
    await _preferences!.setString('users', jsonEncode(users));
  }

  // Check if user exists
  Future<bool> userExists(String username) async {
    final user = await getUser(username);
    return user != null;
  }

  // Save device for a specific user
  Future<void> saveDevice(
    String username,
    Map<String, dynamic> deviceData,
  ) async {
    final user = await getUser(username);
    if (user != null) {
      final devices = user['devices'] as List? ?? [];
      devices.add(deviceData);
      user['devices'] = devices;
      await updateUser(username, user);
    }
  }

  // Get all devices for a user
  Future<List<dynamic>> getUserDevices(String username) async {
    final user = await getUser(username);
    if (user != null) {
      return user['devices'] as List? ?? [];
    }
    return [];
  }

  // Save login session
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

  // Get current session
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

  // Clear session (logout)
  Future<void> clearSession() async {
    await _preferences!.remove('current_session');
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final session = await getSession();
    if (session != null && session['username'] != null) {
      // Verify user still exists
      return await userExists(session['username']);
    }
    return false;
  }

  // Get current logged in user
  Future<Map<String, dynamic>?> getCurrentUser() async {
    final session = await getSession();
    if (session != null && session['username'] != null) {
      return await getUser(session['username']);
    }
    return null;
  }

  // Save device registration code
  Future<void> saveDeviceCode(String username, String deviceCode) async {
    await _preferences!.setString('device_code_$username', deviceCode);
  }

  // Get device registration code
  Future<String?> getDeviceCode(String username) async {
    return _preferences!.getString('device_code_$username');
  }

  // Clear all data (for testing)
  Future<void> clearAllData() async {
    await _preferences!.clear();
  }
}

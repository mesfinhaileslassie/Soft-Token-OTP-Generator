// lib/features/home/presentation/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:payroll_soft_token_app/app/routes/app_router.dart';
import 'package:payroll_soft_token_app/core/theme/app_theme.dart';
import 'package:payroll_soft_token_app/core/services/storage_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isDeviceRegistered = false;
  bool _isDeviceActivated = false;
  bool _isLoading = true;
  String _deviceStatus = '';
  String _debugInfo = '';

  @override
  void initState() {
    super.initState();
    _checkDeviceRegistration();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkDeviceRegistration();
  }

  Future<void> _checkDeviceRegistration() async {
    print('🔍 ===== CHECKING DEVICE REGISTRATION =====');
    try {
      final storage = await StorageService.getInstance();
      final session = await storage.getSession();

      print('🔍 Session: $session');

      if (session != null && session['username'] != null) {
        final username = session['username'];
        print('🔍 Username: $username');

        final user = await storage.getUser(username);
        print('🔍 Full user data: $user');

        final deviceId = await storage.getDeviceId(username);
        print('🔍 Device ID from storage: $deviceId');

        final status = await storage.getDeviceStatus(username);
        print('🔍 Device status: $status');

        final isTrusted = await storage.isDeviceTrusted(username);
        print('🔍 Is device trusted: $isTrusted');

        final credentials = await storage.getDeviceCredentials(username);
        print('🔍 Device credentials: $credentials');

        setState(() {
          _isDeviceRegistered = deviceId != null;
          _isDeviceActivated = isTrusted && status == 'ACTIVE';
          _deviceStatus = status;
          _isLoading = false;
          _debugInfo =
              '''
Username: $username
Device ID: $deviceId
Status: $status
Trusted: $isTrusted
Registered: ${deviceId != null}
Active: ${isTrusted && status == 'ACTIVE'}
''';
        });
      } else {
        print('🔍 No active session found');
        setState(() {
          _isLoading = false;
          _debugInfo = 'No active session';
        });
      }
    } catch (e) {
      print('❌ Error checking device: $e');
      setState(() {
        _isLoading = false;
        _debugInfo = 'Error: $e';
      });
    }
    print('🔍 ===== END CHECK =====');
  }

  // 🔍 Debug: Force check storage
  Future<void> _forceCheck() async {
    await _checkDeviceRegistration();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Checked storage! Check console.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // 🔍 Debug: Force link device
  Future<void> _forceLinkDevice() async {
    try {
      final storage = await StorageService.getInstance();
      final session = await storage.getSession();

      if (session != null && session['username'] != null) {
        final username = session['username'];

        await storage.saveDeviceId(username, 14);
        await storage.markDeviceActive(username);

        print('✅ Device linked for user: $username');

        await _checkDeviceRegistration();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Device linked!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('❌ Error linking device: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Soft Token',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        // ✅ FIX: Wrap in SingleChildScrollView
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            const Text(
              'Welcome!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _isLoading
                  ? 'Loading device status...'
                  : _isDeviceActivated
                  ? '✅ Device is active and ready to use'
                  : _isDeviceRegistered
                  ? '⚠️ Device registered but not activated'
                  : 'Register your device to get started',
              style: TextStyle(
                fontSize: 14,
                color: _isDeviceActivated
                    ? Colors.green.shade700
                    : _isDeviceRegistered
                    ? Colors.orange.shade700
                    : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),

            // REGISTER DEVICE BUTTON - Only show if NOT registered
            // ✅ FIX: Use the correct condition
            if (!_isLoading && !_isDeviceRegistered) ...[
              _buildMenuItem(
                context,
                icon: Icons.devices,
                title: 'Register Device',
                subtitle: 'Register your device with Payroll System',
                color: AppTheme.primaryColor,
                onTap: () {
                  context.push(AppRouter.deviceRegistration);
                },
              ),
              const SizedBox(height: 16),
            ],

            // SHOW REGISTRATION STATUS IF REGISTERED
            if (!_isLoading && _isDeviceRegistered) ...[
              _buildDeviceStatusCard(),
              const SizedBox(height: 16),
            ],

            // GENERATE TOKEN BUTTON
            _buildMenuItem(
              context,
              icon: Icons.security,
              title: 'Generate Token',
              subtitle: _isDeviceActivated
                  ? 'Generate soft token for authentication'
                  : 'Activate your device first to generate tokens',
              color: _isDeviceActivated
                  ? Colors.green.shade700
                  : Colors.grey.shade400,
              onTap: _isDeviceActivated
                  ? () {
                      context.push(AppRouter.token);
                    }
                  : null,
            ),

            const SizedBox(height: 16),

            // MY PROFILE BUTTON
            _buildMenuItem(
              context,
              icon: Icons.person_outline,
              title: 'My Profile',
              subtitle: 'View and update your profile information',
              color: Colors.blue.shade700,
              onTap: () {
                context.push(AppRouter.profile);
              },
            ),

            const SizedBox(height: 16),

            // ACTIVATE DEVICE BUTTON
            if (!_isLoading && _isDeviceRegistered && !_isDeviceActivated) ...[
              _buildMenuItem(
                context,
                icon: Icons.verified,
                title: 'Activate Device',
                subtitle: 'Enter activation code to activate your device',
                color: Colors.orange.shade700,
                onTap: () {
                  context.push(AppRouter.activation);
                },
              ),
              const SizedBox(height: 16),
            ],

            // Debug Info - Make it smaller
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🔍 Debug Info:',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _debugInfo,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Debug Buttons
            const Text(
              '🔧 Debug Tools',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _forceCheck,
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Refresh'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade100,
                      foregroundColor: Colors.blue.shade900,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      textStyle: const TextStyle(fontSize: 11),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _forceLinkDevice,
                    icon: const Icon(Icons.link, size: 16),
                    label: const Text('Link Device'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade100,
                      foregroundColor: Colors.green.shade900,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      textStyle: const TextStyle(fontSize: 11),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                '💡 Check console for detailed debug output',
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: onTap == null
                            ? Colors.grey.shade400
                            : Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: onTap == null
                            ? Colors.grey.shade300
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                onTap == null ? Icons.lock_outline : Icons.arrow_forward_ios,
                color: onTap == null
                    ? Colors.grey.shade300
                    : Colors.grey.shade400,
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceStatusCard() {
    final isActive = _isDeviceActivated;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isActive ? Colors.green.shade50 : Colors.orange.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? Colors.green.shade200 : Colors.orange.shade200,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.green.shade100
                    : Colors.orange.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isActive ? Icons.check_circle : Icons.pending,
                color: isActive ? Colors.green : Colors.orange,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isActive ? 'Device Active' : 'Device Pending',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isActive ? Colors.green : Colors.orange,
                    ),
                  ),
                  Text(
                    isActive
                        ? 'Your device is activated and ready to use'
                        : _deviceStatus == 'PENDING'
                        ? 'Click "Activate Device" to complete activation'
                        : 'Device status: $_deviceStatus',
                    style: TextStyle(
                      fontSize: 12,
                      color: isActive
                          ? Colors.green.shade700
                          : Colors.orange.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.go(AppRouter.login);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}

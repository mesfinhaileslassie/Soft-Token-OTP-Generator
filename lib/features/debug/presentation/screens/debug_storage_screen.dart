// lib/features/debug/presentation/screens/debug_storage_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DebugStorageScreen extends StatefulWidget {
  const DebugStorageScreen({super.key});

  @override
  State<DebugStorageScreen> createState() => _DebugStorageScreenState();
}

class _DebugStorageScreenState extends State<DebugStorageScreen> {
  Map<String, dynamic> _data = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStorage();
  }

  Future<void> _loadStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final Map<String, dynamic> map = {};
    for (String key in keys) {
      map[key] = prefs.get(key);
    }
    setState(() {
      _data = map;
      _loading = false;
    });
  }

  Future<void> _clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _loadStorage();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Storage cleared!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Storage Inspector'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.white),
            onPressed: _clearAll,
            tooltip: 'Clear all storage',
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadStorage),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _data.isEmpty
          ? const Center(child: Text('No data stored.'))
          : ListView.builder(
              itemCount: _data.length,
              itemBuilder: (context, index) {
                final key = _data.keys.elementAt(index);
                final value = _data[key];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  child: ListTile(
                    title: Text(
                      key,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(value.toString()),
                  ),
                );
              },
            ),
    );
  }
}

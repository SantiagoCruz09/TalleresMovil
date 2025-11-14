import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

class EvidenceScreen extends StatefulWidget {
  const EvidenceScreen({super.key});

  @override
  State<EvidenceScreen> createState() => _EvidenceScreenState();
}

class _EvidenceScreenState extends State<EvidenceScreen> {
  String? _name;
  String? _email;
  String? _id;
  // _hasToken not needed now because we display token info directly
  String? _tokenValue;
  String? _tokenType;
  String? _expiresIn;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('name');
    final email = prefs.getString('email');
    final id = prefs.getString('id');
    final token = await _secureStorage.read(key: 'access_token');
    final tokenType = await _secureStorage.read(key: 'token_type');
    final expiresIn = await _secureStorage.read(key: 'expires_in');
    setState(() {
      _name = name;
      _email = email;
      _id = id;
      _tokenValue = token;
      _tokenType = tokenType;
      _expiresIn = expiresIn;
    });
  }

  Future<void> _logout() async {
    // Capture messenger and router before async gaps
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    // Clear shared preferences keys
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('name');
    await prefs.remove('email');
    await prefs.remove('id');

    // Clear secure storage tokens and saved credentials
    await _secureStorage.delete(key: 'access_token');
    await _secureStorage.delete(key: 'refresh_token');
    await _secureStorage.delete(key: 'saved_email');
    await _secureStorage.delete(key: 'saved_password');
    await _secureStorage.delete(key: 'token_type');
    await _secureStorage.delete(key: 'expires_in');

    messenger.showSnackBar(const SnackBar(content: Text('Sesión cerrada')));
    // Navigate to home
    router.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Evidencia de sesión'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.shade50,
                  child: const Icon(Icons.person, color: Colors.blue),
                ),
                title: Text(_name ?? '—', style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('ID: ${_id ?? '—'}  •  ${_email ?? '—'}'),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              child: ListTile(
                leading: CircleAvatar(backgroundColor: Colors.green.shade50, child: const Icon(Icons.verified_user, color: Colors.green)),
                title: const Text('Token JWT', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(_tokenValue != null && _tokenValue!.isNotEmpty ? _maskToken(_tokenValue!) : '—'),
                trailing: IconButton(
                  icon: const Icon(Icons.copy_outlined),
                  onPressed: _tokenValue != null && _tokenValue!.isNotEmpty
                      ? () async {
                          await Clipboard.setData(ClipboardData(text: _tokenValue!));
                          if (!mounted) return;
                          final messenger = ScaffoldMessenger.of(context);
                          messenger.showSnackBar(const SnackBar(content: Text('Token copiado')));
                        }
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              child: ListTile(
                leading: CircleAvatar(backgroundColor: Colors.teal.shade50, child: const Icon(Icons.info_outline, color: Colors.teal)),
                title: const Text('Tipo de Token', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(_tokenType ?? '—'),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              child: ListTile(
                leading: CircleAvatar(backgroundColor: Colors.orange.shade50, child: const Icon(Icons.timer, color: Colors.orange)),
                title: const Text('Expira en', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(_expiresIn != null ? '$_expiresIn segundos' : '—'),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: const Text('Cerrar sesión'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, padding: const EdgeInsets.symmetric(vertical: 14)),
            ),
          ],
        ),
      ),
    );
  }

  String _maskToken(String token) {
    if (token.length <= 20) return token;
    return '${token.substring(0, 18)}...';
  }
}

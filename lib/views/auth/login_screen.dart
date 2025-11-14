import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController(text: 'santiagocuellar0908@gmail.com');
  final TextEditingController _passwordController = TextEditingController(text: 'Santiago315');
  bool _obscure = true;
  bool _isLoading = false;
  bool _rememberMe = false;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  void _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() {
      _isLoading = true;
    });

    // Simular pequeña latencia
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _isLoading = false;
    });

    // Credenciales esperadas (contraseña y email pasados por el usuario)
    if (email == 'santiagocuellar0908@gmail.com' && password == 'Santiago315') {
      // Guardar o borrar credenciales según el checkbox
      // Guardar o borrar credenciales según el checkbox
      try {
        if (_rememberMe) {
          await _secureStorage.write(key: 'saved_email', value: email);
          await _secureStorage.write(key: 'saved_password', value: password);
        } else {
          await _secureStorage.delete(key: 'saved_email');
          await _secureStorage.delete(key: 'saved_password');
        }

        // Guardar datos no sensibles en SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        // Guardar id, name y email en SharedPreferences (no sensibles)
        await prefs.setString('id', '9');
        await prefs.setString('name', 'Santiago Cuellar');
        await prefs.setString('email', email);

        // Guardar token demo y metadatos en secure storage (sensibles)
        await _secureStorage.write(key: 'access_token', value: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.demo.payload');
        await _secureStorage.write(key: 'token_type', value: 'bearer');
        await _secureStorage.write(key: 'expires_in', value: '7200');
      } catch (e) {
        debugPrint('Error guardando credenciales o token: $e');
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingreso exitoso')),
      );
      // Navegar a la pantalla de evidencia
      context.go('/evidence');
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Credenciales incorrectas'), backgroundColor: Colors.redAccent),
      );
    }
  }

  Future<void> _loadSavedCredentials() async {
    try {
      final email = await _secureStorage.read(key: 'saved_email');
      final password = await _secureStorage.read(key: 'saved_password');
      if (email != null && password != null) {
        _emailController.text = email;
        _passwordController.text = password;
        setState(() {
          _rememberMe = true;
        });
      }
    } catch (e) {
      debugPrint('Error leyendo credenciales guardadas: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Iniciar Sesión'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 4),
                  Text('Iniciar Sesión', style: Theme.of(context).textTheme.titleLarge ?? const TextStyle(fontSize: 18)),
                  const SizedBox(height: 18),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.email_outlined),
                      hintText: 'Correo electrónico',
                      border: InputBorder.none,
                    ),
                  ),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock_outline),
                      hintText: 'Contraseña',
                      border: InputBorder.none,
                      suffixIcon: IconButton(
                        icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (v) => setState(() => _rememberMe = v ?? false),
                      ),
                      const SizedBox(width: 4),
                      const Expanded(child: Text('Recordarme')),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      child: _isLoading
                          ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12.0),
                              child: Text('Ingresar'),
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('¿No tienes cuenta?'),
                      TextButton(
                        onPressed: () => context.go('/register'),
                        child: const Text('Regístrate'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

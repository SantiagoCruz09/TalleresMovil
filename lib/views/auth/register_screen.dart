import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _proxyController = TextEditingController();
  // Prefill localhost proxy to make it easy to test
  
  bool _obscure = true;
  bool _isLoading = false;
  bool _useProxy = false;

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Todos los campos son obligatorios')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final targetUrl = 'https://parking.visiontic.com.co/api/users';
      Uri uri;
      if (_useProxy) {
        final proxy = _proxyController.text.trim();
        if (proxy.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Debes indicar la URL del proxy cuando "Usar proxy CORS" está activo')));
          return;
        }
        // Expect proxy that forwards requests by appending the target URL, e.g. https://cors-anywhere.herokuapp.com/
        uri = Uri.parse('$proxy$targetUrl');
      } else {
        uri = Uri.parse(targetUrl);
      }
      // Add Accept header and use JSON body
  final headers = {'Content-Type': 'application/json', 'Accept': 'application/json'};

      // Perform POST
      final resp = await http
          .post(
        uri,
        headers: headers,
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      )
          .timeout(const Duration(seconds: 20));

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registro exitoso')));
        // Volver al login
        context.go('/login');
      } else {
        final msg = resp.body.isNotEmpty ? resp.body : 'Error: ${resp.statusCode}';
        if (!mounted) return;
        // If running on web and get an opaque error before (XHR), guide the user
        if (kIsWeb && (resp.statusCode == 0 || resp.body.isEmpty)) {
          _showCorsDialog();
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Registro fallido: $msg')));
      }
    } catch (e) {
      // Common cause when testing from web: CORS / network error -> XMLHttpRequest error
      if (!mounted) return;
      final message = e.toString();
      if (kIsWeb) {
        // Show a helpful dialog explaining CORS and offering options
        _showCorsDialog(extra: message);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al registrar: $message')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showCorsDialog({String? extra}) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error de registro (CORS / red)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Al parecer la petición fue bloqueada por políticas del navegador (CORS) o hubo un problema de red.'),
            const SizedBox(height: 8),
            const Text('Qué puedes intentar:'),
            const SizedBox(height: 6),
            const Text('- Ejecutar la app en un emulador/dispositivo (Android/iOS) en vez de web.'),
            const Text('- Habilitar CORS en el servidor de la API (permitir origen de tu app).'),
            const SizedBox(height: 8),
            if (extra != null) Text('Detalle: $extra', style: const TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cerrar')),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _proxyController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Prefill with a common local proxy URL to simplify testing
    _proxyController.text = 'http://localhost:8080/';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(prefixIcon: Icon(Icons.person_outline), hintText: 'Nombre'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(prefixIcon: Icon(Icons.email_outlined), hintText: 'Correo electrónico'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock_outline),
                      hintText: 'Contraseña',
                      suffixIcon: IconButton(
                        icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  // Proxy option (dev-only): useful to test from web when server blocks CORS
                  Row(
                    children: [
                      Checkbox(value: _useProxy, onChanged: (v) => setState(() => _useProxy = v ?? false)),
                      const Expanded(child: Text('Usar proxy CORS (solo para pruebas)')),
                    ],
                  ),
                  if (_useProxy) ...[
                    const SizedBox(height: 6),
                    TextField(
                      controller: _proxyController,
                      decoration: const InputDecoration(
                        hintText: 'https://cors-anywhere.herokuapp.com/',
                        labelText: 'URL del proxy',
                        helperText: 'Proxy debe terminar en / y aceptar la URL objetivo concatenada',
                      ),
                    ),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      child: _isLoading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Registrar'),
                    ),
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

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../data/api_client.dart';

const _primary = Color(0xFF2AA9DF);
const _textPrimary = Color(0xFFFFFFFF);
const _textSecondary = Color(0xFF9E9E9E);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _api = ApiClient.instance;
  final _storage = FlutterSecureStorage();
  String _error = '';
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      final result = await _api.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
      await _storage.write(key: 'jwt', value: result['token']);
      await _storage.write(key: 'uid', value: result['uid']);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/dashboard');
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _guestLogin() async {
    await _storage.write(key: 'guest', value: 'true');
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shield_outlined, size: 64, color: _primary),
                const SizedBox(height: 8),
                const Text('Responder', style: TextStyle(
                  color: _textPrimary, fontSize: 28, fontWeight: FontWeight.bold,
                )),
                const SizedBox(height: 4),
                const Text('Network Security Scanner', style: TextStyle(
                  color: _textSecondary, fontSize: 14,
                )),
                const SizedBox(height: 48),
                _buildTextField(_emailController, 'Operator@domain.com',
                    keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 16),
                _buildTextField(_passwordController, 'Password',
                    obscureText: true),
                if (_error.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(_error,
                        style: const TextStyle(color: Color(0xFFEF5350))),
                  ),
                const SizedBox(height: 24),
                _buildButton(_isLoading ? null : _login, 'Login'),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/signup'),
                  child: const Text("Don't have an account? Sign up"),
                ),
                TextButton(
                  onPressed: _guestLogin,
                  child: const Text('Continue as guest',
                      style: TextStyle(color: Colors.grey)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String hint,
      {bool obscureText = false, TextInputType? keyboardType}) {
    return TextField(
      controller: ctrl,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: _textPrimary),
      decoration: InputDecoration(hintText: hint),
    );
  }

  Widget _buildButton(VoidCallback? onPressed, String label) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}

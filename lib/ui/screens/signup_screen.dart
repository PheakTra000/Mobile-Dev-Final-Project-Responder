import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../data/api_client.dart';

const _primary = Color(0xFF2AA9DF);
const _textPrimary = Color(0xFFFFFFFF);

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // Add a controller for the name field
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  final _api = ApiClient.instance;
  final _storage = const FlutterSecureStorage();
  String _error = '';
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    // Validation
    if (name.isEmpty || email.isEmpty || password.isEmpty || confirm.isEmpty) {
      setState(() => _error = 'All fields are required');
      return;
    }
    if (password.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters');
      return;
    }
    if (password != confirm) {
      setState(() => _error = 'Passwords do not match');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      // Pass the name to the registration API
      final token = await _api.register(name, email, password);
      await _storage.write(key: 'jwt', value: token);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/dashboard');
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shield_outlined, size: 64, color: _primary),
                const SizedBox(height: 8),
                const Text('Create Account', style: TextStyle(
                  color: _textPrimary, fontSize: 24, fontWeight: FontWeight.bold,
                )),
                const SizedBox(height: 32),

                // --- Name field (new) ---
                _buildTextField(_nameController, 'Full name'),
                const SizedBox(height: 16),

                _buildTextField(_emailController, 'Operator@domain.com',
                    keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 16),
                _buildTextField(_passwordController, 'Password',
                    obscureText: true),
                const SizedBox(height: 16),
                _buildTextField(_confirmController, 'Confirm password',
                    obscureText: true),

                if (_error.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(_error,
                        style: const TextStyle(color: Color(0xFFEF5350))),
                  ),
                const SizedBox(height: 24),
                _buildButton(_isLoading ? null : _register, 'Create Account'),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Already have an account? Log in'),
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
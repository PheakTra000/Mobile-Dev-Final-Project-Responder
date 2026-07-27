import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'ui/screens/login_screen.dart';
import 'ui/screens/signup_screen.dart';
import 'ui/screens/dashboard_screen.dart';
import 'ui/screens/form_screen.dart';
import 'models/audit_session.dart';
import 'ui/screens/scanning_screen.dart';
import 'ui/theme/app_theme.dart';

void main() {
  runApp(const ResponderApp());
}

class ResponderApp extends StatelessWidget {
  const ResponderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Responder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppTheme.background,
        cardColor: AppTheme.card,
        colorScheme: ColorScheme.dark(primary: AppTheme.primary),
        appBarTheme: AppBarTheme(
          backgroundColor: AppTheme.surface,
          foregroundColor: AppTheme.textPrimary,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            foregroundColor: AppTheme.textPrimary,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppTheme.surface,
          hintStyle: TextStyle(color: AppTheme.textSecondary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: const _AuthGate(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          case '/signup':
            return MaterialPageRoute(builder: (_) => const SignupScreen());
          case '/dashboard':
            return MaterialPageRoute(builder: (_) => const DashboardScreen());
          case '/form':
            return MaterialPageRoute(builder: (_) => const FormScreen());
          case '/scanning':
            final args = settings.arguments as Map<String, dynamic>?;
            final scanTypeStr = args?['scanType'] as String? ?? 'quick';
            return MaterialPageRoute(
              builder: (_) => ScanningScreen(
                profileName: args?['profileName'] as String? ?? 'Scan',
                scanType: scanTypeStr == 'deep' ? ScanType.deep : ScanType.quick,
                sessionId: args?['sessionId'] as String?,
              ),
            );
          default:
            return MaterialPageRoute(builder: (_) => const LoginScreen());
        }
      },
    );
  }
}

class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  String? _token;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final jwt = await const FlutterSecureStorage().read(key: 'jwt');
    if (!mounted) return;
    setState(() => _token = jwt);
  }

  @override
  Widget build(BuildContext context) {
    if (_token == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return _token!.isNotEmpty ? const DashboardScreen() : const LoginScreen();
  }
}

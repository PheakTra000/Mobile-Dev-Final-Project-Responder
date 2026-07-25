import 'user.dart';

class AuthSession {
  final String token;
  final User user;

  AuthSession({required this.token, required this.user});
}

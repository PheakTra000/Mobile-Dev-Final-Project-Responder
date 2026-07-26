import 'dart:async';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/audit_session.dart';
import 'dto/audit_session_dto.dart';

class ApiClient {
  final String baseUrl;

  ApiClient({required this.baseUrl});

  Future<String> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) {
        throw Exception(jsonDecode(response.body)['error']);
      }
      final data = jsonDecode(response.body);
      return data['token'] as String;
    } on TimeoutException {
      throw Exception('Server is not responding. Please try again.');
    }
  }

  Future<String> register(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 10));
      if (response.statusCode != 201) {
        throw Exception(jsonDecode(response.body)['error']);
      }
      final data = jsonDecode(response.body);
      return data['token'] as String;
    } on TimeoutException {
      throw Exception('Server is not responding. Please try again.');
    }
  }

  Future<Map<String, String>> _authHeaders() async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'jwt');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<void> backupSession(AuditSession session) async {
    final headers = await _authHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/scans'),
      headers: headers,
      body: jsonEncode(AuditSessionDto.toJson(session)),
    ).timeout(const Duration(seconds: 10));
    if (response.statusCode != 201) {
      throw Exception(jsonDecode(response.body)['error']);
    }
  }

  Future<List<AuditSession>> fetchSessions() async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/scans'),
      headers: headers,
    ).timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['error']);
    }
    final List data = jsonDecode(response.body) as List;
    return data.map((e) => AuditSessionDto.fromJson(e as Map<String, dynamic>)).toList();
  }

  static final instance = ApiClient(
    baseUrl: 'https://backend.sybau-ctf.space',
  );
}

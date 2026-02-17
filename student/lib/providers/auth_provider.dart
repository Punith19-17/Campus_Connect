import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:student/config.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = '';
  Map<String, dynamic>? _user;
  String? _token;

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  Map<String, dynamic>? get user => _user;
  String? get token => _token;

  // ---------------- LOGIN ----------------
  Future<Map<String, dynamic>> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse(AppConfig.login),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _user = data['user'];
        _token = data['token'];

        return {
          "user": _user,
          "token": _token,
        };
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Login failed');
      }
    } catch (error) {
      _errorMessage = error.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---------------- REGISTER ----------------
  Future<Map<String, dynamic>> register({
    required String registerNumber,
    required String name,
    required String email,
    required String phoneNumber,
    required String department,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse(AppConfig.register),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "registerNumber": registerNumber,
          "name": name,
          "email": email,
          "phoneNumber": phoneNumber,
          "department": department,
          "password": password,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _user = data['user'];
        _token = data['token'];

        return {
          "user": _user,
          "token": _token,
        };
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Registration failed');
      }
    } catch (error) {
      _errorMessage = error.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---------------- LOGOUT ----------------
  Future<void> logout() async {
    _user = null;
    _token = null;
    _errorMessage = '';
    notifyListeners();
  }

  // ---------------- CHECK AUTH STATUS ----------------
  Future<void> checkAuthStatus() async {
    if (_token != null && _user != null) {
      // Already logged in
      return;
    } else {
      // Not logged in
      _user = null;
      _token = null;
    }
    notifyListeners();
  }

  // ---------------- CLEAR ERRORS ----------------
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}

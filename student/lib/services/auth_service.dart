import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Use localhost for 'development'
  static const String baseUrl = 'https://campus-connect-p1ow.onrender.com/api/auth';

  // Register user - FIXED THE URL TYPO
  static Future<Map<String, dynamic>> register({
    required String registerNumber,
    required String name,
    required String email,
    required String phoneNumber,
    required String department,
    required String password,
  }) async {
    try {
      print('🚀 Attempting to register user: $email');
      print('📡 API URL: $baseUrl/register'); // Fixed: /register not /negister

      final response = await http.post(
        Uri.parse('$baseUrl/register'), // Fixed: /register not /negister
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'register_number': registerNumber,
          'name': name,
          'email': email,
          'phone_number': phoneNumber,
          'department': department,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      print('✅ Response status: ${response.statusCode}');
      print('📨 Response body: ${response.body}');

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);

        // Save token and user data to shared preferences
        if (responseData['token'] != null) {
          await _saveUserData(responseData);
        }

        return responseData;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Registration failed with status ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('🌐 Network error: Cannot connect to server. Please check:\n1. Backend is running on port 5000\n2. Correct IP address: 10.72.1.173\n3. Phone and computer are on same WiFi');
    } on HttpException {
      throw Exception('🌐 HTTP error: Could not reach the server.');
    } on FormatException {
      throw Exception('🌐 Format error: Invalid response from server.');
    } on TimeoutException {
      throw Exception('⏰ Timeout error: Server is not responding. Check if backend is running.');
    } catch (error) {
      print('❌ Error during registration: $error');
      throw Exception('🌐 Network error: ${error.toString()}');
    }
  }

  // Login user
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      print('🚀 Attempting to login: $email');
      print('📡 API URL: $baseUrl/login');

      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      print('✅ Response status: ${response.statusCode}');
      print('📨 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Save token and user data to shared preferences
        if (responseData['token'] != null) {
          await _saveUserData(responseData);
        }

        return responseData;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Login failed with status ${response.statusCode}');
      }
    } catch (error) {
      print('❌ Error during login: $error');

      // Generic error messages based on error type
      if (error.toString().contains('SocketException') ||
          error.toString().contains('Network is unreachable')) {
        throw Exception('🌐 Network error: Cannot connect to server. Please check if backend is running.');
      } else if (error.toString().contains('Timeout')) {
        throw Exception('⏰ Timeout error: Server is not responding.');
      } else {
        throw Exception('🌐 Network error: ${error.toString()}');
      }
    }
  }

  // Logout user
  static Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_data');
      print('✅ User logged out successfully');
    } catch (error) {
      print('❌ Error during logout: $error');
      throw Exception('Logout error: $error');
    }
  }

  // Get stored auth token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Get stored user data
  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('user_data');
    if (userDataString != null) {
      return json.decode(userDataString);
    }
    return null;
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  // Helper method to save user data to shared preferences
  static Future<void> _saveUserData(Map<String, dynamic> responseData) async {
    final prefs = await SharedPreferences.getInstance();

    // Save token
    if (responseData['token'] != null) {
      await prefs.setString('auth_token', responseData['token']);
      print('💾 Auth token saved: ${responseData['token'].substring(0, 20)}...');
    } else {
      print('❌ No token in response data');
    }

    // Save user data
    if (responseData['user'] != null) {
      await prefs.setString('user_data', json.encode(responseData['user']));
      print('💾 User data saved');
    } else {
      print('❌ No user data in response');
    }
  }
}
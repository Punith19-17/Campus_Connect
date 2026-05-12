import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '/../config.dart'; // Import the config file
import 'admin_login.dart';

class AdminSignup extends StatefulWidget {
  const AdminSignup({super.key});

  @override
  State<AdminSignup> createState() => _AdminSignUpPageState();
}

class _AdminSignUpPageState extends State<AdminSignup> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _deptController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String _statusMessage = '';
  Color _statusColor = Colors.transparent;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _deptController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Test server connection
  Future<void> _testServerConnection() async {
    try {
      final response = await http.get(
        Uri.parse(AppConfig.testConnection),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        _showModernSnackBar('Server connection successful!', Colors.green);
      } else {
        _showModernSnackBar('Server test failed with status: ${response.statusCode}', Colors.redAccent);
      }
    } catch (e) {
      _showModernSnackBar('Server test failed: $e', Colors.redAccent);
    }
  }

  void _showModernSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(color == Colors.green ? Icons.check_circle_rounded : Icons.error_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _submitSignUpForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _statusMessage = '';
        _statusColor = Colors.transparent;
      });

      final name = _nameController.text;
      final email = _emailController.text;
      final department = _deptController.text;
      final password = _passwordController.text;

      try {
        print('Connecting to: ${AppConfig.adminSignup}');

        // API call for admin signup using config
        final response = await http.post(
          Uri.parse(AppConfig.adminSignup),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'name': name,
            'email': email,
            'department': department,
            'password': password,
          }),
        ).timeout(const Duration(seconds: 10));

        final responseData = json.decode(response.body);
        print('Server response: $responseData');

        if (response.statusCode == 201) {
          setState(() {
            _statusMessage = responseData['message'] ?? 'Admin registration successful!';
            _statusColor = const Color(0xFF10B981); // Emerald
          });

          await Future.delayed(const Duration(milliseconds: 1500));

          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AdminLogin()),
            );
          }
        } else {
          setState(() {
            _statusMessage = responseData['message'] ?? 'Registration failed. Please try again.';
            _statusColor = const Color(0xFFEF4444); // Red
          });
          _showModernSnackBar(_statusMessage, Colors.redAccent);
        }
      } catch (error) {
        String errorMessage = 'Failed to register: ';

        if (error.toString().contains('Failed host lookup')) {
          errorMessage += 'Cannot connect to server. Please check your connection and server URL.';
        } else if (error.toString().contains('Connection refused')) {
          errorMessage += 'Server not running or not accessible. Please start your backend server.';
        } else {
          errorMessage += error.toString();
        }

        setState(() {
          _statusMessage = errorMessage;
          _statusColor = const Color(0xFFEF4444);
        });

        _showModernSnackBar(errorMessage, Colors.redAccent);
        print('Error details: $error');
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
          prefixIcon: Icon(icon, color: const Color(0xFF94A3B8)),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFF43F5E), width: 2), // Rose for Admin Signup
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
        obscureText: isPassword,
        keyboardType: keyboardType,
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.wifi_rounded, color: Color(0xFF1E293B)),
            onPressed: _testServerConnection,
            tooltip: 'Test Server Connection',
          ),
        ],
      ),
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8FAFC), Color(0xFFEFF6FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Icon Header
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFF43F5E).withOpacity(0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person_add_alt_1_rounded,
                        size: 48,
                        color: Color(0xFFF43F5E), // Rose color for Admin Signup
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  const Text(
                    'Create Account',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Fill out the form to manage events',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 32),

                  if (_statusMessage.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: _statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _statusColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _statusColor == const Color(0xFF10B981)
                                ? Icons.check_circle_rounded
                                : Icons.error_rounded,
                            color: _statusColor,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _statusMessage,
                              style: TextStyle(
                                color: _statusColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Registration Form Card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF43F5E).withOpacity(0.05),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        _buildTextField(
                          controller: _nameController,
                          label: 'Full Name',
                          icon: Icons.person_rounded,
                          validator: (v) => v!.isEmpty ? 'Enter full name' : null,
                        ),
                        _buildTextField(
                          controller: _emailController,
                          label: 'Email Address',
                          icon: Icons.email_rounded,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v!.isEmpty) return 'Enter email';
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) return 'Invalid email';
                            return null;
                          },
                        ),
                        _buildTextField(
                          controller: _deptController,
                          label: 'Department',
                          icon: Icons.business_center_rounded,
                          validator: (v) => v!.isEmpty ? 'Enter department' : null,
                        ),
                        _buildTextField(
                          controller: _passwordController,
                          label: 'Password',
                          icon: Icons.lock_rounded,
                          isPassword: true,
                          validator: (v) {
                            if (v!.isEmpty) return 'Enter password';
                            if (v.length < 6) return 'Min 6 characters';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        _isLoading
                            ? const Center(child: CircularProgressIndicator(color: Color(0xFFF43F5E)))
                            : Container(
                                width: double.infinity,
                                height: 56,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFFB7185), Color(0xFFF43F5E)], // Rose gradient
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFF43F5E).withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: _submitSignUpForm,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  ),
                                  child: const Text(
                                    'Sign Up',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account? ",
                        style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const AdminLogin()),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFFF43F5E),
                          padding: EdgeInsets.zero,
                        ),
                        child: const Text('Login', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

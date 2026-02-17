import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'Student_signup.dart';
import 'student_dashboard.dart';
import 'profile_page.dart'; // ✅ Import AuthService here
import 'package:http/http.dart' as http;
import '/../config.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String _statusMessage = '';
  Color _statusColor = Colors.transparent;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _testServerConnection() async {
    try {
      final response = await http.get(Uri.parse(AppConfig.testConnection))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server connection successful!'),
              backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server test failed with status: ${response.statusCode}'),
              backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Server test failed: $e'),
            backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _submitAuthForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _statusMessage = '';
        _statusColor = Colors.transparent;
      });

      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      try {
        // Use AuthProvider to handle login
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final loginResponse = await authProvider.login(email, password);

        // Expecting { "token": "...", "user": {...} }
        final token = loginResponse['token'];
        final user = loginResponse['user'];
        final studentId = user['id']; // Get the student ID from the user data

        if (token != null && user != null && studentId != null) {
          // ✅ Save token and user in SharedPreferences
          await AuthService.saveToken(token, user);

          setState(() {
            _statusMessage = 'Student Logged In Successfully!';
            _statusColor = Colors.green;
          });

          await Future.delayed(const Duration(milliseconds: 1500));

          // ✅ Navigate to dashboard
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            // Pass the studentId to the dashboard
            MaterialPageRoute(builder: (context) => StudentDashboard(studentId: studentId)),
          );
        } else {
          throw Exception("Invalid login response. Token or user missing.");
        }

      } catch (error) {
        String errorMessage = 'Failed to login: ';
        if (error.toString().contains('Failed host lookup')) {
          errorMessage += 'Cannot connect to server. Please check your connection.';
        } else if (error.toString().contains('Connection refused')) {
          errorMessage += 'Server not running. Please start your backend server.';
        } else {
          errorMessage += error.toString();
        }

        setState(() {
          _statusMessage = errorMessage;
          _statusColor = Colors.red;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        title: const Text('AIMS',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF64B5F6), Color(0xFFE3F2FD)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Welcome..!',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                const SizedBox(height: 8),
                const Text('Sign in to access your dashboard',
                    style: TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 16),

                if (_statusMessage.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: _statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _statusColor, width: 1),
                    ),
                    child: Text(_statusMessage,
                        style: TextStyle(color: _statusColor, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center),
                  ),

                Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email Address',
                            prefixIcon: const Icon(Icons.email_outlined),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email address';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                .hasMatch(value)) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        _isLoading
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                          onPressed: _submitAuthForm,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            backgroundColor: const Color(0xFF1E88E5),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('LOGIN', style: TextStyle(fontSize: 18)),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Forgot password feature coming soon!')),
                            );
                          },
                          child: const Text('Forgot Password?', style: TextStyle(color: Color(0xFF1E88E5))),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const Student_signup()),
                    );
                  },
                  child: const Text('Don\'t have an account? Sign Up',
                      style: TextStyle(color: Color(0xFF1E88E5))),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
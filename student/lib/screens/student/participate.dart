import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ParticipatePage extends StatefulWidget {
  final String eventName;

  const ParticipatePage({Key? key, required this.eventName}) : super(key: key);

  @override
  _ParticipatePageState createState() => _ParticipatePageState();
}

class _ParticipatePageState extends State<ParticipatePage> {
  final TextEditingController _registerNumberController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();

  String _statusMessage = '';
  Color _statusColor = Colors.transparent;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _registerNumberController.dispose();
    _nameController.dispose();
    _phoneNumberController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    // Basic validation
    if (_registerNumberController.text.isEmpty ||
        _nameController.text.isEmpty ||
        _phoneNumberController.text.isEmpty ||
        _departmentController.text.isEmpty) {
      setState(() {
        _statusMessage = 'Please fill all required fields.';
        _statusColor = const Color(0xFFE53E3E); // Red
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _statusMessage = 'Registering...';
      _statusColor = const Color(0xFF3182CE); // Blue
    });

    final Map<String, dynamic> data = {
      'eventName': widget.eventName,
      'registerNumber': _registerNumberController.text,
      'name': _nameController.text,
      'phoneNumber': _phoneNumberController.text,
      'department': _departmentController.text,
    };

    try {
      final response = await http.post(
        Uri.parse('https://campus-connect-p1ow.onrender.com/api/participate/register'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(data),
      );

      if (!mounted) return;

      if (response.statusCode == 201) {
        setState(() {
          _statusMessage = 'Registration successful!';
          _statusColor = const Color(0xFF38A169); // Green
        });
        _registerNumberController.clear();
        _nameController.clear();
        _phoneNumberController.clear();
        _departmentController.clear();
      } else if (response.statusCode == 409) {
        final responseBody = jsonDecode(response.body);
        final msg = responseBody['msg'] ?? 'Event is already registered with this register number';

        setState(() {
          _statusMessage = msg;
          _statusColor = const Color(0xFFDD6B20); // Orange
        });
      } else {
        final msg = jsonDecode(response.body)['msg'] ?? 'Failed to register. Please try again.';
        setState(() {
          _statusMessage = msg;
          _statusColor = const Color(0xFFE53E3E); // Red
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _statusMessage = 'Network Error: $e';
        _statusColor = const Color(0xFFE53E3E); // Red
      });
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FE), // Light background matching dashboard
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF4A5568), size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Text(
          'Registration',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Color(0xFF2D3748),
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 60),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Event Name Header
            Container(
              padding: const EdgeInsets.all(24),
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFACE0F9), Color(0xFFE0C3FC)], // Ice Blue to Lilac
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8EC5FC).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'JOINING EVENT',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.white70,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.eventName,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Status Message Display
            if (_statusMessage.isNotEmpty)
              AnimatedOpacity(
                opacity: 1.0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _statusColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _statusColor == const Color(0xFF38A169) ? Icons.check_circle_rounded : Icons.info_rounded,
                        color: _statusColor,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _statusMessage,
                          style: TextStyle(
                            color: _statusColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Form Fields
            _buildTextField('Register Number', Icons.badge_rounded, controller: _registerNumberController),
            const SizedBox(height: 16),
            _buildTextField('Name', Icons.person_rounded, controller: _nameController),
            const SizedBox(height: 16),
            _buildTextField('Phone Number', Icons.phone_iphone_rounded, controller: _phoneNumberController, keyboardType: TextInputType.phone),
            const SizedBox(height: 16),
            _buildTextField('Department', Icons.domain_rounded, controller: _departmentController),

            const SizedBox(height: 40),

            // Submit Button
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (context, double val, child) {
                return Opacity(opacity: val, child: child);
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6C63FF).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    disabledBackgroundColor: const Color(0xFFA0AEC0),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                  child: Center(
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                          )
                        : const Text(
                            'CONFIRM REGISTRATION',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, {TextInputType keyboardType = TextInputType.text, required TextEditingController controller}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Color(0xFF2D3748),
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Color(0xFFA0AEC0),
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          prefixIcon: Icon(icon, color: const Color(0xFF6C63FF), size: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        ),
      ),
    );
  }
}

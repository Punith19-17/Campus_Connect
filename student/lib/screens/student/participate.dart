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
    if (_registerNumberController.text.isEmpty ||
        _nameController.text.isEmpty ||
        _phoneNumberController.text.isEmpty ||
        _departmentController.text.isEmpty) {
      _showModernSnackBar('Please fill all required fields.', Colors.redAccent);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _statusMessage = 'Registering...';
      _statusColor = const Color(0xFF6C63FF);
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
        _showModernSnackBar('Registration successful!', const Color(0xFF2CB67D));
        _registerNumberController.clear();
        _nameController.clear();
        _phoneNumberController.clear();
        _departmentController.clear();
        
        setState(() {
          _statusMessage = '';
        });
        
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) Navigator.pop(context);
        });

      } else if (response.statusCode == 409) {
        final responseBody = jsonDecode(response.body);
        final msg = responseBody['msg'] ?? 'Event is already registered with this register number';
        _showModernSnackBar(msg, const Color(0xFFF59E0B));
        setState(() => _statusMessage = '');
      } else {
        final msg = jsonDecode(response.body)['msg'] ?? 'Failed to register. Please try again.';
        _showModernSnackBar(msg, Colors.redAccent);
        setState(() => _statusMessage = '');
      }
    } catch (e) {
      if (!mounted) return;
      _showModernSnackBar('Network Error: $e', Colors.redAccent);
      setState(() => _statusMessage = '');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
  
  void _showModernSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              color == const Color(0xFF2CB67D) ? Icons.check_circle_rounded : 
              color == const Color(0xFFF59E0B) ? Icons.warning_rounded : Icons.error_rounded, 
              color: Colors.white
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        elevation: 10,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Join Event',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.45,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFFFF6584)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'REGISTRATION',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.eventName,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF7F9FC),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                    ),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(24.0),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_statusMessage.isNotEmpty && _isSubmitting)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                margin: const EdgeInsets.only(bottom: 24),
                                decoration: BoxDecoration(
                                  color: _statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: _statusColor.withOpacity(0.3)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 16, 
                                      height: 16, 
                                      child: CircularProgressIndicator(strokeWidth: 2, color: _statusColor)
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      _statusMessage,
                                      style: TextStyle(color: _statusColor, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              
                            _buildInputField(
                              label: 'Register Number',
                              icon: Icons.badge_rounded,
                              controller: _registerNumberController,
                            ),
                            const SizedBox(height: 16),
                            _buildInputField(
                              label: 'Full Name',
                              icon: Icons.person_rounded,
                              controller: _nameController,
                            ),
                            const SizedBox(height: 16),
                            _buildInputField(
                              label: 'Phone Number',
                              icon: Icons.phone_rounded,
                              controller: _phoneNumberController,
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 16),
                            _buildInputField(
                              label: 'Department',
                              icon: Icons.school_rounded,
                              controller: _departmentController,
                            ),
                            const SizedBox(height: 32),
                            
                            ElevatedButton(
                              onPressed: _isSubmitting ? null : _submitForm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6C63FF),
                                disabledBackgroundColor: const Color(0xFFCBD5E1),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                minimumSize: const Size(double.infinity, 56),
                                elevation: 0,
                              ),
                              child: _isSubmitting
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                                    )
                                  : const Text(
                                      'SUBMIT REGISTRATION',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: Colors.black45,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF7F9FC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: const Color(0xFF6C63FF), size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              hintText: 'Enter your $label',
              hintStyle: const TextStyle(
                color: Colors.black38,
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

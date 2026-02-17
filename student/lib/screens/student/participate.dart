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

  // New state variable to show the status message
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
        _statusColor = Colors.red;
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _statusMessage = 'Registering...';
      _statusColor = Colors.blue;
    });

    // Prepare data to send to the backend, now including event name
    final Map<String, dynamic> data = {
      'eventName': widget.eventName, // Pass the event name
      'registerNumber': _registerNumberController.text,
      'name': _nameController.text,
      'phoneNumber': _phoneNumberController.text,
      'department': _departmentController.text,
    };

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:5000/api/participate/register'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(data),
      );

      if (!mounted) return;

      if (response.statusCode == 201) {
        // Success case
        setState(() {
          _statusMessage = 'Registration successful!';
          _statusColor = Colors.green;
        });
        // Clear the form fields after successful submission
        _registerNumberController.clear();
        _nameController.clear();
        _phoneNumberController.clear();
        _departmentController.clear();

      } else if (response.statusCode == 409) {
        // FIX: Handle 409 Conflict (Duplicate Entry)
        final responseBody = jsonDecode(response.body);
        final msg = responseBody['msg'] ?? 'Event is already registered with this register number';

        setState(() {
          _statusMessage = msg;
          _statusColor = Colors.red;
        });
      } else {
        // General error case (e.g., 500)
        final msg = jsonDecode(response.body)['msg'] ?? 'Failed to register. Please try again.';
        setState(() {
          _statusMessage = msg;
          _statusColor = Colors.red;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _statusMessage = 'Network Error: $e';
        _statusColor = Colors.red;
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
      appBar: AppBar(
        title: Text('Joining: ${widget.eventName}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            // Status Message Display
            if (_statusMessage.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _statusColor),
                ),
                child: Text(
                  _statusMessage,
                  style: TextStyle(color: _statusColor, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),

            _buildTextField('Register Number *', controller: _registerNumberController),
            _buildTextField('Name *', controller: _nameController),
            _buildTextField('Phone Number *', controller: _phoneNumberController, keyboardType: TextInputType.phone),
            _buildTextField('Department *', controller: _departmentController),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
                child: _isSubmitting
                    ? const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                    : const Text('SUBMIT'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isSubmitting ? Colors.grey : Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, {TextInputType keyboardType = TextInputType.text, required TextEditingController controller}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}
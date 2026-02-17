// lib/screens/admin/add_event.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '/../config.dart';
import '../../models/event_model.dart'; // Import the unified Event model
import 'manage_events.dart';

class AddEventPage extends StatefulWidget {
  final Event? event;

  const AddEventPage({super.key, this.event});

  @override
  State<AddEventPage> createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _eventTitleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _organizedClubController = TextEditingController();
  final TextEditingController _awardController = TextEditingController();

  bool _isLoading = false;
  String? _selectedEventType;
  final List<String> _eventTypes = ['College Function', 'Club Event'];
  bool get isEditing => widget.event != null;

  @override
  void initState() {
    super.initState();

    if (isEditing) {
      final currentEvent = widget.event!;
      _eventTitleController.text = currentEvent.eventTitle;
      _descriptionController.text = currentEvent.description;
      _dateController.text = currentEvent.originalDate;
      _startTimeController.text = currentEvent.formattedStartTime;
      _endTimeController.text = currentEvent.formattedEndTime;
      _locationController.text = currentEvent.location;
      _organizedClubController.text = currentEvent.organizedClub;
      _awardController.text = currentEvent.award ?? '';
      _selectedEventType = currentEvent.eventType;
    } else {
      // Set default times for new events
      _startTimeController.text = '09:00';
      _endTimeController.text = '10:00';
    }
  }

  String _formatTimeForDisplay(String time) {
    try {
      List<String> parts = time.split(':');
      if (parts.length >= 2) {
        return '${parts[0]}:${parts[1]}';
      }
      return time;
    } catch (e) {
      return time;
    }
  }

  String _formatTimeForAPI(String time) {
    if (time.split(':').length == 2) {
      return '$time:00';
    }
    return time;
  }

  // Enhanced clash check with start and end times
  Future<Map<String, dynamic>> _checkEventClash() async {
    try {
      final Map<String, String> clashCheckData = {
        'date': _dateController.text.trim(),
        'time': _formatTimeForAPI(_startTimeController.text.trim()),
        'end_time': _formatTimeForAPI(_endTimeController.text.trim()),
        'location': _locationController.text.trim(),
        'event_id': isEditing ? widget.event!.id.toString() : '0',
      };

      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/api/events/check-clash'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(clashCheckData),
      );

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Error checking event clash: $e'};
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate time format and order
    if (!_isValidTime(_startTimeController.text) || !_isValidTime(_endTimeController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter time in HH:MM format (e.g., 14:30)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate start time is before end time
    final startTime = _startTimeController.text;
    final endTime = _endTimeController.text;
    if (startTime.compareTo(endTime) >= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End time must be after start time'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Check for event clash
      final clashResult = await _checkEventClash();

      if (!clashResult['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(clashResult['message']),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isLoading = false);
        return;
      }

      if (clashResult['hasClash'] == true) {
        final clashingEvents = clashResult['clashingEvents'] ?? [];
        String clashMessage = 'Event clashes with existing events:\n\n';

        for (var event in clashingEvents) {
          clashMessage += '• ${event['event_title']}\n';
          clashMessage += '  Club: ${event['organized_club']}\n';
          clashMessage += '  Time: ${_formatTimeForDisplay(event['time'])} - ${_formatTimeForDisplay(event['end_time'])}\n\n';
        }

        clashMessage += 'Please choose a different time or location.';

        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('⚠️ Event Clash '),
              content: SingleChildScrollView(
                child: Text(clashMessage),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );

        setState(() => _isLoading = false);
        return;
      }

      // Proceed with event creation/update
      http.Response response;

      if (isEditing) {
        final uri = Uri.parse('${AppConfig.baseUrl}/api/addevents/${widget.event!.id}');
        final headers = {'Content-Type': 'application/json'};
        final body = json.encode({
          'event_type': _selectedEventType!,
          'event_title': _eventTitleController.text,
          'description': _descriptionController.text,
          'date': _dateController.text,
          'time': _formatTimeForAPI(_startTimeController.text),
          'end_time': _formatTimeForAPI(_endTimeController.text),
          'location': _locationController.text,
          'organized_club': _organizedClubController.text,
          'award': _awardController.text.isEmpty ? null : _awardController.text,
        });

        response = await http.put(uri, headers: headers, body: body);
      } else {
        final uri = Uri.parse('${AppConfig.baseUrl}/api/addevents');
        final headers = {'Content-Type': 'application/json'};
        final body = json.encode({
          'event_type': _selectedEventType!,
          'event_title': _eventTitleController.text,
          'description': _descriptionController.text,
          'date': _dateController.text,
          'time': _formatTimeForAPI(_startTimeController.text),
          'end_time': _formatTimeForAPI(_endTimeController.text),
          'location': _locationController.text,
          'organized_club': _organizedClubController.text,
          'award': _awardController.text.isEmpty ? null : _awardController.text,
        });

        response = await http.post(uri, headers: headers, body: body);
      }

      if (!mounted) return;

      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(jsonResponse['message'] ?? 'Event ${isEditing ? 'updated' : 'created'} successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(jsonResponse['message'] ?? 'Operation failed.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  bool _isValidTime(String time) {
    RegExp timeRegex = RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$');
    return timeRegex.hasMatch(time);
  }

  Future<void> _selectTime(TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      final formattedTime = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      setState(() {
        controller.text = formattedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          isEditing ? 'Alter Event' : 'Add New Event',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: _selectedEventType,
                decoration: const InputDecoration(
                  labelText: 'Event Type *',
                  border: OutlineInputBorder(),
                ),
                items: _eventTypes.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) => setState(() => _selectedEventType = newValue),
                validator: (value) => value == null || value.isEmpty ? 'Please select an event type' : null,
              ),
              const SizedBox(height: 10),
              _buildTextField(_eventTitleController, 'Event Title', isRequired: true),
              _buildTextField(_descriptionController, 'Description', isRequired: true, maxLines: 3),

              // Date Field
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  controller: _dateController,
                  readOnly: true,
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.tryParse(_dateController.text) ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2101),
                    );
                    if (picked != null) {
                      setState(() => _dateController.text = DateFormat('yyyy-MM-dd').format(picked));
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'Date (YYYY-MM-DD) *',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Please select a date' : null,
                ),
              ),

              // Start Time Field
              _buildTimeField(_startTimeController, 'Start Time (HH:MM) *'),

              // End Time Field
              _buildTimeField(_endTimeController, 'End Time (HH:MM) *'),

              _buildTextField(_locationController, 'Location', isRequired: true),
              _buildTextField(_organizedClubController, 'Organized Club', isRequired: true),
              _buildTextField(_awardController, 'Award (Optional)'),

              const SizedBox(height: 30),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isEditing ? Colors.green : Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  isEditing ? 'UPDATE EVENT' : 'SUBMIT EVENT',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText, {bool isRequired = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: isRequired ? '$labelText *' : labelText,
          border: const OutlineInputBorder(),
        ),
        validator: isRequired
            ? (value) => value == null || value.isEmpty ? 'Please enter the $labelText' : null
            : null,
      ),
    );
  }

  Widget _buildTimeField(TextEditingController controller, String labelText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        onTap: () => _selectTime(controller),
        decoration: InputDecoration(
          labelText: labelText,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.access_time),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select time';
          }
          if (!_isValidTime(value)) {
            return 'Please use HH:MM format';
          }
          return null;
        },
      ),
    );
  }
}
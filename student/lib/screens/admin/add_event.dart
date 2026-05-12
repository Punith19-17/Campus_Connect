import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '/../config.dart';
import '../../models/event_model.dart';
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

    if (!_isValidTime(_startTimeController.text) || !_isValidTime(_endTimeController.text)) {
      _showErrorSnackBar('Please enter time in HH:MM format (e.g., 14:30)');
      return;
    }

    if (_startTimeController.text.compareTo(_endTimeController.text) >= 0) {
      _showErrorSnackBar('End time must be after start time');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final clashResult = await _checkEventClash();

      if (!clashResult['success']) {
        _showErrorSnackBar(clashResult['message']);
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('⚠️ Event Clash', style: TextStyle(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(child: Text(clashMessage)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK', style: TextStyle(color: Color(0xFF4F46E5), fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );

        setState(() => _isLoading = false);
        return;
      }

      final uri = Uri.parse(isEditing 
          ? '${AppConfig.baseUrl}/api/addevents/${widget.event!.id}'
          : '${AppConfig.baseUrl}/api/addevents');
      
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

      final response = isEditing 
          ? await http.put(uri, headers: headers, body: body)
          : await http.post(uri, headers: headers, body: body);

      if (!mounted) return;

      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(jsonResponse['message'] ?? 'Event successfully saved!', style: const TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        Navigator.of(context).pop(true);
      } else {
        _showErrorSnackBar(jsonResponse['message'] ?? 'Operation failed.');
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('An error occurred: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  bool _isValidTime(String time) {
    RegExp timeRegex = RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$');
    return timeRegex.hasMatch(time);
  }

  Future<void> _selectTime(TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF4F46E5)),
          ),
          child: child!,
        );
      },
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
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          isEditing ? 'Alter Event' : 'Add New Event',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Form(
            key: _formKey,
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                _buildDropdown(),
                const SizedBox(height: 16),
                _buildTextField(_eventTitleController, 'Event Title', Icons.title_rounded, isRequired: true),
                _buildTextField(_descriptionController, 'Description', Icons.description_rounded, isRequired: true, maxLines: 3),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildDateField(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(child: _buildTimeField(_startTimeController, 'Start Time')),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTimeField(_endTimeController, 'End Time')),
                  ],
                ),
                const SizedBox(height: 16),

                _buildTextField(_locationController, 'Location', Icons.location_on_rounded, isRequired: true),
                _buildTextField(_organizedClubController, 'Organized Club', Icons.group_rounded, isRequired: true),
                _buildTextField(_awardController, 'Award (Optional)', Icons.emoji_events_rounded),

                const SizedBox(height: 40),
                _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF4F46E5)))
                    : Container(
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF818CF8), Color(0xFF4F46E5)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4F46E5).withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Text(
                            isEditing ? 'UPDATE EVENT' : 'CREATE EVENT',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedEventType,
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
      decoration: InputDecoration(
        labelText: 'Event Type *',
        labelStyle: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w500),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        prefixIcon: const Icon(Icons.category_rounded, color: Color(0xFF94A3B8)),
      ),
      items: _eventTypes.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        );
      }).toList(),
      onChanged: (newValue) => setState(() => _selectedEventType = newValue),
      validator: (value) => value == null || value.isEmpty ? 'Please select an event type' : null,
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isRequired = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
        decoration: InputDecoration(
          labelText: isRequired ? '$label *' : label,
          labelStyle: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w500),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          prefixIcon: Icon(icon, color: const Color(0xFF94A3B8)),
        ),
        validator: isRequired ? (value) => value == null || value.isEmpty ? 'Please enter $label' : null : null,
      ),
    );
  }

  Widget _buildDateField() {
    return TextFormField(
      controller: _dateController,
      readOnly: true,
      style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.tryParse(_dateController.text) ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2101),
          builder: (context, child) {
            return Theme(
              data: ThemeData.light().copyWith(colorScheme: const ColorScheme.light(primary: Color(0xFF4F46E5))),
              child: child!,
            );
          },
        );
        if (picked != null) {
          setState(() => _dateController.text = DateFormat('yyyy-MM-dd').format(picked));
        }
      },
      decoration: InputDecoration(
        labelText: 'Date *',
        labelStyle: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w500),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        prefixIcon: const Icon(Icons.calendar_today_rounded, color: Color(0xFF94A3B8)),
      ),
      validator: (value) => value == null || value.isEmpty ? 'Please select a date' : null,
    );
  }

  Widget _buildTimeField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
      onTap: () => _selectTime(controller),
      decoration: InputDecoration(
        labelText: '$label *',
        labelStyle: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w500),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        prefixIcon: const Icon(Icons.access_time_rounded, color: Color(0xFF94A3B8)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Select time';
        if (!_isValidTime(value)) return 'Use HH:MM';
        return null;
      },
    );
  }
}

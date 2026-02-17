import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'manage_clubs.dart'; // Import the updated Club model
import '/../config.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AddClubPage extends StatefulWidget {
  final Club? club;
  const AddClubPage({super.key, this.club});

  @override
  State<AddClubPage> createState() => _AddClubPageState();
}

class _AddClubPageState extends State<AddClubPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _clubNameController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _responsibleFacultyController = TextEditingController();
  final TextEditingController _presidentController = TextEditingController();
  final TextEditingController _vicePresidentController = TextEditingController();
  final TextEditingController _jointSecretaryController = TextEditingController();
  final TextEditingController _treasuryController = TextEditingController();
  final TextEditingController _clubDescriptionController = TextEditingController();
  final List<TextEditingController> _groupMembersControllers = [];

  // Removed image-related variables
  // File? _clubImage;
  // String? _webImagePath;

  bool _isLoading = false;
  String? _selectedClubType;

  bool get isEditing => widget.club != null;

  @override
  void initState() {
    super.initState();

    if (isEditing) {
      // If editing, populate all controllers with the club's data
      final club = widget.club!;
      _clubNameController.text = club.name;
      _clubDescriptionController.text = club.description;
      _departmentController.text = club.department;
      _responsibleFacultyController.text = club.responsibleFaculty ?? '';
      _presidentController.text = club.president;
      _vicePresidentController.text = club.vicePresident;
      _jointSecretaryController.text = club.jointSecretary;
      _treasuryController.text = club.treasury;
      _selectedClubType = club.clubType;

      // Populate group members from the comma-separated string
      if (club.groupMembers.isNotEmpty) {
        final members = club.groupMembers.split(',').map((e) => e.trim()).toList();
        for (var member in members) {
          _groupMembersControllers.add(TextEditingController(text: member));
        }
      }
    }

    // Ensure there's at least one member controller for adding new clubs
    if (_groupMembersControllers.isEmpty) {
      _groupMembersControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    _clubNameController.dispose();
    _departmentController.dispose();
    _responsibleFacultyController.dispose();
    _presidentController.dispose();
    _vicePresidentController.dispose();
    _jointSecretaryController.dispose();
    _treasuryController.dispose();
    _clubDescriptionController.dispose();
    for (var controller in _groupMembersControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // Removed _pickImage method
  // Future<void> _pickImage() async {
  //   final picker = ImagePicker();
  //   final pickedFile = await picker.pickImage(source: ImageSource.gallery);
  //   if (pickedFile != null) {
  //     setState(() {
  //       if (kIsWeb) {
  //         _webImagePath = pickedFile.path;
  //         _clubImage = null;
  //       } else {
  //         _clubImage = File(pickedFile.path);
  //         _webImagePath = null;
  //       }
  //     });
  //   }
  // }

  void _addMemberField() {
    setState(() {
      _groupMembersControllers.add(TextEditingController());
    });
  }

  void _removeMemberField(int index) {
    if (_groupMembersControllers.length > 1) {
      setState(() {
        _groupMembersControllers[index].dispose();
        _groupMembersControllers.removeAt(index);
      });
    }
  }

  Future<void> _saveClub() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _isLoading = true);

    try {
      List<String> members = _groupMembersControllers
          .map((c) => c.text.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      final Map<String, String> fields = {
        'club_name': _clubNameController.text,
        'club_discription': _clubDescriptionController.text,
        'department': _departmentController.text,
        'responsible_faculty': _responsibleFacultyController.text,
        'president': _presidentController.text,
        'vice_president': _vicePresidentController.text,
        'joint_secretary': _jointSecretaryController.text,
        'treasury': _treasuryController.text,
        'club_type': _selectedClubType ?? 'institutional',
        'group_members': members.join(', '),
      };

      http.Response response;
      if (isEditing) {
        // UPDATE Logic: Send a PUT request with a JSON body
        final uri = Uri.parse('${AppConfig.baseUrl}/api/clubs/${widget.club!.id}');
        response = await http.put(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: json.encode(fields),
        );
      } else {
        // CREATE Logic: Send a POST request with a JSON body
        final uri = Uri.parse('${AppConfig.baseUrl}/api/clubs');
        response = await http.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: json.encode(fields),
        );
      }

      if (!mounted) return;
      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(jsonResponse['message'] ?? 'Club ${isEditing ? 'updated' : 'created'} successfully!'),
          backgroundColor: Colors.green,
        ));
        Navigator.of(context).pop(true);
      } else {
        throw Exception(jsonResponse['message'] ?? 'Operation failed.');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e'),
        backgroundColor: Colors.red,
      ));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          isEditing ? 'Alter Club' : 'Add New Club',
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
              // The image selection section has been removed from here.

              _buildTextField(_clubNameController, 'Club Name', isRequired: true),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedClubType,
                decoration: const InputDecoration(labelText: 'Club Type *', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'departmental', child: Text('Department Club')),
                  DropdownMenuItem(value: 'institutional', child: Text('Collage Club')),
                ],
                onChanged: (value) => setState(() => _selectedClubType = value!),
                validator: (value) => value == null ? 'Please select a club type' : null,
              ),
              const SizedBox(height: 10),
              _buildTextField(_clubDescriptionController, 'Club Description', isRequired: true, maxLines: 3),
              _buildTextField(_departmentController, 'Department', isRequired: true),
              _buildTextField(_responsibleFacultyController, 'Responsible Faculty'),
              _buildTextField(_presidentController, 'President', isRequired: true),
              _buildTextField(_vicePresidentController, 'Vice President', isRequired: true),
              _buildTextField(_jointSecretaryController, 'Joint Secretary', isRequired: true),
              _buildTextField(_treasuryController, 'Treasury', isRequired: true),

              const SizedBox(height: 20),
              const Text('Group Members', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ..._groupMembersControllers.asMap().entries.map((entry) {
                int index = entry.key;
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: entry.value,
                          decoration: InputDecoration(
                            labelText: 'Member ${index + 1}',
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      if (_groupMembersControllers.length > 1)
                        IconButton(
                          icon: const Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () => _removeMemberField(index),
                        ),
                    ],
                  ),
                );
              }).toList(),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _addMemberField,
                icon: const Icon(Icons.add),
                label: const Text('Add Member'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green[600]),
              ),

              const SizedBox(height: 30),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _saveClub,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isEditing ? Colors.green : Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  isEditing ? 'UPDATE CLUB' : 'SUBMIT CLUB',
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
}
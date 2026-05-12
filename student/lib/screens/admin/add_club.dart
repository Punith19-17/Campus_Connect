import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'manage_clubs.dart';
import '/../config.dart';

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

  bool _isLoading = false;
  String? _selectedClubType;

  bool get isEditing => widget.club != null;

  @override
  void initState() {
    super.initState();

    if (isEditing) {
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

      if (club.groupMembers.isNotEmpty) {
        final members = club.groupMembers.split(',').map((e) => e.trim()).toList();
        for (var member in members) {
          _groupMembersControllers.add(TextEditingController(text: member));
        }
      }
    }

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
        final uri = Uri.parse('${AppConfig.baseUrl}/api/clubs/${widget.club!.id}');
        response = await http.put(uri, headers: {'Content-Type': 'application/json'}, body: json.encode(fields));
      } else {
        final uri = Uri.parse('${AppConfig.baseUrl}/api/clubs');
        response = await http.post(uri, headers: {'Content-Type': 'application/json'}, body: json.encode(fields));
      }

      if (!mounted) return;
      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(jsonResponse['message'] ?? 'Club successfully saved!', style: const TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
        Navigator.of(context).pop(true);
      } else {
        throw Exception(jsonResponse['message'] ?? 'Operation failed.');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
          isEditing ? 'Alter Club' : 'Add New Club',
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
                _buildTextField(_clubNameController, 'Club Name', Icons.groups_rounded, isRequired: true),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: _selectedClubType,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
                  decoration: InputDecoration(
                    labelText: 'Club Type *',
                    labelStyle: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    prefixIcon: const Icon(Icons.category_rounded, color: Color(0xFF94A3B8)),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'departmental', child: Text('Department Club', style: TextStyle(fontWeight: FontWeight.w600))),
                    DropdownMenuItem(value: 'institutional', child: Text('College Club', style: TextStyle(fontWeight: FontWeight.w600))),
                  ],
                  onChanged: (value) => setState(() => _selectedClubType = value!),
                  validator: (value) => value == null ? 'Please select a club type' : null,
                ),

                const SizedBox(height: 16),
                _buildTextField(_clubDescriptionController, 'Club Description', Icons.description_rounded, isRequired: true, maxLines: 3),
                _buildTextField(_departmentController, 'Department', Icons.business_rounded, isRequired: true),
                _buildTextField(_responsibleFacultyController, 'Responsible Faculty', Icons.school_rounded),
                _buildTextField(_presidentController, 'President', Icons.person_rounded, isRequired: true),
                _buildTextField(_vicePresidentController, 'Vice President', Icons.person_2_rounded, isRequired: true),
                _buildTextField(_jointSecretaryController, 'Joint Secretary', Icons.person_3_rounded, isRequired: true),
                _buildTextField(_treasuryController, 'Treasury', Icons.account_balance_wallet_rounded, isRequired: true),

                const SizedBox(height: 24),
                const Text('Group Members', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
                const SizedBox(height: 12),

                ..._groupMembersControllers.asMap().entries.map((entry) {
                  int index = entry.key;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: entry.value,
                            style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                            decoration: InputDecoration(
                              labelText: 'Member ${index + 1}',
                              labelStyle: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                              prefixIcon: const Icon(Icons.person_add_rounded, color: Color(0xFF94A3B8)),
                            ),
                          ),
                        ),
                        if (_groupMembersControllers.length > 1)
                          IconButton(
                            icon: const Icon(Icons.remove_circle_rounded, color: Color(0xFFEF4444), size: 28),
                            onPressed: () => _removeMemberField(index),
                          ),
                      ],
                    ),
                  );
                }).toList(),

                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _addMemberField,
                    icon: const Icon(Icons.add_circle_outline_rounded, color: Color(0xFF10B981)),
                    label: const Text('Add Member', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.w700)),
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981).withOpacity(0.1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
                _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFFF59E0B)))
                    : Container(
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFCD34D), Color(0xFFF59E0B)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFF59E0B).withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _saveClub,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Text(
                            isEditing ? 'UPDATE CLUB' : 'CREATE CLUB',
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
}

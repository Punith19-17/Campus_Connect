import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

// A model class to deserialize the data from the API
class Participant {
  final int id;
  final String eventName;
  final String registerNumber;
  final String name;
  final String phoneNumber;
  final String department;
  final String createdAt;

  Participant({
    required this.id,
    required this.eventName,
    required this.registerNumber,
    required this.name,
    required this.phoneNumber,
    required this.department,
    required this.createdAt,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      id: json['id'],
      eventName: json['event_name'],
      registerNumber: json['register_number'],
      name: json['name'],
      phoneNumber: json['phone_number'],
      department: json['department'],
      createdAt: json['created_at'],
    );
  }
}

class ParticipationListPage extends StatefulWidget {
  const ParticipationListPage({Key? key}) : super(key: key);

  @override
  State<ParticipationListPage> createState() => _ParticipationListPageState();
}

class _ParticipationListPageState extends State<ParticipationListPage> {
  // State variables for data and filtering
  List<Participant> _allParticipants = [];
  List<Participant> _filteredParticipants = [];
  bool _isLoading = true;
  String? _errorMessage;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchParticipants();
    // Listen for changes in the search bar
    _searchController.addListener(_filterParticipants);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterParticipants);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchParticipants() async {
    try {
      final response = await http.get(Uri.parse('https://campus-connect-p1ow.onrender.com/api/participate'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        final fetchedParticipants = data.map((json) => Participant.fromJson(json)).toList();

        setState(() {
          _allParticipants = fetchedParticipants;
          _filteredParticipants = fetchedParticipants;
          _isLoading = false;
          _errorMessage = null;
        });
      } else {
        throw Exception('Failed to load participants. Status: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error fetching data: ${e.toString()}';
      });
    }
  }

  void _filterParticipants() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      if (query.isEmpty) {
        // If query is empty, show all participants
        _filteredParticipants = _allParticipants;
      } else {
        // Filter based on event name, department, or date (createdAt)
        _filteredParticipants = _allParticipants.where((participant) {
          final eventNameMatches = participant.eventName.toLowerCase().contains(query);
          final departmentMatches = participant.department.toLowerCase().contains(query);

          // Attempt to format and check date (assuming the date part is at the start)
          final dateString = participant.createdAt.split(' ')[0];
          final dateMatches = dateString.contains(query);

          return eventNameMatches || departmentMatches || dateMatches;
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Light grey background matching add_event.dart
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Participation Details',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
        ),
        child: Column(
          children: [
            // Modern Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                decoration: InputDecoration(
                  hintText: 'Search by event, date, or department...',
                  hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
                  prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF4F46E5)), // Indigo accent
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                    borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2),
                  ),
                ),
              ),
            ),

            // Conditional Body (Loading/Error/List)
            Expanded(
              child: _buildBody(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF4F46E5)));
    } else if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
          ),
        ),
      );
    } else if (_filteredParticipants.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.withOpacity(0.5)),
            const SizedBox(height: 16),
            const Text(
              'No participants found.',
              style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ],
        ),
      );
    } else {
      // Data is loaded, display the filtered list
      return ListView.builder(
        padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
        physics: const BouncingScrollPhysics(),
        itemCount: _filteredParticipants.length,
        itemBuilder: (context, index) {
          final participant = _filteredParticipants[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF1F5F9), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event Name Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF), // Indigo tint
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.event_rounded, color: Color(0xFF4F46E5), size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          participant.eventName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Color(0xFFF1F5F9), height: 1),
                  const SizedBox(height: 16),

                  _buildDetailRow(Icons.person_rounded, 'Name', participant.name),
                  const SizedBox(height: 12),
                  _buildDetailRow(Icons.badge_rounded, 'Register No.', participant.registerNumber),
                  const SizedBox(height: 12),
                  _buildDetailRow(Icons.business_center_rounded, 'Department', participant.department),
                  const SizedBox(height: 12),
                  _buildDetailRow(Icons.phone_rounded, 'Phone', participant.phoneNumber),
                  const SizedBox(height: 12),
                  _buildDetailRow(Icons.access_time_rounded, 'Date & Time', participant.createdAt),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF64748B)),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
          ),
        ),
      ],
    );
  }
}

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
      appBar: AppBar(
        title: const Text('Participation Details'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by event name, date, or department...',
                prefixIcon: const Icon(Icons.search),
                // --- MODIFICATION HERE: Changed BorderSide.none to BorderSide(color: Colors.black, width: 1.5) ---
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(color: Colors.black, width: 1.5), // Added black border
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),

          // Conditional Body (Loading/Error/List)
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    } else if (_filteredParticipants.isEmpty) {
      return const Center(child: Text('No participants match your search criteria.'));
    } else {
      // Data is loaded, display the filtered list
      return ListView.builder(
        itemCount: _filteredParticipants.length,
        itemBuilder: (context, index) {
          final participant = _filteredParticipants[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('Event Name', participant.eventName),
                  const SizedBox(height: 8),
                  _buildDetailRow('Register Number', participant.registerNumber),
                  const SizedBox(height: 8),
                  _buildDetailRow('Name', participant.name),
                  const SizedBox(height: 8),
                  _buildDetailRow('Phone Number', participant.phoneNumber),
                  const SizedBox(height: 8),
                  _buildDetailRow('Department', participant.department),
                  const SizedBox(height: 8),
                  _buildDetailRow('Date & Time', participant.createdAt),
                ],
              ),
            ),
          );
        },
      );
    }
  }
}

Widget _buildDetailRow(String title, String value) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        flex: 2,
        child: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.blueGrey),
        ),
      ),
      Expanded(
        flex: 3,
        child: Text(
          value,
          style: const TextStyle(fontSize: 15, color: Colors.black87),
        ),
      ),
    ],
  );
}
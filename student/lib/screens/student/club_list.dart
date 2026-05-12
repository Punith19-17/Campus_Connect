import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'club-details.dart';

// 1. Updated Club model to match the API response
class Club {
  final int id;
  final String name;
  final String description;
  final String clubType; // 'departmental' or 'institutional'
  final String? picUrl;
  // Add all the specific fields from your admin module's Club model
  final String department;
  final String? responsibleFaculty;
  final String president;
  final String vicePresident;
  final String jointSecretary;
  final String treasury;
  final String groupMembers;

  const Club({
    required this.id,
    required this.name,
    required this.description,
    required this.clubType,
    this.picUrl,
    required this.department,
    this.responsibleFaculty,
    required this.president,
    required this.vicePresident,
    required this.jointSecretary,
    required this.treasury,
    required this.groupMembers,
  });

  factory Club.fromJson(Map<String, dynamic> json) {
    return Club(
      id: json['id'] ?? 0,
      name: json['club_name'] ?? 'No Name',
      description: json['club_discription'] ?? 'No Description',
      clubType: json['club_type'] ?? 'institutional',
      picUrl: json['pic'],
      // Map the new fields from your API response
      department: json['department'] ?? '',
      responsibleFaculty: json['responsible_faculty'],
      president: json['president'] ?? '',
      vicePresident: json['vice_president'] ?? '',
      jointSecretary: json['joint_secretary'] ?? '',
      treasury: json['treasury'] ?? '',
      groupMembers: json['group_members'] ?? '',
    );
  }
}

// The reusable widget for the club card.
class ClubCard extends StatelessWidget {
  final Club club;

  const ClubCard({
    Key? key,
    required this.club,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F6FC),
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Center(
              child: Icon(Icons.group, color: Colors.black54),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            club.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              club.description,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: MaterialButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ClubDetailsPage(club: club),
                      ),
                    );
                  },
                  color: const Color(0xFF1E88E5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  height: 30,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: const Text(
                    'Details',
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ClubDirectoryPage extends StatefulWidget {
  const ClubDirectoryPage({Key? key}) : super(key: key);

  @override
  _ClubDirectoryPageState createState() => _ClubDirectoryPageState();
}

class _ClubDirectoryPageState extends State<ClubDirectoryPage> {
  bool _isLoading = true;
  String _errorMessage = '';
  List<Club> _departmentClubs = [];
  List<Club> _collageClubs = [];
  bool _isDepartmentClubSelected = true;

  @override
  void initState() {
    super.initState();
    _fetchClubs();
  }

  Future<void> _fetchClubs() async {
    const String url = 'https://campus-connect-p1ow.onrender.com/api/clubs';

    try {
      final response = await http.get(Uri.parse(url));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['clubs'] is List) {
          final List<Club> allClubs = (data['clubs'] as List)
              .map((clubJson) => Club.fromJson(clubJson))
              .toList();

          final depts = allClubs
              .where((club) => club.clubType == 'departmental')
              .toList();
          final collages = allClubs
              .where((club) => club.clubType == 'institutional')
              .toList();

          setState(() {
            _departmentClubs = depts;
            _collageClubs = collages;
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = 'Invalid data format from server.';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to load clubs. Status: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to connect to the server.\nError: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  _isDepartmentClubSelected = true;
                });
              },
              child: Text(
                'Department Clubs',
                style: TextStyle(
                  fontSize: 20,
                  color: _isDepartmentClubSelected ? Colors.black : Colors.grey[400],
                  fontWeight: _isDepartmentClubSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            const SizedBox(width: 40),
            InkWell(
              onTap: () {
                setState(() {
                  _isDepartmentClubSelected = false;
                });
              },
              child: Text(
                'College Clubs',
                style: TextStyle(
                  fontSize: 20,
                  color: !_isDepartmentClubSelected ? Colors.black : Colors.grey[400],
                  fontWeight: !_isDepartmentClubSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _errorMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red, fontSize: 16),
          ),
        ),
      )
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
            child: Text(
              _isDepartmentClubSelected ? 'Department Club Directory' : 'Collage Club Directory',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black45,
              ),
            ),
          ),
          Expanded(
            child: _buildClubGrid(
              _isDepartmentClubSelected ? _departmentClubs : _collageClubs,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClubGrid(List<Club> clubs) {
    if (clubs.isEmpty) {
      return const Center(
        child: Text(
          'No clubs found in this category.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
      ),
      padding: const EdgeInsets.all(16.0),
      itemCount: clubs.length,
      itemBuilder: (context, index) {
        final club = clubs[index];
        return ClubCard(
          club: club,
        );
      },
    );
  }
}
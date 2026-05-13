import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'club_details.dart'; // Keep original import, previously the user had 'club-details.dart' in their prompt but 'club_details.dart' is standard. I'll use club_details.dart.

// 1. Updated Club model to match the API response
class Club {
  final int id;
  final String name;
  final String description;
  final String clubType; // 'departmental' or 'institutional'
  final String? picUrl;
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
class ClubCard extends StatefulWidget {
  final Club club;

  const ClubCard({
    Key? key,
    required this.club,
  }) : super(key: key);

  @override
  State<ClubCard> createState() => _ClubCardState();
}

class _ClubCardState extends State<ClubCard> with SingleTickerProviderStateMixin {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isHovered = true),
      onTapUp: (_) => setState(() => _isHovered = false),
      onTapCancel: () => setState(() => _isHovered = false),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ClubDetailsPage(club: widget.club),
          ),
        );
      },
      child: AnimatedScale(
        scale: _isHovered ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.0),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4A90E2).withOpacity(0.08),
                spreadRadius: 0,
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Color(0xFFF8FAFC)],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE0E7FF), Color(0xFFC7D2FE)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Icon(Icons.groups_rounded, color: Color(0xFF4F46E5), size: 28),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.club.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Expanded(
                child: Text(
                  widget.club.description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF4A90E2)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: const Center(
                  child: Text(
                    'Details',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
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
      backgroundColor: const Color(0xFFFAFBFF),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Clubs',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Animated Pill Tab Selector
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Stack(
                          children: [
                            AnimatedAlign(
                              alignment: _isDepartmentClubSelected
                                  ? Alignment.centerLeft
                                  : Alignment.centerRight,
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeInOutCubic,
                              child: FractionallySizedBox(
                                widthFactor: 0.5,
                                child: Container(
                                  margin: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(25),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {
                                      setState(() {
                                        _isDepartmentClubSelected = true;
                                      });
                                    },
                                    child: Center(
                                      child: Text(
                                        'Department',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14,
                                          color: _isDepartmentClubSelected
                                              ? const Color(0xFF6C63FF)
                                              : const Color(0xFF94A3B8),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {
                                      setState(() {
                                        _isDepartmentClubSelected = false;
                                      });
                                    },
                                    child: Center(
                                      child: Text(
                                        'College',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14,
                                          color: !_isDepartmentClubSelected
                                              ? const Color(0xFF6C63FF)
                                              : const Color(0xFF94A3B8),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
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
          style: TextStyle(fontSize: 16, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600),
        ),
      );
    }
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
      ),
      padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 100.0, top: 10.0), // Padding for Nav
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

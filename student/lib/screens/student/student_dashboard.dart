import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

import 'clg_events_details.dart';
import 'Student_login.dart';
import 'club_list.dart';
import 'myresponsespage.dart';
import 'profile_page.dart';

class Aim {
  final String id;
  final String? title;
  final String? description;
  final int? progress;
  final String? status;
  final DateTime eventDate;
  final String location;
  final String organizedClub;
  final String? award;
  final String time;

  Aim({
    required this.id,
    this.title,
    this.description,
    this.progress,
    this.status,
    required this.eventDate,
    required this.location,
    required this.organizedClub,
    this.award,
    required this.time,
  });

  factory Aim.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate = DateTime.now();
    try {
      if (json['date'] != null) {
        String dateStr = json['date'].toString();
        if (dateStr.contains('T')) dateStr = dateStr.split('T')[0];
        
        String timeStr = json['time']?.toString() ?? '00:00:00';
        parsedDate = DateTime.parse('$dateStr $timeStr');
      }
    } catch (e) {
      print('Error parsing date: $e');
    }

    return Aim(
      id: json['id']?.toString() ?? '',
      title: json['event_title'],
      description: json['description'],
      progress: json['progress'],
      status: json['status'],
      eventDate: parsedDate,
      location: json['location']?.toString() ?? 'TBD',
      organizedClub: json['organized_club']?.toString() ?? 'Various',
      award: json['award'],
      time: json['time']?.toString() ?? 'TBD',
    );
  }
}

class StudentDashboard extends StatefulWidget {
  final int studentId;
  const StudentDashboard({super.key, required this.studentId});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _currentIndex = 0;
  List<Aim> _aims = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchAims();
  }

  Future<void> _fetchAims() async {
    const String url = 'https://campus-connect-p1ow.onrender.com/api/addevents';
    try {
      final response = await http.get(Uri.parse(url));
      if (!mounted) return;

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['events'] is List) {
          final now = DateTime.now();
          List<Aim> loadedAims = (data['events'] as List).map((json) {
            Aim aim = Aim.fromJson(json);
            
            String calculatedStatus = 'Upcoming';
            int calculatedProgress = 0;
            
            if (aim.eventDate.isBefore(now)) {
              calculatedStatus = 'Completed';
              calculatedProgress = 100;
            } else {
              final difference = aim.eventDate.difference(now).inDays;
              if (difference <= 7) {
                calculatedStatus = 'In Progress';
                calculatedProgress = 75;
              } else if (difference <= 30) {
                calculatedStatus = 'Upcoming';
                calculatedProgress = 25;
              }
            }
            
            return Aim(
              id: aim.id,
              title: aim.title,
              description: aim.description,
              progress: aim.progress ?? calculatedProgress,
              status: aim.status ?? calculatedStatus,
              eventDate: aim.eventDate,
              location: aim.location,
              organizedClub: aim.organizedClub,
              award: aim.award,
              time: aim.time,
            );
          }).toList();
          
          loadedAims.sort((a, b) => a.eventDate.compareTo(b.eventDate));
          
          setState(() {
            _aims = loadedAims;
            _isLoading = false;
          });
        } else {
          _errorMessage = 'Invalid data format from server.';
        }
      } else {
        _errorMessage = 'Failed to load events. Status: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Failed to connect to the server.\nError: $e';
    }
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildHomeContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF)));
    }
    if (_errorMessage.isNotEmpty) {
      return Center(
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
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _fetchAims,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text('Retry', style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        ),
      );
    }
    
    if (_aims.isEmpty) {
      return const Center(child: Text('No events found.', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)));
    }

    return RefreshIndicator(
      onRefresh: _fetchAims,
      color: const Color(0xFF6C63FF),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Home",
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1E293B),
                      letterSpacing: -1,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Upcoming Campus Events",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black45,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: AimCard(aim: _aims[index], studentId: widget.studentId),
                  );
                },
                childCount: _aims.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)), // Space for bottom nav
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      _buildHomeContent(),
      const ClubDirectoryPage(),
      MyResponsesPage(studentId: widget.studentId),
      StudentProfilePage(studentId: widget.studentId),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC), // Consistent pastel background
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: _currentIndex,
          children: screens,
        ),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: const Color(0xFF6C63FF),
            unselectedItemColor: const Color(0xFF94A3B8),
            showSelectedLabels: true,
            showUnselectedLabels: false,
            elevation: 0,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                activeIcon: Icon(Icons.home_rounded, size: 28),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.groups_rounded),
                activeIcon: Icon(Icons.groups_rounded, size: 28),
                label: 'Clubs',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.event_note_rounded),
                activeIcon: Icon(Icons.event_note_rounded, size: 28),
                label: 'Events',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded),
                activeIcon: Icon(Icons.person_rounded, size: 28),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AimCard extends StatelessWidget {
  final Aim aim;
  final int studentId;

  const AimCard({Key? key, required this.aim, required this.studentId}) : super(key: key);

  Color _getStatusColor(String status) {
    if (status == 'Completed') return const Color(0xFFDCFCE7); // Light Green
    if (status == 'In Progress') return const Color(0xFFE0F2FE); // Light Blue
    return const Color(0xFFFEF3C7); // Light Amber
  }

  Color _getStatusTextColor(String status) {
    if (status == 'Completed') return const Color(0xFF15803D); // Dark Green
    if (status == 'In Progress') return const Color(0xFF0369A1); // Dark Blue
    return const Color(0xFFB45309); // Dark Amber
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(aim.status ?? 'Upcoming');
    final statusTextColor = _getStatusTextColor(aim.status ?? 'Upcoming');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => clgeventsDetailsPage(aim: aim, studentId: studentId),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        (aim.status ?? 'Upcoming').toUpperCase(),
                        style: TextStyle(
                          color: statusTextColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFCBD5E1), size: 16),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  aim.title ?? 'No Title',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1E293B),
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  aim.description ?? 'No Description',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 24),
                
                // Progress Bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Timeline Progress',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                        Text(
                          '${aim.progress ?? 0}%',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF6C63FF),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: (aim.progress ?? 0) / 100,
                        backgroundColor: const Color(0xFFF1F5F9),
                        color: const Color(0xFF6C63FF),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                const SizedBox(height: 16),
                
                // Bottom Info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_month_rounded, size: 16, color: Color(0xFF0EA5E9)),
                        const SizedBox(width: 6),
                        Text(
                          DateFormat('MMM d, yyyy').format(aim.eventDate),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.apartment_rounded, size: 16, color: Color(0xFFFF6584)),
                        const SizedBox(width: 6),
                        Text(
                          aim.organizedClub,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

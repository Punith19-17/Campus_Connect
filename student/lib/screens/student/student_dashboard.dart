import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

import 'clg_events_details.dart';
import 'Student_login.dart';
import 'club_list.dart';
import 'myresponsespage.dart';
import 'profile_page.dart';

// ----------------- MODEL -----------------
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

  static String _getStatusFromDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDay = DateTime(date.year, date.month, date.day);

    if (eventDay == today) {
      return 'Today';
    } else if (eventDay.isAfter(today)) {
      final difference = eventDay.difference(today).inDays;
      if (difference == 1) {
        return 'Tomorrow';
      } else if (difference < 7) {
        return DateFormat('EEEE').format(date);
      } else {
        return DateFormat('MMM d, yyyy').format(date);
      }
    } else {
      final difference = today.difference(eventDay).inDays;
      if (difference == 1) {
        return 'Yesterday';
      } else if (difference < 7) {
        return DateFormat('EEEE').format(date);
      } else {
        return 'Completed';
      }
    }
  }

  static String _formatTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return 'N/A';
    try {
      final parts = timeStr.split(':');
      final hour = int.parse(parts[0]);
      final minute = parts.length > 1 ? parts[1] : '00';
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$displayHour:$minute $period';
    } catch (e) {
      return timeStr;
    }
  }

  factory Aim.fromJson(Map<String, dynamic> json) {
    DateTime eventDate =
        (DateTime.tryParse(json['date'] ?? '') ?? DateTime.now()).toLocal();

    int progressValue;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDay = DateTime(eventDate.year, eventDate.month, eventDate.day);

    if (eventDay.isBefore(today)) {
      progressValue = 100;
    } else if (eventDay.isAfter(today)) {
      progressValue = 0;
    } else {
      final currentHour = now.hour;
      if (currentHour < 10) {
        progressValue = 30;
      } else if (currentHour < 12) {
        progressValue = 50;
      } else if (currentHour < 15) {
        progressValue = 70;
      } else if (currentHour < 18) {
        progressValue = 85;
      } else {
        progressValue = 95;
      }
    }

    return Aim(
      id: (json['id'] ?? 0).toString(),
      title: json['event_title'] ?? 'No Title',
      description: json['description'] ?? 'No Description',
      progress: progressValue,
      status: _getStatusFromDate(eventDate),
      eventDate: eventDate,
      location: json['location'] ?? 'No Location',
      organizedClub: json['organized_club']?.toString() ?? 'N/A',
      award: json['award'],
      time: _formatTime(json['time']),
    );
  }
}

// ----------------- DASHBOARD -----------------
class StudentDashboard extends StatefulWidget {
  final int studentId;
  const StudentDashboard({super.key, required this.studentId});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  List<Aim> _aims = [];
  bool _isLoading = true;
  String _errorMessage = '';
  int _selectedIndex = 0;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      _HomePage(
          aims: _aims, isLoading: _isLoading, errorMessage: _errorMessage),
      const ClubDirectoryPage(),
      MyResponsesPage(studentId: widget.studentId),
      StudentProfilePage(studentId: widget.studentId),
    ];
    _fetchAims();
  }

  Future<void> _fetchAims() async {
    const String url =
        'https://campus-connect-p1ow.onrender.com/api/addevents/collegefunctions';
    try {
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = json.decode(response.body);

        if (decoded['success'] == true && decoded['events'] is List) {
          List<Aim> loadedAims = (decoded['events'] as List)
              .map((data) => Aim.fromJson(data as Map<String, dynamic>))
              .toList();

          loadedAims =
              loadedAims.where((aim) => (aim.progress ?? 0) < 100).toList();

          loadedAims.sort((a, b) {
            int getPriority(Aim aim) {
              if (aim.status == 'Today') return 1;
              if (aim.status == 'Tomorrow') return 2;
              if (aim.progress != 100) return 3;
              return 4;
            }

            int priorityA = getPriority(a);
            int priorityB = getPriority(b);

            if (priorityA != priorityB) {
              return priorityA.compareTo(priorityB);
            }

            return a.eventDate.compareTo(b.eventDate);
          });

          setState(() {
            _aims = loadedAims;
          });
        } else {
          setState(() {
            _errorMessage = 'Invalid response format from server.';
          });
        }
      } else {
        setState(() {
          _errorMessage =
              'Failed to load events. Status: ${response.statusCode}';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage =
              'Failed to connect to the server.\nPlease check your connection.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _pages[0] = _HomePage(
              aims: _aims,
              isLoading: _isLoading,
              errorMessage: _errorMessage);
        });
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFF), // Soft background
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: AppBar(
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
              )
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1E293B)),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const AuthScreen(),
                ),
              );
            },
          ),
        ),
        title: const Text('Campus Connect',
            style: TextStyle(
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E293B),
                letterSpacing: 0.5)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                )
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.notifications_none_rounded, color: Color(0xFF1E293B)),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4A90E2).withOpacity(0.15),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
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
                  icon: Icon(Icons.edit_note_rounded),
                  activeIcon: Icon(Icons.edit_note_rounded, size: 28),
                  label: 'Responses',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_rounded),
                  activeIcon: Icon(Icons.person_rounded, size: 28),
                  label: 'Profile',
                ),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: const Color(0xFF6C63FF),
              unselectedItemColor: const Color(0xFF94A3B8),
              showSelectedLabels: true,
              showUnselectedLabels: false,
              onTap: _onItemTapped,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ),
      ),
    );
  }
}

// ----------------- EVENT CARD -----------------
class AimCard extends StatefulWidget {
  final Aim aim;
  const AimCard({super.key, required this.aim});

  @override
  State<AimCard> createState() => _AimCardState();
}

class _AimCardState extends State<AimCard> with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Today':
        return const Color(0xFFE0F2FE);
      case 'Tomorrow':
        return const Color(0xFFFEF3C7);
      case 'Yesterday':
        return const Color(0xFFFCE7F3);
      case 'Completed':
        return const Color(0xFFDCFCE7);
      default:
        return const Color(0xFFF3E8FF);
    }
  }

  Color _getStatusTextColor(String? status) {
    switch (status) {
      case 'Today':
        return const Color(0xFF0284C7);
      case 'Tomorrow':
        return const Color(0xFFD97706);
      case 'Yesterday':
        return const Color(0xFFDB2777);
      case 'Completed':
        return const Color(0xFF16A34A);
      default:
        return const Color(0xFF9333EA);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => clgeventsDetailsPage(event: widget.aim),
          ),
        );
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6C63FF).withOpacity(0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                const Color(0xFFF8FAFC),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.event_available_rounded,
                              color: const Color(0xFF6C63FF),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              widget.aim.title ?? '',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1E293B),
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 6.0),
                      decoration: BoxDecoration(
                        color: _getStatusColor(widget.aim.status),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        widget.aim.status?.toUpperCase() ?? '',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: _getStatusTextColor(widget.aim.status),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  widget.aim.description ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 20),
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
                      '${widget.aim.progress ?? 0}%',
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
                    value: (widget.aim.progress ?? 0) / 100,
                    backgroundColor: const Color(0xFFF1F5F9),
                    color: const Color(0xFF6C63FF),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ----------------- HOME PAGE -----------------
class _HomePage extends StatelessWidget {
  final List<Aim> aims;
  final bool isLoading;
  final String errorMessage;

  const _HomePage({
    required this.aims,
    required this.isLoading,
    required this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: Color(0xFF6C63FF)));
    }

    if (errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded,
                  color: Colors.redAccent, size: 48),
              const SizedBox(height: 16),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.redAccent, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
    }

    if (aims.isEmpty) {
      return const Center(
        child: Text(
          'No college functions are scheduled at this time.',
          style: TextStyle(
              fontSize: 16,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w600),
        ),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 110.0, 20.0, 100.0), // Top padding for AppBar, Bottom for Nav
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                  )
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.school_rounded, size: 24, color: Color(0xFF6C63FF)),
                  SizedBox(width: 10),
                  Text(
                    'College Functions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: aims.length,
              itemBuilder: (context, index) {
                final aim = aims[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: AimCard(aim: aim),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

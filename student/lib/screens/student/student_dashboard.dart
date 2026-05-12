import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:ui'; // For BackdropFilter

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
      _HomePage(aims: _aims, isLoading: _isLoading, errorMessage: _errorMessage),
      const ClubDirectoryPage(),
      MyResponsesPage(studentId: widget.studentId),
      StudentProfilePage(studentId: widget.studentId),
    ];
    _fetchAims();
  }

  Future<void> _fetchAims() async {
    const String url = 'https://campus-connect-p1ow.onrender.com/api/addevents/collegefunctions';
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

          loadedAims = loadedAims.where((aim) => (aim.progress ?? 0) < 100).toList();

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
          _errorMessage = 'Failed to load events. Status: ${response.statusCode}';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to connect to the server.\nPlease check your connection.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _pages[0] = _HomePage(aims: _aims, isLoading: _isLoading, errorMessage: _errorMessage);
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
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFE0F2FE), // Very light Sky Blue
            Color(0xFFF0FDF4), // Very light Green
            Color(0xFFFFF1F2), // Very light Rose
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent, // Let gradient show
        extendBody: true, // Crucial for floating nav bar
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B)),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const AuthScreen(),
                ),
              );
            },
          ),
          title: const Text(
            'AIMS',
            style: TextStyle(
              color: Color(0xFF1E293B),
              fontWeight: FontWeight.w900,
              fontSize: 22,
              letterSpacing: -0.5,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: _pages[_selectedIndex],
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: _StudentGlassContainer(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              selectedItemColor: const Color(0xFF0EA5E9), // Vibrant Sky Blue
              unselectedItemColor: const Color(0xFF94A3B8),
              onTap: _onItemTapped,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              showUnselectedLabels: false,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
            ),
          ),
        ),
      ),
    );
  }
}

// ----------------- EVENT CARD -----------------
class AimCard extends StatelessWidget {
  final Aim aim;
  const AimCard({super.key, required this.aim});

  Map<String, dynamic> _getStatusConfig(String? status) {
    switch (status) {
      case 'Today':
        return {'color': const Color(0xFFF59E0B), 'icon': Icons.bolt_rounded}; // Amber
      case 'Tomorrow':
        return {'color': const Color(0xFFF43F5E), 'icon': Icons.update_rounded}; // Rose
      case 'Completed':
        return {'color': const Color(0xFF10B981), 'icon': Icons.check_circle_rounded}; // Emerald
      default:
        return {'color': const Color(0xFF8B5CF6), 'icon': Icons.event_rounded}; // Purple
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusConfig = _getStatusConfig(aim.status);
    final double progressRatio = (aim.progress ?? 0) / 100.0;
    final bool isCompleted = progressRatio >= 1.0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => clgeventsDetailsPage(event: aim),
          ),
        );
      },
      child: _StudentGlassContainer(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isCompleted ? const Color(0xFF10B981).withOpacity(0.15) : const Color(0xFF0EA5E9).withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isCompleted ? Icons.check_circle_rounded : Icons.star_rounded,
                          color: isCompleted ? const Color(0xFF10B981) : const Color(0xFF0EA5E9),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              aim.title ?? '',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF1E293B),
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              aim.organizedClub,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (aim.status != null && aim.status!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusConfig['color'].withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusConfig['color'].withOpacity(0.3), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusConfig['icon'], size: 14, color: statusConfig['color']),
                        const SizedBox(width: 4),
                        Text(
                          aim.status!,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: statusConfig['color'],
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              aim.description ?? '',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF475569),
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
                  'Event Timeline',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF94A3B8),
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  '${aim.progress ?? 0}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: isCompleted ? const Color(0xFF10B981) : const Color(0xFF0EA5E9),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progressRatio,
                backgroundColor: Colors.white.withOpacity(0.5),
                valueColor: AlwaysStoppedAnimation<Color>(
                  isCompleted ? const Color(0xFF10B981) : const Color(0xFF0EA5E9),
                ),
                minHeight: 8,
              ),
            ),
          ],
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
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Discover",
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1E293B),
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "College Functions & Events",
                  style: TextStyle(
                    fontSize: 16,
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 24),
                _buildContent(),
                const SizedBox(height: 80), // Space for bottom nav bar
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: CircularProgressIndicator(color: Color(0xFF0EA5E9)),
        ),
      );
    }

    if (errorMessage.isNotEmpty) {
      return _StudentGlassContainer(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    if (aims.isEmpty) {
      return _StudentGlassContainer(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: const [
            Icon(Icons.event_busy_rounded, color: Color(0xFF94A3B8), size: 64),
            SizedBox(height: 16),
            Text(
              'No college functions are scheduled right now.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w700, fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Check back later!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: aims.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: AimCard(aim: aims[index]),
        );
      },
    );
  }
}

/// A reusable vibrant frosted glass container for the Student Module
class _StudentGlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const _StudentGlassContainer({required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: padding ?? const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.55), // More opaque white for vibrant brightness
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0EA5E9).withOpacity(0.05), // Soft sky blue shadow
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

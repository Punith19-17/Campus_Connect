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
        // Events that have passed are marked as 'Completed' and will be filtered out.
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
    const String url = 'http://10.0.2.2:5000/api/addevents/collegefunctions';
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

          // FIX: Filter out events where progress is 100% (completed/past)
          loadedAims = loadedAims.where((aim) => (aim.progress ?? 0) < 100).toList();

          loadedAims.sort((a, b) {
            int getPriority(Aim aim) {
              if (aim.status == 'Today') return 1; // Highest priority
              if (aim.status == 'Tomorrow') return 2;
              if (aim.progress != 100) return 3; // All other upcoming
              return 4; // Fallback (shouldn't be hit now due to filter)
            }

            int priorityA = getPriority(a);
            int priorityB = getPriority(b);

            if (priorityA != priorityB) {
              return priorityA.compareTo(priorityB);
            }

            // Secondary sort by date (ascending)
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const AuthScreen(),
              ),
            );
          },
        ),
        title: const Text('AIMS',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,

      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Clubs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_note),
            label: 'My Responses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
      ),
    );
  }
}

// ----------------- EVENT CARD -----------------
class AimCard extends StatelessWidget {
  final Aim aim;
  const AimCard({super.key, required this.aim});

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Today':
        return Colors.blue[200]!;
      case 'Tomorrow':
        return Colors.orange[200]!;
      case 'Yesterday':
        return Colors.pink[200]!;
      case 'Completed':
        return Colors.green[200]!;
      default:
        return Colors.green[200]!;
    }
  }

  Color _getIconColor(int? progress) {
    return (progress ?? 0) >= 100 ? Colors.green : Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => clgeventsDetailsPage(event: aim),
          ),
        );
      },
      child: Card(
        elevation: 4,
        color: const Color(0xFFF0F6FC),
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          (aim.progress ?? 0) >= 100
                              ? Icons.check_circle_outline
                              : Icons.circle_outlined,
                          color: _getIconColor(aim.progress),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            aim.title ?? '',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: _getStatusColor(aim.status),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      aim.status ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                aim.description ?? '',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Progress',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: (aim.progress ?? 0) / 100,
                backgroundColor: Colors.grey[300],
                color: Colors.black,
                borderRadius: BorderRadius.circular(10),
              ),
              const SizedBox(height: 4),
              Text(
                '${aim.progress ?? 0}%',
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
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
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red, fontSize: 16),
          ),
        ),
      );
    }

    if (aims.isEmpty) {
      return const Center(
        child: Text(
          'No college functions are scheduled at this time.',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.school, size: 24, color: Colors.black87),
              SizedBox(width: 8),
              Text(
                'College Functions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: aims.length,
            itemBuilder: (context, index) {
              final aim = aims[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: AimCard(aim: aim),
              );
            },
          ),
        ],
      ),
    );
  }
}
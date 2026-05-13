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
      backgroundColor: const Color(0xFFF5F8FE), // Clean light icy background
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: Stack(
        children: [
          // The beautiful curved light gradient header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 280,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFFF1EB), Color(0xFFACE0F9)], // Soft Peach to Light Blue
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFFACE0F9),
                    blurRadius: 30,
                    offset: Offset(0, 10),
                    spreadRadius: -10,
                  )
                ],
              ),
            ),
          ),

          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Custom App Bar Area
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AuthScreen(),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              )
                            ],
                          ),
                          child: const Icon(Icons.arrow_back_rounded, color: Color(0xFF4A5568), size: 20),
                        ),
                      ),
                      const Text(
                        'AIMS',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF2D3748),
                          fontSize: 22,
                          letterSpacing: 2.0,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            )
                          ],
                        ),
                        child: const Icon(Icons.notifications_active_rounded, color: Color(0xFF4A5568), size: 20),
                      ),
                    ],
                  ),
                ),

                // Active Page (Expands)
                Expanded(
                  child: _pages[_selectedIndex],
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8EC5FC).withOpacity(0.3),
                blurRadius: 30,
                offset: const Offset(0, 15),
                spreadRadius: -10,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
                BottomNavigationBarItem(icon: Icon(Icons.groups_rounded), label: 'Clubs'),
                BottomNavigationBarItem(icon: Icon(Icons.edit_note_rounded), label: 'Responses'),
                BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: const Color(0xFF6C63FF), // Vibrant indigo accent
              unselectedItemColor: const Color(0xFFA0AEC0),
              showSelectedLabels: true,
              showUnselectedLabels: false,
              onTap: _onItemTapped,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              elevation: 0,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
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
  final int index;
  const AimCard({super.key, required this.aim, required this.index});

  @override
  State<AimCard> createState() => _AimCardState();
}

class _AimCardState extends State<AimCard> with SingleTickerProviderStateMixin {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    // Entrance Animation setup
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + (widget.index * 100)),
      curve: Curves.easeOutCubic,
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isHovered = true),
        onTapUp: (_) => setState(() => _isHovered = false),
        onTapCancel: () => setState(() => _isHovered = false),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => clgeventsDetailsPage(event: widget.aim),
            ),
          );
        },
        child: AnimatedScale(
          scale: _isHovered ? 0.95 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              // Asymmetrical unique layout
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
                topRight: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFACE0F9).withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFE0C3FC), Color(0xFF8EC5FC)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.event_note_rounded, color: Colors.white, size: 24),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F8FE),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.aim.status?.toUpperCase() ?? '',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF4A5568),
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    widget.aim.title ?? '',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF2D3748),
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.aim.description ?? '',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF718096),
                      height: 1.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'PROGRESS',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFA0AEC0),
                          letterSpacing: 1.0,
                        ),
                      ),
                      Text(
                        '${widget.aim.progress ?? 0}%',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF6C63FF),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F8FE),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: widget.aim.progress ?? 0,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFACE0F9), Color(0xFF6C63FF)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 100 - (widget.aim.progress ?? 0),
                          child: const SizedBox(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
      return const Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF)));
    }

    if (errorMessage.isNotEmpty) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.redAccent.withOpacity(0.1),
                blurRadius: 20,
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
        ),
      );
    }

    if (aims.isEmpty) {
      return const Center(
        child: Text(
          'No college functions are scheduled at this time.',
          style: TextStyle(fontSize: 16, color: Color(0xFF718096), fontWeight: FontWeight.w600),
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24.0, 10.0, 24.0, 120.0), // Padding for Nav
      itemCount: aims.length + 1, // +1 for the header text
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 32.0, top: 16.0),
            child: TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              builder: (context, double value, child) {
                return Opacity(
                  opacity: value,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Upcoming Events',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF2D3748),
                          letterSpacing: -1.0,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Explore what\'s happening on campus',
                        style: TextStyle(
                          fontSize: 16,
                          color: const Color(0xFF4A5568).withOpacity(0.8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        }
        final aim = aims[index - 1];
        return Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: AimCard(aim: aim, index: index),
        );
      },
    );
  }
}

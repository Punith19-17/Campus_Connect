import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'myresponsespage.dart'; // for Event model
import 'participate.dart'; // Import the ParticipatePage

class EventDetailsPage extends StatefulWidget {
  final int eventId;
  final int studentId;

  const EventDetailsPage({
    super.key,
    required this.eventId,
    required this.studentId,
  });

  @override
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  bool _isInterested = false;
  bool _isLoading = true;
  String? _errorMessage;
  Event? _event;

  @override
  void initState() {
    super.initState();
    _fetchEventDetails();
  }

  Future<void> _fetchEventDetails() async {
    const String baseUrl = 'https://campus-connect-p1ow.onrender.com';
    final String url = '$baseUrl/api/addevents/${widget.eventId}';
    final String likeStatusUrl =
        '$baseUrl/api/addevents/like/status?eventId=${widget.eventId}&studentId=${widget.studentId}';

    try {
      final responses = await Future.wait([
        http.get(Uri.parse(url)),
        http.get(Uri.parse(likeStatusUrl)),
      ]);

      final eventResponse = responses[0];
      final likeResponse = responses[1];

      if (eventResponse.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(eventResponse.body);
        if (data['success'] == true && data['event'] != null) {
          _event = Event.fromJson(data['event']);
        } else {
          _errorMessage = 'Event details not found.';
        }
      } else {
        _errorMessage = 'Failed to load event details. Status: ${eventResponse.statusCode}';
      }

      if (likeResponse.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(likeResponse.body);
        if (data['success'] == true) {
          _isInterested = data['isLiked'] ?? false;
        }
      }
    } catch (e) {
      _errorMessage = 'Failed to connect to the server.\nError: $e';
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleLike() async {
    setState(() {
      _isInterested = !_isInterested;
    });

    try {
      const String baseUrl = 'https://campus-connect-p1ow.onrender.com';
      final String url = _isInterested
          ? '$baseUrl/api/addevents/like'
          : '$baseUrl/api/addevents/unlike';

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'eventId': widget.eventId,
          'studentId': widget.studentId,
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        setState(() {
          _isInterested = !_isInterested;
        });
        if (!mounted) return;
        _showModernSnackBar('Failed to update interest status.', Colors.redAccent);
      }
    } catch (e) {
      setState(() {
        _isInterested = !_isInterested;
      });
      if (!mounted) return;
      _showModernSnackBar('Error: ${e.toString()}', Colors.redAccent);
    }
  }

  void _showModernSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF0EA5E9))),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 64),
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final event = _event!;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B), size: 18),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        title: const Text(
          'Event Details',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Immersive Header Area
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 120, 24, 40),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF38BDF8), // Vibrant Sky Blue
                    Color(0xFF818CF8), // Indigo
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_month_rounded, color: Colors.white, size: 14),
                            const SizedBox(width: 6),
                            Text(
                              event.formattedDate,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: _toggleLike,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _isInterested ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            color: _isInterested ? const Color(0xFFF43F5E) : Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            
            // Content Area
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'About This Event',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    event.description,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF475569),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  const Text(
                    'Event Details',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Detail Glass Cards
                  _buildDetailCard(
                    icon: Icons.calendar_month_rounded,
                    title: 'Date',
                    subtitle: event.formattedDate,
                    color: const Color(0xFF38BDF8),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailCard(
                    icon: Icons.access_time_rounded,
                    title: 'Time',
                    subtitle: event.time,
                    color: const Color(0xFF8B5CF6),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailCard(
                    icon: Icons.location_on_rounded,
                    title: 'Location',
                    subtitle: event.location,
                    color: const Color(0xFF10B981),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailCard(
                    icon: Icons.business_rounded,
                    title: 'Organized By',
                    subtitle: event.club,
                    color: const Color(0xFFEC4899),
                  ),
                  
                  if (event.award.isNotEmpty) ...[
                    const SizedBox(height: 32),
                    const Text(
                      'Prizes & Awards',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailCard(
                      icon: Icons.emoji_events_rounded,
                      title: 'Award',
                      subtitle: event.award,
                      color: const Color(0xFFF59E0B),
                    ),
                  ],
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF38BDF8), Color(0xFF818CF8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF38BDF8).withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ParticipatePage(eventName: event.title),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              minimumSize: const Size(double.infinity, 56),
            ),
            child: const Text(
              'Join Event',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailCard({required IconData icon, required String title, required String subtitle, required Color color}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

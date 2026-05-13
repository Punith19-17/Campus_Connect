import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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

class _EventDetailsPageState extends State<EventDetailsPage> with SingleTickerProviderStateMixin {
  bool _isInterested = false;
  bool _isLoading = true;
  String? _errorMessage;
  Event? _event;

  late AnimationController _heartAnimationController;

  @override
  void initState() {
    super.initState();
    _heartAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      lowerBound: 0.8,
      upperBound: 1.2,
    );
    _fetchEventDetails();
  }

  @override
  void dispose() {
    _heartAnimationController.dispose();
    super.dispose();
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
        _errorMessage =
            'Failed to load event details. Status: ${eventResponse.statusCode}';
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
    _heartAnimationController.forward().then((_) {
      _heartAnimationController.reverse();
    });

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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update interest status.')),
        );
      }
    } catch (e) {
      setState(() {
        _isInterested = !_isInterested;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFFAFBFF),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF))),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFFAFBFF),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48),
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final event = _event!;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFF),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
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
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
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
              icon: Icon(
                Icons.share_rounded,
                color: const Color(0xFF1E293B),
              ),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image / Gradient Header
            Container(
              width: double.infinity,
              height: 260,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF4A90E2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -50,
                    top: -50,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ),
                  Positioned(
                    left: -30,
                    bottom: -30,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content Body Overlapping the Header
            Transform.translate(
              offset: const Offset(0, -40),
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFFAFBFF),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and Like Button
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              event.title,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF1E293B),
                                height: 1.2,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: _toggleLike,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: _isInterested ? const Color(0xFFFEE2E2) : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  )
                                ],
                              ),
                              child: Row(
                                children: [
                                  ScaleTransition(
                                    scale: _heartAnimationController,
                                    child: Icon(
                                      _isInterested ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                      color: _isInterested ? const Color(0xFFEF4444) : const Color(0xFF94A3B8),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _isInterested ? 'Interested' : 'Interest',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: _isInterested ? const Color(0xFFEF4444) : const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Bento Grid Info Cards
                      Row(
                        children: [
                          Expanded(child: _buildBentoCard(Icons.calendar_month_rounded, 'Date', event.formattedDate, const Color(0xFF0EA5E9), const Color(0xFFE0F2FE))),
                          const SizedBox(width: 16),
                          Expanded(child: _buildBentoCard(Icons.access_time_rounded, 'Time', event.time, const Color(0xFF8B5CF6), const Color(0xFFEDE9FE))),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildBentoCard(Icons.location_on_rounded, 'Location', event.location, const Color(0xFF10B981), const Color(0xFFD1FAE5))),
                          const SizedBox(width: 16),
                          Expanded(child: _buildBentoCard(Icons.apartment_rounded, 'Club', event.club, const Color(0xFFF59E0B), const Color(0xFFFEF3C7))),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // About Section
                      const Text(
                        'About This Event',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        event.description,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.6,
                          color: Color(0xFF475569),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Awards Section
                      if (event.award != null && event.award!.isNotEmpty) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFEF3C7), Color(0xFFFEF08A)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.emoji_events_rounded, color: Color(0xFFD97706), size: 28),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Prizes & Awards',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFFB45309),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      event.award!,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF92400E),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 100), // Space for floating button
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C63FF).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
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
            padding: EdgeInsets.zero,
          ),
          child: Ink(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF4A90E2)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Text(
                'Join Event',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBentoCard(IconData icon, String title, String subtitle, Color iconColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

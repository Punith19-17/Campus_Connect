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
    // NOTE: Hardcoded URL for local development/emulator access
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
          // Assuming Event.fromJson is correctly implemented in myresponsespage.dart
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
        // revert UI if API failed
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
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
          ),
        ),
      );
    }

    final event = _event!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Event Details',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          // ** ICON COLOR CHANGE 1: Back Button **
          icon: const Icon(Icons.arrow_back, color: Colors.blueGrey),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          event.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _toggleLike,
                        child: Row(
                          children: [
                            Text(
                              'Interested',
                              style: TextStyle(
                                fontSize: 16,
                                color: _isInterested
                                    ? Colors.red
                                    : Colors.grey[600], // Adjusted non-interested color
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              _isInterested
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              // ** ICON COLOR CHANGE 2: Interested Heart Icon **
                              color: _isInterested
                                  ? Colors.red
                                  : Colors.grey[600], // Adjusted non-interested color
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // ** ICON COLOR CHANGE 3: Header Date Icon **
                      const Icon(Icons.calendar_today,
                          size: 16, color: Colors.deepOrange),
                      const SizedBox(width: 8),
                      Text(
                        event.formattedDate,
                        style: const TextStyle(
                            fontSize: 14, color: Colors.black54),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildSectionTitle('About This Event'),
            _buildSectionText(event.description),
            const SizedBox(height: 24),
            _buildSectionTitle('Event Details'),
            // ** ICON COLOR CHANGE 4: Date Detail Card **
            _buildDetailCard(Icons.calendar_today_outlined,
                'Date', event.formattedDate, Colors.purple),
            // ** ICON COLOR CHANGE 5: Time Detail Card **
            _buildDetailCard(Icons.access_time, 'Time', event.time, Colors.teal),
            // ** ICON COLOR CHANGE 6: Location Detail Card **
            _buildDetailCard(
                Icons.location_on_outlined, 'Location', event.location, Colors.indigo),
            const SizedBox(height: 24),
            _buildSectionTitle('Organized By'),
            // ** ICON COLOR CHANGE 7: Club Detail Card **
            _buildDetailCard(Icons.apartment, 'Club', event.club, Colors.pink),
            const SizedBox(height: 24),
            _buildSectionTitle('Prizes & Awards'),
            // ** ICON COLOR CHANGE 8: Award Detail Card **
            _buildDetailCard(Icons.emoji_events_outlined,
                'Award', event.award, Colors.amber),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomSheet: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            // Navigate to the ParticipatePage and pass the event title
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ParticipatePage(eventName: event.title),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E88E5),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            minimumSize: const Size(double.infinity, 50),
          ),
          child: const Text(
            'Join Event',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding:
      const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildSectionText(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          height: 1.5,
          color: Colors.black54,
        ),
      ),
    );
  }

  // Modified to accept a Color parameter
  Widget _buildDetailCard(
      IconData icon, String title, String subtitle, Color iconColor) {
    return Padding(
      padding:
      const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.grey[100], // Changed background color for contrast
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Use the passed-in color for the icon
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'myresponsespage.dart'; // Ensure this points to the newly updated myresponsespage.dart where EventCard is.

class InterestedEventsPage extends StatefulWidget {
  final int studentId;
  const InterestedEventsPage({super.key, required this.studentId});

  @override
  State<InterestedEventsPage> createState() => _InterestedEventsPageState();
}

class _InterestedEventsPageState extends State<InterestedEventsPage> {
  List<Event> _interestedEvents = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchInterestedEvents();
  }

  Future<void> _fetchInterestedEvents() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final String url =
          'http://10.0.2.2:5000/api/addevents/interested/${widget.studentId}';
      final response = await http.get(Uri.parse(url));
      if (!mounted) return;

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final List eventsJson = jsonResponse['events'];
        final events = eventsJson.map((json) => Event.fromJson(json)).toList();
        setState(() {
          _interestedEvents = List<Event>.from(events);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load interested events');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Failed to load interested events. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC), // Matches the new MyResponsesPage background
      appBar: AppBar(
        title: const Text(
          'My Responses',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF)));
    }
    if (_error.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            _error,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
    if (_interestedEvents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: const Icon(
                Icons.event_busy_rounded,
                size: 80,
                color: Color(0xFFCBD5E1),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'No interested events yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Go back and explore club events\nto find something you like!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
                height: 1.5,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      itemCount: _interestedEvents.length,
      itemBuilder: (context, index) {
        final event = _interestedEvents[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: EventCard(event: event, studentId: widget.studentId),
        );
      },
    );
  }
}

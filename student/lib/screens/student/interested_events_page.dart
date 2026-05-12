import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:ui';
import 'event_details.dart'; // Make sure this points to the newly updated event_details.dart

// We need the Event model here.
class Event {
  final int id;
  final String title;
  final String description;
  final String date;
  final String location;
  final String club;
  final String award;
  final String time;
  final String originalDate;
  final String formattedDate;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    required this.club,
    required this.award,
    required this.time,
    required this.originalDate,
    required this.formattedDate,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    String rawDate = json['date']?.toString() ?? '';
    String displayDate = 'N/A';
    if (rawDate.isNotEmpty) {
      try {
        final parsed = DateTime.parse(rawDate);
        displayDate = '${parsed.month}/${parsed.day}/${parsed.year}';
      } catch (e) {
        displayDate = rawDate;
      }
    }

    return Event(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['event_title'] ?? 'No Title',
      description: json['description'] ?? '',
      date: displayDate,
      location: json['location'] ?? 'No Location',
      club: json['organized_club']?.toString() ?? 'N/A',
      award: json['award'] ?? '',
      time: json['time'] ?? 'N/A',
      originalDate: rawDate,
      formattedDate: displayDate,
    );
  }
}

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
          'https://campus-connect-p1ow.onrender.com/api/addevents/interested/${widget.studentId}';
      final response = await http.get(Uri.parse(url));
      if (!mounted) return;

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final List eventsJson = jsonResponse['events'] ?? [];
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
          'My Responses',
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Space
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 120, 24, 24),
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
              children: const [
                Text(
                  "Responses",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -1,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Events you are interested in",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF0EA5E9)));
    }
    if (_error.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _StudentGlassContainer(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48),
                const SizedBox(height: 16),
                Text(
                  _error,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _fetchInterestedEvents,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('Retry', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                )
              ],
            ),
          ),
        ),
      );
    }
    if (_interestedEvents.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _StudentGlassContainer(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.favorite_border_rounded, color: Color(0xFF94A3B8), size: 64),
                SizedBox(height: 16),
                Text(
                  'You haven\'t shown interest in any events yet.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w700, fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  'Explore the home tab to find events!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24.0),
      itemCount: _interestedEvents.length,
      itemBuilder: (context, index) {
        final event = _interestedEvents[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: EventCard(event: event, studentId: widget.studentId),
        );
      },
    );
  }
}

class EventCard extends StatelessWidget {
  final Event event;
  final int studentId;

  const EventCard({
    Key? key,
    required this.event,
    required this.studentId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailsPage(eventId: event.id, studentId: studentId),
          ),
        );
      },
      child: _StudentGlassContainer(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF43F5E).withOpacity(0.15), // Rose/Pink for favorite
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.favorite_rounded, color: Color(0xFFF43F5E), size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1E293B),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        event.club,
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
            const SizedBox(height: 16),
            const Divider(color: Colors.white, height: 1),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month_rounded, color: Color(0xFF38BDF8), size: 16),
                      const SizedBox(width: 6),
                      Text(
                        event.formattedDate,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.access_time_rounded, color: Color(0xFF8B5CF6), size: 16),
                      const SizedBox(width: 6),
                      Text(
                        event.time,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StudentGlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const _StudentGlassContainer({required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: padding ?? const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0EA5E9).withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

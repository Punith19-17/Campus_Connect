import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'event_details.dart';
import 'interested_events_page.dart';

// Event model
class Event {
  final int id;
  final String title;
  final String description;
  final DateTime eventDate;
  final String time;
  final String location;
  final String club;
  final String? imageUrl;
  final String eventType;
  final String award;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.eventDate,
    required this.time,
    required this.location,
    required this.club,
    this.imageUrl,
    required this.eventType,
    required this.award,
  });

  String get formattedDate => DateFormat('MMM d').format(eventDate);
  String get formattedTime => DateFormat('h:mm a').format(eventDate);

  String get dayStatus {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dayOfEvent = DateTime(eventDate.year, eventDate.month, eventDate.day);

    if (dayOfEvent == today) return 'Today';
    if (dayOfEvent == today.add(const Duration(days: 1))) return 'Tomorrow';
    if (dayOfEvent == today.subtract(const Duration(days: 1))) return 'Yesterday';
    return DateFormat('EEEE').format(eventDate);
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    final dateStr = json['date']?.toString().split('T')[0] ?? '';
    final timeStr = json['time']?.toString() ?? '00:00:00';
    final fullDateTimeStr = '$dateStr $timeStr';

    return Event(
      id: json['id'] ?? 0,
      title: json['event_title']?.toString() ?? 'No Title',
      description: json['description']?.toString() ?? 'No Description',
      eventDate: (DateTime.tryParse(fullDateTimeStr) ?? DateTime.now()).toLocal(),
      time: json['time']?.toString() ?? '',
      location: json['location']?.toString() ?? 'N/A',
      club: json['organized_club']?.toString() ?? 'N/A',
      imageUrl: json['pic']?.toString(),
      eventType: json['event_type']?.toString() ?? 'General',
      award: json['award']?.toString() ?? 'No Award',
    );
  }
}

class MyResponsesPage extends StatefulWidget {
  final int studentId; // ✅ take studentId dynamically
  const MyResponsesPage({super.key, required this.studentId});

  @override
  State<MyResponsesPage> createState() => _MyResponsesPageState();
}

class _MyResponsesPageState extends State<MyResponsesPage> {
  bool _isLoading = true;
  String _errorMessage = '';
  List<Event> _allEvents = [];
  List<Event> _filteredEvents = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    const String url = 'http://10.0.2.2:5000/api/addevents/club';
    try {
      final response = await http.get(Uri.parse(url));
      if (!mounted) return;

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['events'] is List) {
          final allApiEvents = (data['events'] as List)
              .map((eventJson) => Event.fromJson(eventJson))
              .toList();

          setState(() {
            _allEvents = allApiEvents;
            _filteredEvents = allApiEvents;
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

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _filterEvents();
    });
  }

  void _filterEvents({String? filterType}) {
    List<Event> tempEvents = _allEvents
        .where((event) =>
            event.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            event.club.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    if (filterType == 'by_name') {
      tempEvents.sort((a, b) => a.title.compareTo(b.title));
    } else if (filterType == 'by_date') {
      tempEvents.sort((a, b) => a.eventDate.compareTo(b.eventDate));
    }

    setState(() {
      _filteredEvents = tempEvents;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // A unique soft pastel background
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
            : _errorMessage.isNotEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        _errorMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.redAccent, fontSize: 16),
                      ),
                    ),
                  )
                : CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 32, 24, 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        'Campus Connect',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF6C63FF),
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Club Events',
                                        style: TextStyle(
                                          fontSize: 34,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFF1E293B),
                                        ),
                                      ),
                                    ],
                                  ),
                                  InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => InterestedEventsPage(
                                            studentId: widget.studentId,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFF6C63FF), Color(0xFFFF6584)],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF6C63FF).withOpacity(0.3),
                                            blurRadius: 12,
                                            offset: const Offset(0, 6),
                                          ),
                                        ],
                                      ),
                                      child: const Row(
                                        children: [
                                          Icon(Icons.bookmark_added_rounded, color: Colors.white, size: 18),
                                          SizedBox(width: 6),
                                          Text(
                                            'Responses',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 28),
                              
                              // Floating Search Bar Design
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: TextField(
                                  onChanged: _onSearchChanged,
                                  style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                                  decoration: const InputDecoration(
                                    hintText: 'Search for an event...',
                                    hintStyle: TextStyle(color: Colors.black38, fontSize: 15, fontWeight: FontWeight.w500),
                                    prefixIcon: Padding(
                                      padding: EdgeInsets.only(left: 16, right: 12),
                                      child: Icon(Icons.search_rounded, color: Color(0xFF6C63FF), size: 24),
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(vertical: 20),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              
                              Text(
                                '${_filteredEvents.length} events found',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black45,
                                ),
                              ),
                              const SizedBox(height: 16),
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
                                child: EventCard(
                                  event: _filteredEvents[index],
                                  studentId: widget.studentId, // ✅ pass studentId down
                                ),
                              );
                            },
                            childCount: _filteredEvents.length,
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 80)),
                    ],
                  ),
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  final Event event;
  final int studentId; // ✅ added

  const EventCard({Key? key, required this.event, required this.studentId}) : super(key: key);

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Today':
        return const Color(0xFFE0F2FE); // Light Blue
      case 'Tomorrow':
        return const Color(0xFFFEF3C7); // Light Amber
      case 'Yesterday':
        return const Color(0xFFFCE7F3); // Light Pink
      default:
        return const Color(0xFFDCFCE7); // Light Green
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status) {
      case 'Today':
        return const Color(0xFF0369A1); // Dark Blue
      case 'Tomorrow':
        return const Color(0xFFB45309); // Dark Amber
      case 'Yesterday':
        return const Color(0xFFBE185D); // Dark Pink
      default:
        return const Color(0xFF15803D); // Dark Green
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: () {
            // ✅ pass the REAL studentId
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EventDetailsPage(eventId: event.id, studentId: studentId),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _getStatusColor(event.dayStatus),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              event.dayStatus.toUpperCase(),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: _getStatusTextColor(event.dayStatus),
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            event.title,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1E293B),
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F9FC),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Color(0xFF6C63FF),
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  event.description,
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
                
                // Bottom Info Row
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.apartment_rounded, size: 18, color: Color(0xFF0EA5E9)), // Cyan
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              event.club,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1E293B),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Row(
                      children: [
                        const Icon(Icons.access_time_filled_rounded, size: 18, color: Color(0xFFFF6584)), // Pink
                        const SizedBox(width: 8),
                        Text(
                          event.formattedTime,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
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

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'eventdetails.dart';
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
  final int studentId;
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
    const String url = 'https://campus-connect-p1ow.onrender.com/api/addevents/club';
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
      backgroundColor: Colors.transparent, // Inherits from dashboard background
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
          : _errorMessage.isNotEmpty
              ? Center(
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
                          _errorMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                )
              : CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Club Events',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF2D3748),
                                    letterSpacing: -1.0,
                                  ),
                                ),
                                GestureDetector(
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
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFFACE0F9), Color(0xFFE0C3FC)], // Ice Blue to Lilac
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF8EC5FC).withOpacity(0.4),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: const Text(
                                      'Responses',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${_filteredEvents.length} events found',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFA0AEC0),
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Modern Search Bar
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  )
                                ],
                              ),
                              child: TextField(
                                onChanged: _onSearchChanged,
                                decoration: InputDecoration(
                                  hintText: 'Search events or clubs...',
                                  hintStyle: const TextStyle(color: Color(0xFFA0AEC0), fontWeight: FontWeight.w600),
                                  prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF6C63FF)),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return EventCard(
                              event: _filteredEvents[index],
                              studentId: widget.studentId,
                              index: index,
                            );
                          },
                          childCount: _filteredEvents.length,
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}

class EventCard extends StatefulWidget {
  final Event event;
  final int studentId;
  final int index;

  const EventCard({
    super.key,
    required this.event,
    required this.studentId,
    required this.index,
  });

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  bool _isHovered = false;

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Today':
        return const Color(0xFFEBF8FF); // Light Blue
      case 'Tomorrow':
        return const Color(0xFFFFFFF0); // Light Yellow
      case 'Yesterday':
        return const Color(0xFFFFF5F5); // Light Red
      default:
        return const Color(0xFFF0FFF4); // Light Green
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status) {
      case 'Today':
        return const Color(0xFF3182CE);
      case 'Tomorrow':
        return const Color(0xFFD69E2E);
      case 'Yesterday':
        return const Color(0xFFE53E3E);
      default:
        return const Color(0xFF38A169);
    }
  }

  @override
  Widget build(BuildContext context) {
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
              builder: (context) =>
                  EventDetailsPage(eventId: widget.event.id, studentId: widget.studentId),
            ),
          );
        },
        child: AnimatedScale(
          scale: _isHovered ? 0.95 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: Container(
            margin: const EdgeInsets.only(bottom: 20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8EC5FC).withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFA1C4FD), Color(0xFFC2E9FB)], // Fresh Sky Blue
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.celebration_rounded, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.event.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF2D3748),
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              widget.event.club,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF6C63FF),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getStatusColor(widget.event.dayStatus),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.event.dayStatus,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: _getStatusTextColor(widget.event.dayStatus),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.event.description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF718096),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F8FE),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildInfoItem(Icons.calendar_month_rounded, widget.event.formattedDate),
                        _buildInfoItem(Icons.access_time_rounded, widget.event.formattedTime),
                        _buildInfoItem(Icons.location_on_rounded, widget.event.location),
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

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: const Color(0xFFA0AEC0)),
        const SizedBox(width: 4),
        Text(
          text.length > 8 ? '${text.substring(0, 8)}...' : text, // Truncate long locations
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF4A5568),
          ),
        ),
      ],
    );
  }
}

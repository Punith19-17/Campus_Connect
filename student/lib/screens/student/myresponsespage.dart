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
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _errorMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red, fontSize: 16),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Club Events',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InterestedEventsPage(
                          studentId: widget.studentId,
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'My Responses',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              '${_filteredEvents.length} events found',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: 'Search events...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onChanged: _onSearchChanged,
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _filteredEvents.length,
              itemBuilder: (context, index) {
                return EventCard(
                  event: _filteredEvents[index],
                  studentId: widget.studentId, // ✅ pass studentId down
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  final Event event;
  final int studentId; // ✅ added

  const EventCard({Key? key, required this.event, required this.studentId})
      : super(key: key);

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Today':
        return Colors.blue[100]!;
      case 'Tomorrow':
        return Colors.orange[100]!;
      case 'Yesterday':
        return Colors.pink[100]!;
      default:
        return Colors.green[100]!;
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status) {
      case 'Today':
        return Colors.blue[800]!;
      case 'Tomorrow':
        return Colors.orange[800]!;
      case 'Yesterday':
        return Colors.pink[800]!;
      default:
        return Colors.green[800]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // ✅ pass the REAL studentId
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                EventDetailsPage(eventId: event.id, studentId: studentId),
          ),
        );
      },
      child: Card(
        elevation: 2,
        color: const Color(0xFFF0F6FC),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        margin: const EdgeInsets.only(bottom: 16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image section has been removed
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold), // Increased font size
                    ),
                    const SizedBox(height: 8),
                    Text(
                      event.description, // Added description back
                      style: TextStyle(
                          fontSize: 14, color: Colors.grey[600]), // Increased font size
                    ),
                    const SizedBox(height: 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              size: 16, color: Colors.blue), // Changed color to blue
                          const SizedBox(width: 4),
                          Text(
                            event.formattedDate,
                            style: const TextStyle(
                                fontSize: 14, color: Colors.grey), // Increased font size
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.access_time,
                              size: 16, color: Colors.orange), // Changed color to orange
                          const SizedBox(width: 4),
                          Text(
                            event.formattedTime,
                            style: const TextStyle(
                                fontSize: 14, color: Colors.grey), // Increased font size
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.location_on,
                              size: 16, color: Colors.purple), // Changed color to purple
                          const SizedBox(width: 4),
                          Text(
                            event.location,
                            style: const TextStyle(
                                fontSize: 14, color: Colors.grey), // Increased font size
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      event.club,
                      style: const TextStyle(
                          fontSize: 14, color: Colors.grey), // Increased font size
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(event.dayStatus),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      event.dayStatus,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _getStatusTextColor(event.dayStatus),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey,
                    size: 16,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
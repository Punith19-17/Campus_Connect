import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '/../config.dart'; // Make sure this path is correct

// Import the unified Event model
import '../../models/event_model.dart';
import 'add_event.dart';
import 'event_details.dart'; // Import the EventDetailsPage
import 'package:intl/intl.dart'; // Needed for date comparisons

class ManageEventsPage extends StatefulWidget {
  const ManageEventsPage({Key? key}) : super(key: key);

  @override
  State<ManageEventsPage> createState() => _ManageEventsPageState();
}

class _ManageEventsPageState extends State<ManageEventsPage> {
  // Now uses the unified Event class from event_model.dart
  List<Event> _allEvents = [];
  List<Event> _filteredEvents = [];
  bool _isLoading = true;
  String _error = '';

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadEvents();
    _searchController.addListener(_filterEvents);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterEvents);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      final response = await http.get(Uri.parse('${AppConfig.baseUrl}/api/addevents'));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final List eventsJson = jsonResponse['events'];
        // Event.fromJson from the unified event_model.dart
        final events = eventsJson.map((json) => Event.fromJson(json)).toList();
        setState(() {
          _allEvents = events;
          // Apply sorting immediately after loading
          _sortAndFilterEvents(_searchController.text);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load events from API');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to load events. Please try again.';
      });
    }
  }

  // New method to apply both filtering and the custom sorting logic
  void _sortAndFilterEvents(String query) {
    final lowerCaseQuery = query.toLowerCase();
    final now = DateTime.now(); // Get the current time for filtering

    // 1. Filter the list
    List<Event> filtered = _allEvents.where((event) {
      // **FILTER LOGIC:** Check if the event's full date/time is NOT in the past.
      final isActive = !event.fullDateTime.isBefore(now);

      // **UPDATED SEARCH LOGIC:** Search title, club, date, and location
      final titleMatches = event.eventTitle.toLowerCase().contains(lowerCaseQuery);
      final clubMatches = event.organizedClub.toLowerCase().contains(lowerCaseQuery);
      final dateMatches = event.originalDate.toLowerCase().contains(lowerCaseQuery);
      final locationMatches = event.location.toLowerCase().contains(lowerCaseQuery); // Added location search

      final queryMatches = titleMatches || clubMatches || dateMatches || locationMatches;

      // Only include events that are active AND match the current search query
      return isActive && queryMatches;
    }).toList();

    // 2. Apply custom sorting
    filtered.sort(_eventDateComparator);

    setState(() {
      _filteredEvents = filtered;
    });
  }

  // Custom comparator for sorting events by date priority
  int _eventDateComparator(Event a, Event b) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Get the date-only components for comparison
    final dateA = DateTime(a.fullDateTime.year, a.fullDateTime.month, a.fullDateTime.day);
    final dateB = DateTime(b.fullDateTime.year, b.fullDateTime.month, b.fullDateTime.day);

    // Define priority scores
    int getPriority(DateTime date) {
      if (date.isAtSameMomentAs(today)) return 3; // Today: Highest priority
      if (date.isAtSameMomentAs(today.add(const Duration(days: 1)))) return 2; // Tomorrow: Second highest
      if (date.isBefore(today)) return 0; // Past: Lowest priority
      return 1; // Future (not tomorrow): Medium priority
    }

    final priorityA = getPriority(dateA);
    final priorityB = getPriority(dateB);

    if (priorityA != priorityB) {
      return priorityB.compareTo(priorityA); // Sort by priority descending (3, 2, 1, 0)
    }

    // If priorities are the same, sort by the actual event date and time
    // For today/tomorrow/future, sort by ascending date/time.
    if (priorityA >= 1) {
      return a.fullDateTime.compareTo(b.fullDateTime);
    }

    // For completed (past) events, sort by descending date (most recent completed first).
    return b.fullDateTime.compareTo(a.fullDateTime);
  }

  void _filterEvents() {
    _sortAndFilterEvents(_searchController.text);
  }

  Future<void> _refreshEvents() async {
    await _loadEvents();
  }

  Future<void> _handleAlter(Event event) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => AddEventPage(event: event)),
    );
    if (result == true) {
      _refreshEvents();
    }
  }

  Future<void> _handleDelete(Event event) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete "${event.eventTitle}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final response = await http.delete(
        Uri.parse('${AppConfig.baseUrl}/api/addevents/${event.id}'),
      );
      if (!mounted) return;
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event deleted successfully!'), backgroundColor: Colors.green),
        );
        _refreshEvents();
      } else {
        final error = json.decode(response.body)['message'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete event: $error'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      // Added AppBar for the header navigation and title
      appBar: AppBar(
        // The default leading icon (back arrow) appears if context.canPop is true
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'AIMS',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Button is placed on the left (start of the row)
                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const AddEventPage()),
                    );
                    if (result == true) {
                      _refreshEvents();
                    }
                  },
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('Add Event'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007AFF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                // Title is moved to the right (end of the row)
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                // Hint text reflects all search fields including location
                hintText: 'Search active events by title, club, date, or location...',
                prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshEvents,
                child: _buildEventList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error.isNotEmpty) {
      return Center(child: Text(_error));
    }
    if (_filteredEvents.isEmpty) {
      // Updated message to reflect active-only filtering
      return const Center(child: Text('No active events found.'));
    }
    return ListView.builder(
      itemCount: _filteredEvents.length,
      itemBuilder: (context, index) {
        final event = _filteredEvents[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EventDetailsPage(event: event),
              ),
            );
          },
          child: EventCard(
            event: event,
            onAlter: () => _handleAlter(event),
            onDelete: () => _handleDelete(event),
          ),
        );
      },
    );
  }
}

class EventCard extends StatelessWidget {
  // Now uses the unified Event class from event_model.dart
  final Event event;
  final VoidCallback onAlter;
  final VoidCallback onDelete;

  const EventCard({
    Key? key,
    required this.event,
    required this.onAlter,
    required this.onDelete,
  }) : super(key: key);

  // Helper function to determine the event status and style
  Map<String, dynamic> _getEventStatus() {
    // We use the fullDateTime getter which now correctly handles the local time conversion
    // fullDateTime is part of the unified Event class
    final eventDateTime = event.fullDateTime;
    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);
    // Use the date component of the corrected eventDateTime
    final eventDate = DateTime(eventDateTime.year, eventDateTime.month, eventDateTime.day);

    // Status check based on the corrected date/time
    if (eventDateTime.isBefore(now)) {
      return {'text': 'COMPLETED', 'color': Colors.green};
    } else if (eventDate.isAtSameMomentAs(todayDate)) {
      return {'text': 'TODAY', 'color': Colors.orange};
    } else if (eventDate.isAtSameMomentAs(todayDate.add(const Duration(days: 1)))) {
      return {'text': 'TOMORROW', 'color': Colors.pink};
    } else {
      // For future events, don't show a specific status badge
      return {'text': '', 'color': Colors.transparent};
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = _getEventStatus();

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        // NEW COLOR: Soft Lavender (Colors.deepPurple[50])
        color: Colors.deepPurple[50],
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), spreadRadius: 1, blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  event.eventTitle, // Changed from event.title to event.eventTitle
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'Alter') {
                    onAlter();
                  } else if (value == 'Delete') {
                    onDelete();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem<String>(value: 'Alter', child: Text('Alter')),
                  const PopupMenuItem<String>(value: 'Delete', child: Text('Delete')),
                ],
                icon: Icon(Icons.more_vert, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildDetailItem(icon: Icons.calendar_today, text: event.displayDate, iconColor: Colors.blue), // Changed to displayDate
              const SizedBox(width: 16),
              _buildDetailItem(icon: Icons.access_time, text: event.displayTime, iconColor: Colors.orange), // Changed to displayTime
              const SizedBox(width: 16),
              Expanded(
                  child: _buildDetailItem(icon: Icons.location_on, text: event.location, iconColor: Colors.red)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Display Organized Club Name
              Text(
                event.organizedClub,
                style: TextStyle(fontSize: 16, color: Colors.grey[700], fontWeight: FontWeight.w600),
              ),
              // Display the Status Text opposite the club name
              if (status['text'].isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: status['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: status['color'], width: 1),
                  ),
                  child: Text(
                    status['text'],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: status['color'],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({required IconData icon, required String text, required Color iconColor}) {
    final textStyle = TextStyle(fontSize: 13, color: Colors.grey[700]);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: textStyle,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
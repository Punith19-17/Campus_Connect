import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:ui'; // For BackdropFilter
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
    if (priorityA >= 1) {
      return a.fullDateTime.compareTo(b.fullDateTime);
    }

    // For completed (past) events, sort by descending date
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Confirm Deletion', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete "${event.eventTitle}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
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
        _showModernSnackBar('Event deleted successfully!', Colors.green);
        _refreshEvents();
      } else {
        final error = json.decode(response.body)['message'];
        _showModernSnackBar('Failed to delete event: $error', Colors.redAccent);
      }
    } catch (e) {
      if (!mounted) return;
      _showModernSnackBar('An error occurred: $e', Colors.redAccent);
    }
  }

  void _showModernSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(color == Colors.green ? Icons.check_circle_rounded : Icons.error_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFFFE4E1), // Misty Rose
            Color(0xFFE0F7FA), // Light Cyan
            Color(0xFFF3E5F5), // Light Purple
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          automaticallyImplyLeading: false, // No back arrow
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'AIMS', // Preserved AIMS title
            style: TextStyle(
              color: Color(0xFF1E293B),
              fontWeight: FontWeight.w900,
              fontSize: 22,
              letterSpacing: -0.5,
            ),
          ),
          centerTitle: false,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: Container(
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      // Routes directly to AddEventPage() per check.dart logic
                      final result = await Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const AddEventPage()),
                      );
                      if (result == true) {
                        _refreshEvents();
                      }
                    },
                    icon: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
                    label: const Text(
                      'NEW',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        letterSpacing: 0.5,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: _GlassContainer(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                  decoration: InputDecoration(
                    hintText: 'Search active events by title, club, date, or location...',
                    hintStyle: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                    prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF6366F1)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0),
                      borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshEvents,
                color: const Color(0xFF6366F1),
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
      return const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)));
    }
    if (_error.isNotEmpty) {
      return Center(
        child: _GlassContainer(
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
            ],
          ),
        ),
      );
    }
    if (_filteredEvents.isEmpty) {
      return Center(
        child: _GlassContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.search_off_rounded, color: Color(0xFF64748B), size: 48),
              SizedBox(height: 16),
              Text(
                'No active events found.',
                style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 40),
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      itemCount: _filteredEvents.length,
      itemBuilder: (context, index) {
        final event = _filteredEvents[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: GestureDetector(
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
          ),
        );
      },
    );
  }
}

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onAlter;
  final VoidCallback onDelete;

  const EventCard({
    Key? key,
    required this.event,
    required this.onAlter,
    required this.onDelete,
  }) : super(key: key);

  Map<String, dynamic> _getEventStatus() {
    final eventDateTime = event.fullDateTime;
    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);
    final eventDate = DateTime(eventDateTime.year, eventDateTime.month, eventDateTime.day);

    if (eventDateTime.isBefore(now)) {
      return {'text': 'COMPLETED', 'color': const Color(0xFF10B981), 'icon': Icons.check_circle_rounded}; // Emerald
    } else if (eventDate.isAtSameMomentAs(todayDate)) {
      return {'text': 'TODAY', 'color': const Color(0xFFF59E0B), 'icon': Icons.bolt_rounded}; // Amber
    } else if (eventDate.isAtSameMomentAs(todayDate.add(const Duration(days: 1)))) {
      return {'text': 'TOMORROW', 'color': const Color(0xFFF43F5E), 'icon': Icons.update_rounded}; // Rose
    } else {
      return {'text': '', 'color': Colors.transparent, 'icon': null};
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = _getEventStatus();

    return _GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  event.eventTitle,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              PopupMenuButton<String>(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: Colors.white.withOpacity(0.95),
                elevation: 10,
                onSelected: (value) {
                  if (value == 'Alter') {
                    onAlter();
                  } else if (value == 'Delete') {
                    onDelete();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem<String>(
                    value: 'Alter',
                    child: Row(
                      children: const [
                        Icon(Icons.edit_rounded, color: Color(0xFF6366F1), size: 20),
                        SizedBox(width: 12),
                        Text('Alter', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'Delete',
                    child: Row(
                      children: const [
                        Icon(Icons.delete_rounded, color: Color(0xFFEF4444), size: 20),
                        SizedBox(width: 12),
                        Text('Delete', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFFEF4444))),
                      ],
                    ),
                  ),
                ],
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.more_vert_rounded, color: Color(0xFF1E293B), size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildDetailItem(
                icon: Icons.calendar_month_rounded,
                text: event.displayDate,
                iconColor: const Color(0xFF3B82F6),
              ),
              const SizedBox(width: 16),
              _buildDetailItem(
                icon: Icons.access_time_rounded,
                text: event.displayTime,
                iconColor: const Color(0xFFF59E0B),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDetailItem(
                  icon: Icons.location_on_rounded,
                  text: event.location,
                  iconColor: const Color(0xFF10B981),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white, height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.business_rounded, size: 14, color: Color(0xFF8B5CF6)),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    event.organizedClub,
                    style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B), fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              if (status['text'] != '')
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: status['color'].withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: status['color'].withOpacity(0.5), width: 1),
                  ),
                  child: Row(
                    children: [
                      Icon(status['icon'], size: 14, color: status['color']),
                      const SizedBox(width: 4),
                      Text(
                        status['text'],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: status['color'],
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({required IconData icon, required String text, required Color iconColor}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: iconColor.withOpacity(0.8)),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// A reusable frosted glass container
class _GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const _GlassContainer({required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: padding ?? const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.4),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
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

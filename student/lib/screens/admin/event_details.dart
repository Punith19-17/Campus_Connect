import 'package:flutter/material.dart';
import '../../models/event_model.dart'; // Import the unified Event model

class EventDetailsPage extends StatelessWidget {
  final Event event;

  const EventDetailsPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    // Debug the date to see what's happening
    print('=== EVENT DETAILS DEBUG ===');
    print('Event date: ${event.date}');
    print('Formatted date: ${event.formattedDate}');
    print('Display date: ${event.displayDate}');
    print('===========================');

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigates back
          },
        ),
        title: const Text('Event Details'),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Container(
          color: const Color(0xFFF3F3F3),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  event.eventTitle,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  event.description,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Event Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  icon: Icons.calendar_today,
                  text: _getCorrectFormattedDate(), // Use the corrected date method
                  iconColor: Colors.blue,
                ),
                _buildInfoRow(
                  icon: Icons.access_time,
                  text: '${event.formattedStartTime} - ${event.formattedEndTime}',
                  iconColor: Colors.purple,
                ),
                _buildInfoRow(
                  icon: Icons.location_on,
                  text: event.location,
                  iconColor: Colors.green,
                ),
                _buildInfoRow(
                  icon: Icons.category,
                  text: event.eventType,
                  iconColor: Colors.orange,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Organized By',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  event.organizedClub,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Award',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildAwardRow(
                  icon: Icons.emoji_events,
                  text: event.award ?? 'No award specified',
                ),
                // Add participants count if available
                if (event.participants > 0) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Participants',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildParticipantsRow(
                    icon: Icons.people,
                    text: '${event.participants} participants',
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Method to get the correctly formatted date without timezone issues
  String _getCorrectFormattedDate() {
    try {
      // Use the original date string from the event to avoid timezone issues
      final originalDate = event.originalDate; // This should be '2025-11-21'

      // Parse it directly without timezone conversion
      final parts = originalDate.split('-');
      if (parts.length == 3) {
        final year = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final day = int.parse(parts[2]);

        // Create a DateTime object directly
        final correctDate = DateTime(year, month, day);

        // Format it manually to avoid any timezone issues
        final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

        final dayOfWeek = dayNames[correctDate.weekday - 1];
        final monthName = monthNames[correctDate.month - 1];

        return '$dayOfWeek, $monthName ${correctDate.day}, ${correctDate.year}';
      }

      // Fallback to the original formatted date
      return event.formattedDate;
    } catch (e) {
      print('Error formatting date: $e');
      return event.formattedDate;
    }
  }

  Widget _buildInfoRow({required IconData icon, required String text, required Color iconColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAwardRow({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.amber,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantsRow({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.blue,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
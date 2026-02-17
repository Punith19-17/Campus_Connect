import 'package:flutter/material.dart';
import 'student_dashboard.dart'; // Import the Aim class

class clgeventsDetailsPage extends StatefulWidget {
  final Aim event;

  const clgeventsDetailsPage({super.key, required this.event});

  @override
  State<clgeventsDetailsPage> createState() => _clgeventsDetailsPageState();
}

class _clgeventsDetailsPageState extends State<clgeventsDetailsPage> {
  // A state variable to track if the user is interested
  bool _isInterested = false;

  @override
  Widget build(BuildContext context) {
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.event.title ?? '',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // The "interested" heart icon
                    IconButton(
                      icon: Icon(
                        _isInterested ? Icons.favorite : Icons.favorite_border,
                        color: _isInterested ? Colors.red : Colors.black,
                      ),
                      onPressed: () {
                        setState(() {
                          _isInterested = !_isInterested;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.event.description ?? '',
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
                  text: widget.event.eventDate != null ? '${widget.event.eventDate.month}/${widget.event.eventDate.day}/${widget.event.eventDate.year}' : 'N/A',
                  iconColor: Colors.blue, // Different color
                ),
                _buildInfoRow(
                  icon: Icons.access_time,
                  text: widget.event.time,
                  iconColor: Colors.purple, // Different color
                ),
                _buildInfoRow(
                  icon: Icons.location_on,
                  text: widget.event.location,
                  iconColor: Colors.green, // Different color
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
                  widget.event.organizedClub,
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
                  text: widget.event.award ?? 'No award specified',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({required IconData icon, required String text, required Color iconColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: iconColor, // Use the provided color
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
}

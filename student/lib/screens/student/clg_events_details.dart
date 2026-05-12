import 'package:flutter/material.dart';
import 'dart:ui'; // For BackdropFilter
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
      backgroundColor: const Color(0xFFF8FAFC), // Light grey background
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
              onPressed: () {
                Navigator.pop(context); // Navigates back
              },
            ),
          ),
        ),
        title: const Text(
          'Event Details',
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
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Immersive Header Area
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 120, 24, 40),
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
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.event.status ?? 'Upcoming',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.event.title ?? '',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.business_rounded, color: Colors.white, size: 16),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.event.organizedClub,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Content Area
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Interaction Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'About This Event',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isInterested = !_isInterested;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: _isInterested ? const Color(0xFFF43F5E).withOpacity(0.1) : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _isInterested ? const Color(0xFFF43F5E).withOpacity(0.5) : const Color(0xFFE2E8F0),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _isInterested ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                color: _isInterested ? const Color(0xFFF43F5E) : const Color(0xFF64748B),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _isInterested ? 'Interested' : 'Interest',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: _isInterested ? const Color(0xFFF43F5E) : const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.event.description ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF475569),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  const Text(
                    'Event Details',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Detail Glass Cards
                  _buildDetailCard(
                    icon: Icons.calendar_month_rounded,
                    title: 'Date',
                    subtitle: widget.event.eventDate != null ? '${widget.event.eventDate.month}/${widget.event.eventDate.day}/${widget.event.eventDate.year}' : 'N/A',
                    color: const Color(0xFF38BDF8),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailCard(
                    icon: Icons.access_time_rounded,
                    title: 'Time',
                    subtitle: widget.event.time,
                    color: const Color(0xFF8B5CF6),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailCard(
                    icon: Icons.location_on_rounded,
                    title: 'Location',
                    subtitle: widget.event.location,
                    color: const Color(0xFF10B981),
                  ),
                  
                  if (widget.event.award != null && widget.event.award!.isNotEmpty) ...[
                    const SizedBox(height: 32),
                    const Text(
                      'Prizes & Awards',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailCard(
                      icon: Icons.emoji_events_rounded,
                      title: 'Award',
                      subtitle: widget.event.award!,
                      color: const Color(0xFFF59E0B),
                    ),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard({required IconData icon, required String title, required String subtitle, required Color color}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

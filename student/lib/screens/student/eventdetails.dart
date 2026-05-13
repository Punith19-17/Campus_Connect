import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'myresponsespage.dart'; // for Event model
import 'participate.dart'; // Import the ParticipatePage

class EventDetailsPage extends StatefulWidget {
  final int eventId;
  final int studentId;

  const EventDetailsPage({
    super.key,
    required this.eventId,
    required this.studentId,
  });

  @override
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> with SingleTickerProviderStateMixin {
  bool _isInterested = false;
  bool _isLoading = true;
  String? _errorMessage;
  Event? _event;

  late AnimationController _heartAnimationController;

  @override
  void initState() {
    super.initState();
    _heartAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      lowerBound: 0.8,
      upperBound: 1.2,
    );
    _fetchEventDetails();
  }

  @override
  void dispose() {
    _heartAnimationController.dispose();
    super.dispose();
  }

  Future<void> _fetchEventDetails() async {
    const String baseUrl = 'https://campus-connect-p1ow.onrender.com';
    final String url = '$baseUrl/api/addevents/${widget.eventId}';
    final String likeStatusUrl =
        '$baseUrl/api/addevents/like/status?eventId=${widget.eventId}&studentId=${widget.studentId}';

    try {
      final responses = await Future.wait([
        http.get(Uri.parse(url)),
        http.get(Uri.parse(likeStatusUrl)),
      ]);

      final eventResponse = responses[0];
      final likeResponse = responses[1];

      if (eventResponse.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(eventResponse.body);
        if (data['success'] == true && data['event'] != null) {
          _event = Event.fromJson(data['event']);
        } else {
          _errorMessage = 'Event details not found.';
        }
      } else {
        _errorMessage =
            'Failed to load event details. Status: ${eventResponse.statusCode}';
      }

      if (likeResponse.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(likeResponse.body);
        if (data['success'] == true) {
          _isInterested = data['isLiked'] ?? false;
        }
      }
    } catch (e) {
      _errorMessage = 'Failed to connect to the server.\nError: $e';
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleLike() async {
    _heartAnimationController.forward().then((_) {
      _heartAnimationController.reverse();
    });

    setState(() {
      _isInterested = !_isInterested;
    });

    try {
      const String baseUrl = 'https://campus-connect-p1ow.onrender.com';
      final String url = _isInterested
          ? '$baseUrl/api/addevents/like'
          : '$baseUrl/api/addevents/unlike';

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'eventId': widget.eventId,
          'studentId': widget.studentId,
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        setState(() {
          _isInterested = !_isInterested;
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update interest status.')),
        );
      }
    } catch (e) {
      setState(() {
        _isInterested = !_isInterested;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F8FE),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF))),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F8FE),
        body: Center(
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
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final event = _event!;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            expandedHeight: 180.0,
            pinned: true,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF4A5568), size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.share_rounded, color: Color(0xFF4A5568), size: 20),
                    onPressed: () {},
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFFF1EB), Color(0xFFACE0F9)], // Peach to Ice Blue
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutBack,
                    builder: (context, double val, child) {
                      return Transform.scale(
                        scale: val,
                        child: child,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.4),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFACE0F9).withOpacity(0.5),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.event_rounded, size: 40, color: Color(0xFF2D3748)),
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              transform: Matrix4.translationValues(0, -30, 0), // Pull up over the app bar slightly
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 30, 20, 100), // Adjusted padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            event.title,
                            style: const TextStyle(
                              fontSize: 24, // Smaller font
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF2D3748),
                              height: 1.2,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: _toggleLike,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(12), // Smaller padding
                            decoration: BoxDecoration(
                              color: _isInterested ? const Color(0xFFFFF5F5) : const Color(0xFFF5F8FE),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _isInterested ? const Color(0xFFFEB2B2) : Colors.transparent,
                              ),
                            ),
                            child: ScaleTransition(
                              scale: _heartAnimationController,
                              child: Icon(
                                _isInterested ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                color: _isInterested ? const Color(0xFFF56565) : const Color(0xFFA0AEC0),
                                size: 24, // Smaller icon
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Bento Mini Cards
                    Row(
                      children: [
                        Expanded(child: _buildBentoCard(Icons.calendar_month_rounded, 'Date', event.formattedDate, const Color(0xFF6C63FF), const Color(0xFFF0F5FF))),
                        const SizedBox(width: 20),
                        Expanded(child: _buildBentoCard(Icons.access_time_rounded, 'Time', event.time, const Color(0xFFF6AD55), const Color(0xFFFFFaf0))),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(child: _buildBentoCard(Icons.location_on_rounded, 'Location', event.location, const Color(0xFF48BB78), const Color(0xFFF0FFF4))),
                        const SizedBox(width: 20),
                        Expanded(child: _buildBentoCard(Icons.apartment_rounded, 'Club', event.club, const Color(0xFFED64A6), const Color(0xFFFFF5F7))),
                      ],
                    ),

                    const SizedBox(height: 32),

                    const Text(
                      'About This Event',
                      style: TextStyle(
                        fontSize: 18, // Smaller font
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF2D3748),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      event.description,
                      style: const TextStyle(
                        fontSize: 14, // Smaller font
                        height: 1.5,
                        color: Color(0xFF718096),
                      ),
                    ),

                    const SizedBox(height: 32),

                    if (event.award != null && event.award!.isNotEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16), // Smaller padding
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFFF0),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFFEFCBF)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: Color(0xFFFEFCBF),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.emoji_events_rounded, color: Color(0xFFD69E2E), size: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Prizes & Awards',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFFD69E2E),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    event.award!,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF975A16),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20), // Smaller margin
        width: double.infinity,
        height: 54, // Smaller button
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(27),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8EC5FC).withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ParticipatePage(eventName: event.title),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27)),
            padding: EdgeInsets.zero,
          ),
          child: Ink(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8EC5FC), Color(0xFFE0C3FC)], // Ice Blue to Lilac
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(27),
            ),
            child: const Center(
              child: Text(
                'JOIN EVENT',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14, // Smaller font
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBentoCard(IconData icon, String title, String subtitle, Color iconColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(20.0), // Larger padding for breathing room
      decoration: BoxDecoration(
        color: const Color(0xFFF5F8FE),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 24), // Larger icon back
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFFA0AEC0),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: Color(0xFF2D3748),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

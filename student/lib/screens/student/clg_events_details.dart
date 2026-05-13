import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'student_dashboard.dart'; // Import the Aim class

class clgeventsDetailsPage extends StatefulWidget {
  final Aim event;

  const clgeventsDetailsPage({super.key, required this.event});

  @override
  State<clgeventsDetailsPage> createState() => _clgeventsDetailsPageState();
}

class _clgeventsDetailsPageState extends State<clgeventsDetailsPage> with SingleTickerProviderStateMixin {
  bool _isInterested = false;
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
  }

  @override
  void dispose() {
    _heartAnimationController.dispose();
    super.dispose();
  }

  void _toggleInterest() {
    setState(() {
      _isInterested = !_isInterested;
    });

    if (_isInterested) {
      _heartAnimationController.forward().then((_) => _heartAnimationController.reverse());
    }
  }

  String _getFormattedDate() {
    return DateFormat('MMM d, yyyy').format(widget.event.eventDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            expandedHeight: 200.0,
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
            flexibleSpace: ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
              child: FlexibleSpaceBar(
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
                        child: const Icon(Icons.celebration_rounded, size: 40, color: Color(0xFF2D3748)),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 30, 24, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Heart
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            widget.event.title ?? 'No Title',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF2D3748),
                              letterSpacing: -1.0,
                              height: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: _toggleInterest,
                          child: Container(
                            padding: const EdgeInsets.all(12),
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
                                size: 24,
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
                        Expanded(child: _buildBentoCard(Icons.calendar_month_rounded, 'Date', _getFormattedDate(), const Color(0xFF6C63FF), const Color(0xFFF0F5FF))),
                        const SizedBox(width: 16),
                        Expanded(child: _buildBentoCard(Icons.access_time_rounded, 'Time', widget.event.time, const Color(0xFFF6AD55), const Color(0xFFFFFaf0))),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildBentoCard(Icons.location_on_rounded, 'Location', widget.event.location, const Color(0xFF48BB78), const Color(0xFFF0FFF4))),
                        const SizedBox(width: 16),
                        Expanded(child: _buildBentoCard(Icons.domain_rounded, 'Organized By', widget.event.organizedClub, const Color(0xFFED64A6), const Color(0xFFFFF5F7))),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // About section
                    const Text(
                      'About This Event',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF2D3748),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.event.description ?? 'No description provided.',
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF718096),
                        height: 1.6,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Award Section
                    const Text(
                      'Award',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF2D3748),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFaf0),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFFBD38D).withOpacity(0.5)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF6AD55).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.emoji_events_rounded, color: Color(0xFFDD6B20), size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              widget.event.award ?? 'No award specified',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF2D3748),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBentoCard(IconData icon, String title, String subtitle, Color iconColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(20.0),
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
            child: Icon(icon, color: iconColor, size: 24),
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

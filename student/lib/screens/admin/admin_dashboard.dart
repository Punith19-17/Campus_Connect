import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:ui';
import 'manage_events.dart';
import 'manage_clubs.dart';
import 'add_event.dart';
import 'add_club.dart';
import 'participation_list.dart';
import '/../config.dart';

// ** Data model to hold the statistics fetched from the API **
class DashboardStats {
  final int totalEvents;
  final int totalClubs;
  final int totalStudents;
  final int activeEvents;

  DashboardStats({
    this.totalEvents = 0,
    this.totalClubs = 0,
    this.totalStudents = 0,
    this.activeEvents = 0,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalEvents: json['totalEvents'] ?? 0,
      totalClubs: json['totalClubs'] ?? 0,
      totalStudents: json['totalStudents'] ?? 0,
      activeEvents: json['activeEvents'] ?? 0,
    );
  }
}

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    DashboardHome(),
    ManageEventsPage(),
    ManageClubs(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6F8), // Super light mobile grey
      extendBody: true, // Allows the floating nav bar to sit over the body
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(left: 24, right: 24, bottom: 20),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withOpacity(0.15),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.dashboard_rounded, 'Dashboard'),
              _buildNavItem(1, Icons.event_rounded, 'Events'),
              _buildNavItem(2, Icons.groups_rounded, 'Clubs'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6366F1).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF6366F1) : const Color(0xFF94A3B8),
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF6366F1),
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

class DashboardHome extends StatefulWidget {
  const DashboardHome({super.key});

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> with SingleTickerProviderStateMixin {
  late Future<DashboardStats> _statsFuture;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _statsFuture = _fetchDashboardStats();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<DashboardStats> _fetchDashboardStats() async {
    try {
      final response = await http.get(Uri.parse('${AppConfig.baseUrl}/api/dashboard/stats'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return DashboardStats.fromJson(data['stats']);
      } else {
        throw Exception('Failed to load dashboard stats');
      }
    } catch (e) {
      return DashboardStats(totalEvents: -1);
    }
  }

  void _refreshStats() {
    setState(() {
      _statsFuture = _fetchDashboardStats();
    });
    _controller.reset();
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Massive Curved Header Background
              ClipPath(
                clipper: _HeaderClipper(),
                child: Container(
                  height: 380,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFE0C3FC), // Soft Light Purple
                        Color(0xFF8EC5FC), // Soft Light Blue
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),

              // Header Content
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.only(top: 20, left: 24, right: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Row (Greeting & Refresh)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Good Morning,",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white.withOpacity(0.8),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Text(
                                "Admin 👋",
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                              onPressed: _refreshStats,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),

                      // Horizontal Scrolling Stats
                      SizedBox(
                        height: 200,
                        child: FutureBuilder<DashboardStats>(
                          future: _statsFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator(color: Colors.white));
                            }
                            final stats = snapshot.hasData ? snapshot.data : null;
                            final isError = snapshot.hasError || (stats?.totalEvents == -1);

                            return ListView(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              clipBehavior: Clip.none,
                              children: [
                                _AnimatedStatCard(
                                  animation: _controller,
                                  delay: 0.1,
                                  title: "Total\nEvents",
                                  value: isError ? "Err" : (stats?.totalEvents.toString() ?? "..."),
                                  icon: Icons.event_available_rounded,
                                  textColor: const Color(0xFF6366F1), // Indigo
                                ),
                                const SizedBox(width: 16),
                                _AnimatedStatCard(
                                  animation: _controller,
                                  delay: 0.2,
                                  title: "Active\nClubs",
                                  value: isError ? "Err" : (stats?.totalClubs.toString() ?? "..."),
                                  icon: Icons.groups_rounded,
                                  textColor: const Color(0xFFF43F5E), // Rose
                                ),
                                const SizedBox(width: 16),
                                _AnimatedStatCard(
                                  animation: _controller,
                                  delay: 0.3,
                                  title: "Total\nStudents",
                                  value: isError ? "Err" : (stats?.totalStudents.toString() ?? "..."),
                                  icon: Icons.school_rounded,
                                  textColor: const Color(0xFF10B981), // Emerald
                                ),
                                const SizedBox(width: 16),
                                _AnimatedStatCard(
                                  animation: _controller,
                                  delay: 0.4,
                                  title: "Active\nEvents",
                                  value: isError ? "Err" : (stats?.activeEvents.toString() ?? "..."),
                                  icon: Icons.local_activity_rounded,
                                  textColor: const Color(0xFFF59E0B), // Amber
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Management Section
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 24),
              _AnimatedFadeSlide(
                animation: _controller,
                delay: 0.5,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Management",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1E293B),
                        letterSpacing: -0.5,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ParticipationListPage())),
                      icon: const Icon(Icons.history_rounded, size: 18),
                      label: const Text("Logs", style: TextStyle(fontWeight: FontWeight.bold)),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF6366F1),
                        backgroundColor: const Color(0xFF6366F1).withOpacity(0.1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              _AnimatedFadeSlide(
                animation: _controller,
                delay: 0.6,
                child: _ManagementCard(
                  title: "Create Event",
                  subtitle: "Plan and schedule new campus activities.",
                  icon: Icons.add_circle_rounded,
                  color: const Color(0xFF10B981),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEventPage())),
                ),
              ),
              const SizedBox(height: 16),

              _AnimatedFadeSlide(
                animation: _controller,
                delay: 0.7,
                child: _ManagementCard(
                  title: "Register Club",
                  subtitle: "Add new organizations and departments.",
                  icon: Icons.add_business_rounded,
                  color: const Color(0xFFF59E0B),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddClubPage())),
                ),
              ),
              const SizedBox(height: 120), // Space for floating bottom nav bar
            ]),
          ),
        ),
      ],
    );
  }
}

// ----------------------------------------------------------------------
// Custom UI Components
// ----------------------------------------------------------------------

class _HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 80);
    path.quadraticBezierTo(
      size.width / 2, size.height + 40,
      size.width, size.height - 80,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _AnimatedStatCard extends StatelessWidget {
  final AnimationController animation;
  final double delay;
  final String title;
  final String value;
  final IconData icon;
  final Color textColor;

  const _AnimatedStatCard({
    required this.animation,
    required this.delay,
    required this.title,
    required this.value,
    required this.icon,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return _AnimatedFadeSlide(
      animation: animation,
      delay: delay,
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: textColor.withOpacity(0.15),
              blurRadius: 25,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: textColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: textColor, size: 28),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: textColor,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF64748B),
                      height: 1.3,
                    ),
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

class _ManagementCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ManagementCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(icon, color: color, size: 32),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, color: color.withOpacity(0.3), size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedFadeSlide extends StatelessWidget {
  final AnimationController animation;
  final double delay;
  final Widget child;

  const _AnimatedFadeSlide({
    required this.animation,
    required this.delay,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final start = delay.clamp(0.0, 1.0);
    final end = (delay + 0.4).clamp(0.0, 1.0);
    final curve = CurvedAnimation(
      parent: animation,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );

    return AnimatedBuilder(
      animation: curve,
      builder: (context, childWidget) {
        return Opacity(
          opacity: curve.value,
          child: Transform.translate(
            offset: Offset(0, 40 * (1 - curve.value)),
            child: childWidget,
          ),
        );
      },
      child: child,
    );
  }
}

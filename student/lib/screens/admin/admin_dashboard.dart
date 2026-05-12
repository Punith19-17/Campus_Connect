import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:ui'; // Needed for BackdropFilter
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
    // The entire dashboard uses a stunning full-screen light gradient
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
        backgroundColor: Colors.transparent, // Let the beautiful gradient shine through
        extendBody: true, // Let the bottom nav float over the background
        body: SafeArea(
          bottom: false,
          child: IndexedStack(
            index: _selectedIndex,
            children: _widgetOptions,
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            margin: const EdgeInsets.only(left: 24, right: 24, bottom: 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5), // Glassmorphism nav bar
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(color: Colors.white.withOpacity(0.7), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
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
            ),
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
          color: isSelected ? Colors.white.withOpacity(0.8) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]
              : [],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF6366F1) : const Color(0xFF64748B),
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
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 20.0, bottom: 120.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          _AnimatedFadeSlide(
            animation: _controller,
            delay: 0.1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("Control Center", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF1E293B), letterSpacing: -0.5)),
                    SizedBox(height: 4),
                    Text("Campus Management", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
                  ],
                ),
                _GlassContainer(
                  padding: const EdgeInsets.all(12),
                  child: InkWell(
                    onTap: _refreshStats,
                    child: const Icon(Icons.refresh_rounded, color: Color(0xFF1E293B)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Bento Box Glassmorphic Grid
          FutureBuilder<DashboardStats>(
            future: _statsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)));
              }

              final stats = snapshot.data;
              final isError = snapshot.hasError || (stats?.totalEvents == -1);

              return Column(
                children: [
                  // Full Width Hero Box (Total Students)
                  _AnimatedFadeSlide(
                    animation: _controller,
                    delay: 0.2,
                    child: _GlassContainer(
                      height: 120,
                      padding: const EdgeInsets.all(24),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Total Enrolled Students", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                                const SizedBox(height: 4),
                                Text(
                                  isError ? "Err" : (stats?.totalStudents.toString() ?? "..."),
                                  style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Color(0xFF1E293B), height: 1.0),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [Color(0xFF818CF8), Color(0xFF4F46E5)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [BoxShadow(color: const Color(0xFF4F46E5).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
                            ),
                            child: const Icon(Icons.people_alt_rounded, color: Colors.white, size: 36),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Asymmetric Bento Grid
                  _AnimatedFadeSlide(
                    animation: _controller,
                    delay: 0.3,
                    child: Row(
                      children: [
                        // Left Tall Box (Total Events)
                        Expanded(
                          child: _GlassStatCard(
                            height: 220,
                            title: "Total\nEvents",
                            value: isError ? "Err" : (stats?.totalEvents.toString() ?? "..."),
                            icon: Icons.event_available_rounded,
                            gradientColor: const Color(0xFF38BDF8),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Right Stacked Boxes
                        Expanded(
                          child: Column(
                            children: [
                              _GlassStatCard(
                                height: 102,
                                title: "Total Clubs",
                                value: isError ? "Err" : (stats?.totalClubs.toString() ?? "..."),
                                icon: Icons.groups_rounded,
                                gradientColor: const Color(0xFFF43F5E),
                                isHorizontal: true,
                              ),
                              const SizedBox(height: 16),
                              _GlassStatCard(
                                height: 102,
                                title: "Active Now",
                                value: isError ? "Err" : (stats?.activeEvents.toString() ?? "..."),
                                icon: Icons.local_activity_rounded,
                                gradientColor: const Color(0xFF10B981),
                                isHorizontal: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 40),

          // Actions Section
          _AnimatedFadeSlide(
            animation: _controller,
            delay: 0.4,
            child: const Text("Management Actions", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
          ),
          const SizedBox(height: 16),

          _AnimatedFadeSlide(
            animation: _controller,
            delay: 0.5,
            child: _GlassContainer(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  _ActionTile(
                    title: "Create New Event",
                    icon: Icons.add_circle_rounded,
                    color: const Color(0xFF10B981),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEventPage())),
                  ),
                  Divider(color: Colors.white.withOpacity(0.5), height: 1, indent: 64),
                  _ActionTile(
                    title: "Register New Club",
                    icon: Icons.add_business_rounded,
                    color: const Color(0xFFF59E0B),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddClubPage())),
                  ),
                  Divider(color: Colors.white.withOpacity(0.5), height: 1, indent: 64),
                  _ActionTile(
                    title: "View Participation Logs",
                    icon: Icons.history_rounded,
                    color: const Color(0xFF8B5CF6),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ParticipationListPage())),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------------
// Glassmorphism UI Components
// ----------------------------------------------------------------------

/// A reusable frosted glass container
class _GlassContainer extends StatelessWidget {
  final Widget child;
  final double? height;
  final double? width;
  final EdgeInsets? padding;

  const _GlassContainer({required this.child, this.height, this.width, this.padding});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          height: height,
          width: width,
          padding: padding,
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

class _GlassStatCard extends StatelessWidget {
  final double height;
  final String title;
  final String value;
  final IconData icon;
  final Color gradientColor;
  final bool isHorizontal;

  const _GlassStatCard({
    required this.height,
    required this.title,
    required this.value,
    required this.icon,
    required this.gradientColor,
    this.isHorizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassContainer(
      height: height,
      padding: EdgeInsets.all(isHorizontal ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               Container(
                 padding: EdgeInsets.all(isHorizontal ? 10 : 14),
                 decoration: BoxDecoration(
                   color: gradientColor.withOpacity(0.15),
                   shape: BoxShape.circle,
                 ),
                 child: Icon(icon, color: gradientColor, size: isHorizontal ? 20 : 32),
               ),
               if (isHorizontal)
                 Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
            ]
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isHorizontal) ...[
                Text(value, style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Color(0xFF1E293B), height: 1)),
                const SizedBox(height: 4),
              ],
              Text(title, style: TextStyle(fontSize: isHorizontal ? 14 : 16, fontWeight: FontWeight.w700, color: const Color(0xFF64748B))),
            ],
          )
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({required this.title, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, color: Colors.black.withOpacity(0.2), size: 16),
            ],
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

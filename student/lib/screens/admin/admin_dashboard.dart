import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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
      backgroundColor: const Color(0xFFF5F7FA), // Light grey background
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: const Text(
          'Campus Admin',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.w800,
            fontSize: 22,
            letterSpacing: 0.5,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30.0),
            topRight: Radius.circular(30.0),
          ),
          child: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_outlined),
                  activeIcon: Icon(Icons.dashboard_rounded),
                  label: 'Dashboard'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.event_outlined),
                  activeIcon: Icon(Icons.event_rounded),
                  label: 'Events'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.group_work_outlined),
                  activeIcon: Icon(Icons.group_work_rounded),
                  label: 'Clubs'),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: const Color(0xFF4F46E5),
            unselectedItemColor: const Color(0xFF94A3B8),
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
            onTap: _onItemTapped,
            backgroundColor: Colors.white,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
          ),
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
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _statsFuture = _fetchDashboardStats();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
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
    _animationController.reset();
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          _AnimatedChild(
            animation: _animationController,
            index: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Overview',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B)),
                ),
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ParticipationListPage(),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.playlist_add_check_rounded, color: Color(0xFF4F46E5), size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Responses',
                              style: TextStyle(
                                color: Color(0xFF4F46E5),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: _refreshStats,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.refresh_rounded, color: Color(0xFF64748B), size: 20),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Stats Grid
          FutureBuilder<DashboardStats>(
            future: _statsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF4F46E5)));
              }
              if (snapshot.hasError || (snapshot.hasData && snapshot.data!.totalEvents == -1)) {
                return _buildSummaryGrid(DashboardStats(totalEvents: -1));
              }
              if (snapshot.hasData) {
                return _buildSummaryGrid(snapshot.data);
              }
              return const Center(child: Text('No data available.'));
            },
          ),

          const SizedBox(height: 40),
          _AnimatedChild(
            animation: _animationController,
            index: 3,
            child: const Text(
              'Quick Actions',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B)),
            ),
          ),
          const SizedBox(height: 16),

          // Quick Actions Grid
          _AnimatedChild(
            animation: _animationController,
            index: 4,
            child: Row(
              children: [
                Expanded(
                  child: _QuickActionButton(
                    label: 'Add Event',
                    icon: Icons.add_circle_outline_rounded,
                    color: const Color(0xFF10B981),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const AddEventPage()));
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _QuickActionButton(
                    label: 'Add Club',
                    icon: Icons.add_business_rounded,
                    color: const Color(0xFFF59E0B),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const AddClubPage()));
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryGrid(DashboardStats? stats) {
    String getValue(int? statValue) {
      if (stats == null) return '...';
      if (statValue == -1) return 'Err';
      return statValue.toString();
    }

    return _AnimatedChild(
      animation: _animationController,
      index: 1,
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _SummaryCard(
            title: 'Total Events',
            value: getValue(stats?.totalEvents),
            icon: Icons.event_rounded,
            gradientColors: const [Color(0xFF38BDF8), Color(0xFF0284C7)],
          ),
          _SummaryCard(
            title: 'Total Clubs',
            value: getValue(stats?.totalClubs),
            icon: Icons.groups_rounded,
            gradientColors: const [Color(0xFF818CF8), Color(0xFF4F46E5)],
          ),
          _SummaryCard(
            title: 'Total Students',
            value: getValue(stats?.totalStudents),
            icon: Icons.people_alt_rounded,
            gradientColors: const [Color(0xFFF472B6), Color(0xFFDB2777)],
          ),
          _SummaryCard(
            title: 'Active Events',
            value: getValue(stats?.activeEvents),
            icon: Icons.local_activity_rounded,
            gradientColors: const [Color(0xFF34D399), Color(0xFF059669)],
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final List<Color> gradientColors;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.0),
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(
              icon,
              size: 80,
              color: Colors.white.withOpacity(0.15),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 32, color: color),
                ),
                const SizedBox(height: 12),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedChild extends StatelessWidget {
  final AnimationController animation;
  final int index;
  final Widget child;

  const _AnimatedChild({
    required this.animation,
    required this.index,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final start = (index * 0.1).clamp(0.0, 1.0);
    final end = (start + 0.5).clamp(0.0, 1.0);
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
            offset: Offset(0, 30 * (1 - curve.value)),
            child: childWidget,
          ),
        );
      },
      child: child,
    );
  }
}

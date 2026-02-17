import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'manage_events.dart';
import 'manage_clubs.dart';
import 'add_event.dart';
import 'add_club.dart';
import 'participation_list.dart'; // Import the participation list page
import '/../config.dart'; // Ensure you have your config file

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

  // The main pages for the navigation bar
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
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'AIMS',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.event_outlined),
              activeIcon: Icon(Icons.event),
              label: 'Events'),
          BottomNavigationBarItem(
              icon: Icon(Icons.group_work_outlined),
              activeIcon: Icon(Icons.group_work),
              label: 'Clubs'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF4A90E2),
        unselectedItemColor: Colors.grey[600],
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        elevation: 5.0,
      ),
    );
  }
}

// ** DashboardHome converted to a StatefulWidget to fetch and manage data **
class DashboardHome extends StatefulWidget {
  const DashboardHome({super.key});

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> {
  late Future<DashboardStats> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = _fetchDashboardStats();
  }

  // ** Function to fetch data from the new backend endpoint **
  Future<DashboardStats> _fetchDashboardStats() async {
    try {
      final response = await http.get(
          Uri.parse('${AppConfig.baseUrl}/api/dashboard/stats'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return DashboardStats.fromJson(data['stats']);
      } else {
        throw Exception('Failed to load dashboard stats');
      }
    } catch (e) {
      // Return a default object with -1 to indicate an error
      return DashboardStats(totalEvents: -1);
    }
  }

  void _refreshStats() {
    setState(() {
      _statsFuture = _fetchDashboardStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Admin Panel',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
              //  Grouping for the buttons on the right
              Row(
                children: [
                  // The "Responses" button (Now on the left)
                  ElevatedButton.icon(
                    onPressed: () {
                      // Navigate to the ParticipationListPage
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ParticipationListPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.playlist_add_check, size: 30),
                    label: const Text('Participation'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE3F2FD), // Light blue background
                      foregroundColor: const Color(0xFF1E88E5), // Darker blue for text/icon
                      elevation: 0, // Flat button style
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                  const SizedBox(width: 8), // Spacing between buttons
                  // NEW: The refresh button (Now on the right)
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 20),
                    color: const Color(0xFF1E88E5), // Darker blue color
                    onPressed: _refreshStats, // Call the existing refresh function
                    tooltip: 'Refresh Stats',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          // ** FutureBuilder handles UI states (loading, error, data) **
          FutureBuilder<DashboardStats>(
            future: _statsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // Show placeholders while loading
                return _buildSummaryGrid(null);
              }
              if (snapshot.hasError ||
                  (snapshot.hasData && snapshot.data!.totalEvents == -1)) {
                // Show cards with an error indicator
                return _buildSummaryGrid(DashboardStats(totalEvents: -1));
              }
              if (snapshot.hasData) {
                // Show data when it arrives
                return _buildSummaryGrid(snapshot.data);
              }
              return const Center(child: Text('No data available.'));
            },
          ),
          const SizedBox(height: 30),
          const Text(
            'Quick Actions',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                  child: QuickActionButton(
                      label: 'Add Event',
                      icon: Icons.add_circle_outline,
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const AddEventPage()));
                      })),
              const SizedBox(width: 15),
              Expanded(
                  child: QuickActionButton(
                      label: 'Add Club',
                      icon: Icons.add_business_outlined,
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const AddClubPage()));
                      })),
            ],
          ),
        ],
      ),
    );
  }

  // Helper widget to build the grid, handling null (loading) and error states
  Widget _buildSummaryGrid(DashboardStats? stats) {
    // Determine the value to display based on the state
    String getValue(int? statValue) {
      if (stats == null) return '...'; // Loading
      if (statValue == -1) return 'Error'; // Error
      return statValue.toString();
    }

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 15.0,
      mainAxisSpacing: 15.0,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        SummaryCard(
          title: 'Total Events',
          value: getValue(stats?.totalEvents),
          icon: Icons.event,
          color: const Color(0xFF4A90E2),
        ),
        SummaryCard(
          title: 'Total Clubs',
          value: getValue(stats?.totalClubs),
          icon: Icons.group_work,
          color: const Color(0xFF50E3C2),
        ),
        SummaryCard(
          title: 'Total Students',
          value: getValue(stats?.totalStudents),
          icon: Icons.people,
          color: const Color(0xFFF5A623),
        ),
        SummaryCard(
          title: 'Active Events',
          value: getValue(stats?.activeEvents),
          icon: Icons.local_activity,
          color: const Color(0xFFBD10E0),
        ),
      ],
    );
  }
}

class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: value == 'Error' ? Colors.redAccent : Colors.black87,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuickActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const QuickActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: const Color(0xFF4A90E2)),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
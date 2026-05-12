import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:ui';
import 'club_details.dart';

class Club {
  final int id;
  final String name;
  final String description;
  final String clubType;
  final String? picUrl;
  final String department;
  final String? responsibleFaculty;
  final String president;
  final String vicePresident;
  final String jointSecretary;
  final String treasury;
  final String groupMembers;

  const Club({
    required this.id,
    required this.name,
    required this.description,
    required this.clubType,
    this.picUrl,
    required this.department,
    this.responsibleFaculty,
    required this.president,
    required this.vicePresident,
    required this.jointSecretary,
    required this.treasury,
    required this.groupMembers,
  });

  factory Club.fromJson(Map<String, dynamic> json) {
    return Club(
      id: json['id'] ?? 0,
      name: json['club_name'] ?? 'No Name',
      description: json['club_discription'] ?? 'No Description',
      clubType: json['club_type'] ?? 'institutional',
      picUrl: json['pic'],
      department: json['department'] ?? '',
      responsibleFaculty: json['responsible_faculty'],
      president: json['president'] ?? '',
      vicePresident: json['vice_president'] ?? '',
      jointSecretary: json['joint_secretary'] ?? '',
      treasury: json['treasury'] ?? '',
      groupMembers: json['group_members'] ?? '',
    );
  }
}

class ClubDirectoryPage extends StatefulWidget {
  const ClubDirectoryPage({Key? key}) : super(key: key);

  @override
  _ClubDirectoryPageState createState() => _ClubDirectoryPageState();
}

class _ClubDirectoryPageState extends State<ClubDirectoryPage> {
  bool _isLoading = true;
  String _errorMessage = '';
  List<Club> _departmentClubs = [];
  List<Club> _collageClubs = [];
  bool _isDepartmentClubSelected = true;

  @override
  void initState() {
    super.initState();
    _fetchClubs();
  }

  Future<void> _fetchClubs() async {
    const String url = 'https://campus-connect-p1ow.onrender.com/api/clubs';

    try {
      final response = await http.get(Uri.parse(url));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['clubs'] is List) {
          final List<Club> allClubs = (data['clubs'] as List)
              .map((clubJson) => Club.fromJson(clubJson))
              .toList();

          final depts = allClubs
              .where((club) => club.clubType == 'departmental')
              .toList();
          final collages = allClubs
              .where((club) => club.clubType == 'institutional')
              .toList();

          setState(() {
            _departmentClubs = depts;
            _collageClubs = collages;
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = 'Invalid data format from server.';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to load clubs. Status: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to connect to the server.\nError: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Clubs",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E293B),
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Join communities & grow",
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 24),
              _StudentGlassContainer(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Expanded(child: _buildTab('Department', true)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildTab('College', false)),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF0EA5E9)))
              : _errorMessage.isNotEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: _StudentGlassContainer(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48),
                              const SizedBox(height: 16),
                              Text(
                                _errorMessage,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : _buildClubGrid(_isDepartmentClubSelected ? _departmentClubs : _collageClubs),
        ),
      ],
    );
  }

  Widget _buildTab(String title, bool isDepartmentTab) {
    bool isSelected = _isDepartmentClubSelected == isDepartmentTab;
    return GestureDetector(
      onTap: () {
        setState(() {
          _isDepartmentClubSelected = isDepartmentTab;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0EA5E9) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildClubGrid(List<Club> clubs) {
    if (clubs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _StudentGlassContainer(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.groups_rounded, color: Color(0xFF94A3B8), size: 64),
                SizedBox(height: 16),
                Text(
                  'No clubs found in this category.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    // Use staggered/masonry look by slightly offsetting the second column
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75, // Optimized for glass cards
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
      ),
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 100), // Extra bottom padding for nav bar
      itemCount: clubs.length,
      itemBuilder: (context, index) {
        return Transform.translate(
          offset: Offset(0, index % 2 != 0 ? 20 : 0), // Masonry stagger effect
          child: ClubCard(club: clubs[index]),
        );
      },
    );
  }
}

class ClubCard extends StatelessWidget {
  final Club club;

  const ClubCard({
    Key? key,
    required this.club,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _StudentGlassContainer(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE2E8F0), Color(0xFFF8FAFC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0EA5E9).withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Center(
              child: Icon(Icons.groups_rounded, color: Color(0xFF94A3B8), size: 32),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            club.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1E293B),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              club.description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 36,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ClubDetailsPage(club: club),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0EA5E9).withOpacity(0.1),
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
              ),
              child: const Text(
                'DETAILS',
                style: TextStyle(
                  color: Color(0xFF0EA5E9),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A reusable vibrant frosted glass container for the Student Module
class _StudentGlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const _StudentGlassContainer({required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: padding ?? const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.55),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0EA5E9).withOpacity(0.05),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

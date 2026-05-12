import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:ui'; // For BackdropFilter
import 'add_club.dart';
import 'club_details.dart';
import '/../config.dart';

// ** SOLUTION 1: Expanded the Club Model to hold ALL details from the backend **
class Club {
  final int id;
  final String name;
  final String description;
  final String clubType;
  final String? pic;
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
    this.pic,
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
      pic: json['pic'],
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

class ManageClubs extends StatefulWidget {
  const ManageClubs({Key? key}) : super(key: key);

  @override
  _ManageClubsState createState() => _ManageClubsState();
}

class _ManageClubsState extends State<ManageClubs> {
  bool _isDepartmentClubSelected = true;
  final TextEditingController _searchController = TextEditingController();

  List<Club> _allClubs = [];
  List<Club> _filteredClubs = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchClubs();
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.removeListener(_applyFilters);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchClubs() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final response = await http.get(Uri.parse('${AppConfig.baseUrl}/api/clubs'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> clubJson = data['clubs'];
        setState(() {
          _allClubs = clubJson.map((json) => Club.fromJson(json)).toList();
          _applyFilters();
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load clubs');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Could not fetch clubs. Please try again.';
      });
    }
  }

  Future<void> _refreshClubs() async {
    _searchController.clear();
    await _fetchClubs();
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();
    final selectedType = _isDepartmentClubSelected ? 'departmental' : 'institutional';

    setState(() {
      _filteredClubs = _allClubs.where((club) {
        final typeMatches = club.clubType == selectedType;
        final queryMatches = query.isEmpty || club.name.toLowerCase().contains(query);
        return typeMatches && queryMatches;
      }).toList();
    });
  }

  Future<void> _handleAlter(Club club) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => AddClubPage(club: club)),
    );
    if (result == true) {
      _refreshClubs();
    }
  }

  Future<void> _handleDelete(Club club) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Confirm Deletion', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete the "${club.name}" club?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final response = await http.delete(Uri.parse('${AppConfig.baseUrl}/api/clubs/${club.id}'));
      if (!mounted) return;

      if (response.statusCode == 200) {
        _showModernSnackBar('Club deleted successfully!', Colors.green);
        _refreshClubs();
      } else {
        final error = json.decode(response.body)['message'] ?? 'Failed to delete club.';
        _showModernSnackBar(error, Colors.redAccent);
      }
    } catch (e) {
      if (!mounted) return;
      _showModernSnackBar('An error occurred: $e', Colors.redAccent);
    }
  }

  void _showModernSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(color == Colors.green ? Icons.check_circle_rounded : Icons.error_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          automaticallyImplyLeading: false, // No back arrow as requested
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Manage Clubs',
            style: TextStyle(
              color: Color(0xFF1E293B),
              fontWeight: FontWeight.w900,
              fontSize: 22,
              letterSpacing: -0.5,
            ),
          ),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: Container(
                  height: 36, // Explicit height matching the "Manage Events" button
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const AddClubPage()),
                      );
                      if (result == true) {
                        _refreshClubs();
                      }
                    },
                    icon: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
                    label: const Text(
                      'NEW',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        letterSpacing: 0.5,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: _GlassContainer(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Expanded(child: _buildTab('Department', true)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildTab('College', false)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: _GlassContainer(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                  decoration: InputDecoration(
                    hintText: 'Search for clubs...',
                    hintStyle: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                    prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF6366F1)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0),
                      borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _buildBody(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String title, bool isDepartmentTab) {
    bool isSelected = _isDepartmentClubSelected == isDepartmentTab;
    return GestureDetector(
      onTap: () {
        setState(() {
          _isDepartmentClubSelected = isDepartmentTab;
          _applyFilters();
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6366F1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)));
    }
    if (_error != null) {
      return Center(
        child: _GlassContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
    }
    if (_filteredClubs.isEmpty) {
      return Center(
        child: _GlassContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.search_off_rounded, color: Color(0xFF64748B), size: 48),
              SizedBox(height: 16),
              Text(
                'No clubs found.',
                style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _refreshClubs,
      color: const Color(0xFF6366F1),
      child: GridView.builder(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.70, // Optimized for modern glass container layout
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
        ),
        padding: const EdgeInsets.only(left: 24, right: 24, bottom: 40),
        itemCount: _filteredClubs.length,
        itemBuilder: (context, index) {
          final club = _filteredClubs[index];
          return ClubCard(
            club: club,
            onAlter: () => _handleAlter(club),
            onDelete: () => _handleDelete(club),
          );
        },
      ),
    );
  }
}

class ClubCard extends StatelessWidget {
  final Club club;
  final VoidCallback onAlter;
  final VoidCallback onDelete;

  const ClubCard({
    Key? key,
    required this.club,
    required this.onAlter,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _GlassContainer(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center, // Centered align
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: 24), // Spacer to offset popup menu and perfectly center image
              // Club Image
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: club.pic != null && club.pic!.isNotEmpty
                      ? Image.network(
                          '${AppConfig.baseUrl}${club.pic}',
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                        )
                      : _buildPlaceholder(),
                ),
              ),
              // Popup Menu
              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: Colors.white.withOpacity(0.95),
                elevation: 10,
                onSelected: (String result) {
                  if (result == 'alter') {
                    onAlter();
                  } else if (result == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'alter',
                    child: Row(
                      children: [
                        Icon(Icons.edit_rounded, color: Color(0xFF6366F1), size: 18),
                        SizedBox(width: 8),
                        Text('Alter', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_rounded, color: Color(0xFFEF4444), size: 18),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFFEF4444))),
                      ],
                    ),
                  ),
                ],
                icon: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.more_vert_rounded, color: Color(0xFF1E293B), size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            club.name,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Text(
              club.description,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 32,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ClubDetailsPage(club: club),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1).withOpacity(0.1),
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              ),
              child: const Text(
                'DETAILS',
                style: TextStyle(
                  color: Color(0xFF6366F1),
                  fontSize: 10,
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

  Widget _buildPlaceholder() {
    return Container(
      width: 60,
      height: 60,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE2E8F0), Color(0xFFF1F5F9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.groups_rounded, color: Color(0xFF94A3B8), size: 28),
    );
  }
}

/// A reusable frosted glass container
class _GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const _GlassContainer({required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: padding ?? const EdgeInsets.all(24),
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

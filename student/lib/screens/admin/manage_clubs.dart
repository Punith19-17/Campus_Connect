import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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
        title: const Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete the "${club.name}" club?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final response = await http.delete(Uri.parse('${AppConfig.baseUrl}/api/clubs/${club.id}'));
      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Club deleted successfully!'), backgroundColor: Colors.green),
        );
        _refreshClubs();
      } else {
        final error = json.decode(response.body)['message'] ?? 'Failed to delete club.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Manage Clubs',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const AddClubPage()),
                );
                if (result == true) {
                  _refreshClubs();
                }
              },
              icon: const Icon(Icons.add, size: 20, color: Colors.white),
              label: const Text('Add Club', style: TextStyle(color: Colors.white, fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E88E5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                _buildTab('Department Clubs', true),
                const SizedBox(width: 40),
                _buildTab('College Clubs', false),
              ],
            ),
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for clubs...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String title, bool isDepartmentTab) {
    bool isSelected = _isDepartmentClubSelected == isDepartmentTab;
    return InkWell(
      onTap: () {
        setState(() {
          _isDepartmentClubSelected = isDepartmentTab;
          _applyFilters();
        });
      },
      child: Text(
        title,
        style: TextStyle(
          fontSize: 19,
          color: isSelected ? Colors.black : Colors.grey[400],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text(_error!));
    }
    if (_filteredClubs.isEmpty) {
      return const Center(child: Text('No clubs found in this category.'));
    }
    return RefreshIndicator(
      onRefresh: _refreshClubs,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.65,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
        ),
        padding: const EdgeInsets.all(16.0),
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
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F6FC),
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(30),
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
              PopupMenuButton<String>(
                onSelected: (String result) {
                  if (result == 'alter') {
                    onAlter();
                  } else if (result == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(value: 'alter', child: Text('Alter')),
                  const PopupMenuItem<String>(value: 'delete', child: Text('Delete')),
                ],
                icon: const Icon(Icons.more_vert, color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            club.name,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              club.description,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
              overflow: TextOverflow.ellipsis,
              maxLines: 4,
            ),
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: MaterialButton(
                  onPressed: () {
                    // **MODIFIED:** Pass the club object to the new page
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ClubDetailsPage(club: club),
                      ),
                    );
                  },
                  color: const Color(0xFF1E88E5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                  height: 30,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: const Text('Details', style: TextStyle(color: Colors.white, fontSize: 10)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(color: Colors.grey[300], shape: BoxShape.circle),
      child: const Icon(Icons.group, color: Colors.black54),
    );
  }
}

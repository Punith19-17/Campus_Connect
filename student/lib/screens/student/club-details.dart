import 'package:flutter/material.dart';
import 'club_list.dart'; // Import the Club class from the student module

class ClubDetailsPage extends StatelessWidget {
  final Club club;

  const ClubDetailsPage({
    super.key,
    required this.club,
  });

  @override
  Widget build(BuildContext context) {
    // 2. Use the club object's data instead of hardcoded strings.
    final Map<String, String> leadership = {};
    if (club.responsibleFaculty != null && club.responsibleFaculty!.isNotEmpty) {
      leadership['Responsible Faculty'] = club.responsibleFaculty!;
    }
    if (club.president.isNotEmpty) {
      leadership['President'] = club.president;
    }
    if (club.vicePresident.isNotEmpty) {
      leadership['Vice President'] = club.vicePresident;
    }
    if (club.jointSecretary.isNotEmpty) {
      leadership['Joint Secretary'] = club.jointSecretary;
    }
    if (club.treasury.isNotEmpty) {
      leadership['Treasury'] = club.treasury;
    }

    // Split the group members string by commas and trim whitespace
    final List<String> members = club.groupMembers.split(',').map((e) => e.trim()).toList();
    // Filter out any empty strings that might result from trailing commas
    members.removeWhere((member) => member.isEmpty);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'AIMS',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 4.0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                club.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A90E2),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.class_outlined, size: 18, color: Colors.blueAccent),
                  const SizedBox(width: 8),
                  Text(
                    club.department.isEmpty ? 'N/A' : club.department,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _buildSectionTitle('Description', Icons.lightbulb_outline, Colors.orange),
              Text(
                club.description,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 32),
              _buildSectionTitle('Roles', Icons.supervised_user_circle_outlined, Colors.purple),
              _buildLeadershipGrid(leadership),
              const SizedBox(height: 32),
              _buildSectionTitle('Members', Icons.group_outlined, Colors.green),
              _buildMembersList(members),
              const SizedBox(height: 32),
              _buildSectionTitle('Club Type', Icons.category_outlined, Colors.redAccent),
              Text(
                club.clubType.isEmpty ? 'N/A' : club.clubType.toUpperCase(),
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildLeadershipGrid(Map<String, String> leadership) {
    if (leadership.isEmpty) {
      return const Text('No leadership roles found.');
    }
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 24.0,
      mainAxisSpacing: 16.0,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 3.5,
      children: leadership.entries.map((entry) {
        return _buildPersonCard(entry.key, entry.value);
      }).toList(),
    );
  }

  Widget _buildPersonCard(String role, String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.person_outline, size: 18, color: Colors.blueGrey),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                role,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        Text(
          name,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildMembersList(List<String> members) {
    if (members.isEmpty) {
      return const Text('No members found.');
    }
    List<Widget> rows = [];
    for (int i = 0; i < members.length; i += 3) {
      List<Widget> rowMembers = [];
      for (int j = i; j < i + 3 && j < members.length; j++) {
        rowMembers.add(
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(
                members[j],
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
          ),
        );
      }
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            children: rowMembers,
          ),
        ),
      );
    }
    return Column(
      children: rows,
    );
  }
}
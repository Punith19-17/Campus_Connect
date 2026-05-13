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
    final Map<String, String> leadership = {};
    if (club.responsibleFaculty != null && club.responsibleFaculty!.isNotEmpty) {
      leadership['Faculty Advisor'] = club.responsibleFaculty!;
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
      leadership['Treasurer'] = club.treasury;
    }

    final List<String> members = club.groupMembers.split(',').map((e) => e.trim()).toList();
    members.removeWhere((member) => member.isEmpty);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFF),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
              )
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1E293B)),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Premium Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 100, bottom: 40, left: 24, right: 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFE0E7FF), Color(0xFFF3E8FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4F46E5).withOpacity(0.15),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(Icons.groups_rounded, color: Color(0xFF6C63FF), size: 40),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    club.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1E293B),
                      letterSpacing: -0.5,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.domain_rounded, size: 16, color: Color(0xFF64748B)),
                        const SizedBox(width: 8),
                        Text(
                          club.department.isEmpty ? 'General' : club.department,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content Sections
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('About the Club', Icons.info_outline_rounded, const Color(0xFF0EA5E9), const Color(0xFFE0F2FE)),
                  _buildSoftCard(
                    child: Text(
                      club.description,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                  _buildSectionTitle('Leadership', Icons.stars_rounded, const Color(0xFF8B5CF6), const Color(0xFFEDE9FE)),
                  _buildSoftCard(
                    child: _buildLeadershipGrid(leadership),
                  ),

                  const SizedBox(height: 32),
                  _buildSectionTitle('Members', Icons.people_alt_rounded, const Color(0xFF10B981), const Color(0xFFD1FAE5)),
                  _buildSoftCard(
                    child: _buildMembersGrid(members),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color iconColor, Color bgColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSoftCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildLeadershipGrid(Map<String, String> leadership) {
    if (leadership.isEmpty) {
      return const Text('No leadership roles found.', style: TextStyle(color: Color(0xFF94A3B8)));
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: leadership.length,
      separatorBuilder: (context, index) => const Divider(height: 24, color: Color(0xFFF1F5F9)),
      itemBuilder: (context, index) {
        String role = leadership.keys.elementAt(index);
        String name = leadership.values.elementAt(index);
        return Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_outline_rounded, size: 20, color: Color(0xFF64748B)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    role,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMembersGrid(List<String> members) {
    if (members.isEmpty) {
      return const Text('No members found.', style: TextStyle(color: Color(0xFF94A3B8)));
    }
    return Wrap(
      spacing: 8.0,
      runSpacing: 12.0,
      children: members.map((member) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            member,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569),
            ),
          ),
        );
      }).toList(),
    );
  }
}

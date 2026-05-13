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
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            expandedHeight: 280.0,
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
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFACE0F9), Color(0xFFE0C3FC)], // Ice Blue to Lilac
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      TweenAnimationBuilder(
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
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF8EC5FC).withOpacity(0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(Icons.groups_rounded, color: Color(0xFF6C63FF), size: 36),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(
                          club.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF2D3748),
                            letterSpacing: -0.5,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.domain_rounded, size: 16, color: Color(0xFF4A5568)),
                            const SizedBox(width: 8),
                            Text(
                              club.department.isEmpty ? 'General' : club.department,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF2D3748),
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
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF5F8FE),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              transform: Matrix4.translationValues(0, -20, 0),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 30, 20, 60),
                child: Column(
                  children: [
                    _buildAnimatedCard(
                      index: 0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('About the Club', Icons.info_outline_rounded, const Color(0xFF6C63FF), const Color(0xFFF5F8FE)),
                          const SizedBox(height: 16),
                          Text(
                            club.description,
                            style: const TextStyle(
                              fontSize: 15,
                              height: 1.6,
                              color: Color(0xFF718096),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildAnimatedCard(
                      index: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Leadership', Icons.stars_rounded, const Color(0xFFF56565), const Color(0xFFFFF5F5)),
                          const SizedBox(height: 16),
                          _buildLeadershipGrid(leadership),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildAnimatedCard(
                      index: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Members', Icons.people_alt_rounded, const Color(0xFF38B2AC), const Color(0xFFE6FFFA)),
                          const SizedBox(height: 16),
                          _buildMembersGrid(members),
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

  Widget _buildAnimatedCard({required int index, required Widget child}) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 600 + (index * 200)),
      curve: Curves.easeOutCubic,
      builder: (context, double val, childWidget) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - val)),
          child: Opacity(
            opacity: val,
            child: childWidget,
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8EC5FC).withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: child,
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color iconColor, Color bgColor) {
    return Row(
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
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Color(0xFF2D3748),
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildLeadershipGrid(Map<String, String> leadership) {
    if (leadership.isEmpty) {
      return const Text('No leadership roles found.', style: TextStyle(color: Color(0xFFA0AEC0)));
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: leadership.length,
      separatorBuilder: (context, index) => const Divider(height: 24, color: Color(0xFFEDF2F7)),
      itemBuilder: (context, index) {
        String role = leadership.keys.elementAt(index);
        String name = leadership.values.elementAt(index);
        return Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F8FE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.person_outline_rounded, size: 18, color: Color(0xFF718096)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    role,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFA0AEC0),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF2D3748),
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
      return const Text('No members found.', style: TextStyle(color: Color(0xFFA0AEC0)));
    }
    return Wrap(
      spacing: 10.0,
      runSpacing: 10.0,
      children: members.map((member) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F8FE),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            member,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFF4A5568),
            ),
          ),
        );
      }).toList(),
    );
  }
}

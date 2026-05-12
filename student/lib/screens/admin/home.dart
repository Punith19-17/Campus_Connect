import 'package:flutter/material.dart';
import '../student/Student_login.dart';
import '../student/Student_signup.dart';
import 'admin_signup.dart';
import 'admin_login.dart';
import 'aboutus.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Campus Connect',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E293B),
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white.withOpacity(0.85),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF8FAFC), // Light Slate
              Color(0xFFEFF6FF), // Light Blue
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Main Header Card
                Container(
                  padding: const EdgeInsets.all(32.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3B82F6).withOpacity(0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF60A5FA), Color(0xFF3B82F6)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF3B82F6).withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.hub_rounded,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Campus Connect",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1E293B),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Your unified campus experience",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 10,
                        runSpacing: 10,
                        children: const [
                          _FeatureChip(icon: Icons.event_available, label: "Events"),
                          _FeatureChip(icon: Icons.campaign_outlined, label: "Notices"),
                          _FeatureChip(icon: Icons.schedule, label: "Timings"),
                          _FeatureChip(icon: Icons.place_outlined, label: "Venues"),
                          _FeatureChip(icon: Icons.people, label: "Clubs"),
                          _FeatureChip(icon: Icons.analytics, label: "Analytics"),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Student Section
                const _SectionHeader(
                  title: "Student Portal",
                  subtitle: "Access your personalized dashboard",
                  icon: Icons.school_rounded,
                  gradient: [Color(0xFF38BDF8), Color(0xFF0284C7)],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _ActionCard(
                        icon: Icons.login_rounded,
                        title: "Login",
                        subtitle: "Welcome back",
                        gradient: const [Color(0xFF38BDF8), Color(0xFF0284C7)],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AuthScreen()),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _ActionCard(
                        icon: Icons.person_add_rounded,
                        title: "Sign Up",
                        subtitle: "Join the campus",
                        gradient: const [Color(0xFF34D399), Color(0xFF059669)],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const Student_signup()),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Admin Section
                const _SectionHeader(
                  title: "Admin Portal",
                  subtitle: "Manage events and campus life",
                  icon: Icons.admin_panel_settings_rounded,
                  gradient: [Color(0xFFFBBF24), Color(0xFFD97706)],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _ActionCard(
                        icon: Icons.login_rounded,
                        title: "Admin Login",
                        subtitle: "Manage portal",
                        gradient: const [Color(0xFFFBBF24), Color(0xFFD97706)],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AdminLogin()),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _ActionCard(
                        icon: Icons.person_add_alt_1_rounded,
                        title: "Admin Sign Up",
                        subtitle: "New admin",
                        gradient: const [Color(0xFFA78BFA), Color(0xFF7C3AED)],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AdminSignup()),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // About Section
                const _SectionHeader(
                  title: "Discover",
                  subtitle: "Learn more about Campus Connect",
                  icon: Icons.info_outline_rounded,
                  gradient: [Color(0xFFF472B6), Color(0xFFDB2777)],
                ),
                const SizedBox(height: 16),
                _ActionCard(
                  icon: Icons.info_rounded,
                  title: "About Us",
                  subtitle: "Our mission & features",
                  gradient: const [Color(0xFFF472B6), Color(0xFFDB2777)],
                  isFullWidth: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AboutUsPage()),
                    );
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [gradient[0].withOpacity(0.2), gradient[1].withOpacity(0.2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: gradient[1], size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final VoidCallback onTap;
  final bool isFullWidth;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradient[1].withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          highlightColor: gradient[0].withOpacity(0.1),
          splashColor: gradient[1].withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: isFullWidth
                ? Row(
                    children: _buildContent(),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _buildContent(isVertical: true),
                  ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildContent({bool isVertical = false}) {
    final iconWidget = Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [gradient[0].withOpacity(0.15), gradient[1].withOpacity(0.15)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: gradient[1], size: 28),
    );

    final textWidget = Column(
      crossAxisAlignment: isVertical ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
          textAlign: isVertical ? TextAlign.center : TextAlign.left,
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
          textAlign: isVertical ? TextAlign.center : TextAlign.left,
        ),
      ],
    );

    if (isVertical) {
      return [
        iconWidget,
        const SizedBox(height: 16),
        textWidget,
      ];
    } else {
      return [
        iconWidget,
        const SizedBox(width: 16),
        Expanded(child: textWidget),
        const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1)),
      ];
    }
  }
}

class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeatureChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF475569)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }
}

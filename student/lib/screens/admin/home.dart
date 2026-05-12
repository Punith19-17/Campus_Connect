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
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Icon(Icons.school_rounded, color: Color(0xFF6366F1), size: 22),
            ),
            const SizedBox(width: 10),
            const Text(
              'Campus Connect',
              style: TextStyle(
                color: Color(0xFF1E293B),
                fontWeight: FontWeight.w800,
                fontSize: 22,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.white.withOpacity(0.4),
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withOpacity(0.7),
                Colors.white.withOpacity(0.0),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.4, 0.7, 1.0],
            colors: [
              Color(0xFFFFF0F5), // Lavender Blush
              Color(0xFFE8F4F8), // Soft Light Blue
              Color(0xFFF3E8FF), // Light Purple
              Color(0xFFFFF5E6), // Soft Peach
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                // Hero Section
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: const Text(
                    "👋 Welcome to your new portal",
                    style: TextStyle(
                      color: Color(0xFF6366F1),
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Discover &\nManage Your\nCampus Life.",
                  style: TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                    height: 1.1,
                    letterSpacing: -1.0,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Everything you need from events to notices, right at your fingertips in one unified platform.",
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF475569),
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),

                // Horizontal Scrolling Feature Pills
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  clipBehavior: Clip.none,
                  child: Row(
                    children: const [
                      _FeaturePill(icon: Icons.event_available_rounded, text: "Events", color: Color(0xFFF43F5E)),
                      SizedBox(width: 12),
                      _FeaturePill(icon: Icons.campaign_rounded, text: "Notices", color: Color(0xFF8B5CF6)),
                      SizedBox(width: 12),
                      _FeaturePill(icon: Icons.schedule_rounded, text: "Timings", color: Color(0xFF06B6D4)),
                      SizedBox(width: 12),
                      _FeaturePill(icon: Icons.groups_rounded, text: "Clubs", color: Color(0xFF10B981)),
                      SizedBox(width: 12),
                      _FeaturePill(icon: Icons.place_rounded, text: "Venues", color: Color(0xFFF59E0B)),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Portals Section
                const Text(
                  "Get Started",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 16),

                _InteractivePortalCard(
                  title: "Student Portal",
                  subtitle: "Access your dashboard, classes, and marks.",
                  icon: Icons.face_retouching_natural_rounded,
                  gradientColors: const [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  onLogin: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthScreen())),
                  onSignup: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const Student_signup())),
                ),
                const SizedBox(height: 20),

                _InteractivePortalCard(
                  title: "Admin Portal",
                  subtitle: "Publish notices, manage clubs and events.",
                  icon: Icons.admin_panel_settings_rounded,
                  gradientColors: const [Color(0xFFF59E0B), Color(0xFFEF4444)],
                  onLogin: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminLogin())),
                  onSignup: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminSignup())),
                ),
                const SizedBox(height: 24),

                _InfoCard(
                  title: "About Us",
                  subtitle: "Learn more about Campus Connect.",
                  icon: Icons.info_outline_rounded,
                  color: const Color(0xFF10B981),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutUsPage())),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InteractivePortalCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradientColors;
  final VoidCallback onLogin;
  final VoidCallback onSignup;

  const _InteractivePortalCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradientColors,
    required this.onLogin,
    required this.onSignup,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.65), // Glassy feel
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: gradientColors[0].withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E293B),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
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
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _PortalButton(
                  text: "Login",
                  isPrimary: true,
                  gradientColors: gradientColors,
                  onTap: onLogin,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PortalButton(
                  text: "Sign Up",
                  isPrimary: false,
                  gradientColors: gradientColors,
                  onTap: onSignup,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PortalButton extends StatelessWidget {
  final String text;
  final bool isPrimary;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _PortalButton({
    required this.text,
    required this.isPrimary,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: isPrimary
              ? LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          color: isPrimary ? null : Colors.white.withOpacity(0.7),
          border: isPrimary ? null : Border.all(color: Colors.white, width: 2),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: gradientColors[0].withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: isPrimary ? Colors.white : const Color(0xFF1E293B),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _InfoCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.65),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 2),
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
            const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF94A3B8), size: 18),
          ],
        ),
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _FeaturePill({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

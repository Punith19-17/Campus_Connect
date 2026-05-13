import 'package:flutter/material.dart';
import '../student/Student_login.dart';
import '../student/Student_signup.dart';
import 'admin_signup.dart';
import 'admin_login.dart';
import 'aboutus.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    // Start the animation as soon as the screen loads
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Light grey background, classic app feel
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30.0), // Space for overlapping card
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Curved Header Background with Light Gradient
                  Container(
                    height: 300,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF7F7FD5), // Soft Indigo
                          Color(0xFF86A8E7), // Soft Blue
                          Color(0xFF91EAE4), // Soft Cyan
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                      ),
                    ),
                  ),

                  // Header Content
                  SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Campus Connect",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 30),
                          const Text(
                            "Welcome Back 👋",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Your unified campus experience",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Overlapping Greeting Card
                  Positioned(
                    bottom: -30,
                    left: 24,
                    right: 24,
                    child: _AnimatedChild(
                      animation: _controller,
                      index: 0,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF7F7FD5).withOpacity(0.15),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.school_rounded, color: Color(0xFF6366F1), size: 28),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    "Ready to connect?",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "Access your portals below.",
                                    style: TextStyle(
                                      color: Color(0xFF64748B),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
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
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 16),

                // Quick Actions Title
                _AnimatedChild(
                  animation: _controller,
                  index: 1,
                  child: const Text(
                    "Quick Explore",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Quick Actions Grid (2x3 format for apps)
                _AnimatedChild(
                  animation: _controller,
                  index: 2,
                  child: _buildQuickLinks(context),
                ),
                const SizedBox(height: 32),

                // Portals Title
                _AnimatedChild(
                  animation: _controller,
                  index: 3,
                  child: const Text(
                    "Access Portals",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Student Portal App Card
                _AnimatedChild(
                  animation: _controller,
                  index: 4,
                  child: _PortalAppCard(
                    title: "User Portal",
                    subtitle: "Dashboard, Classes & Marks",
                    icon: Icons.face_retouching_natural_rounded,
                    gradientColors: const [Color(0xFF38BDF8), Color(0xFF0284C7)],
                    onLogin: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthScreen())),
                    onSignup: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const Student_signup())),
                  ),
                ),
                const SizedBox(height: 20),

                // Admin Portal App Card
                _AnimatedChild(
                  animation: _controller,
                  index: 5,
                  child: _PortalAppCard(
                    title: "Admin Portal",
                    subtitle: "Manage Events & Clubs",
                    icon: Icons.admin_panel_settings_rounded,
                    gradientColors: const [Color(0xFFFBBF24), Color(0xFFEA580C)],
                    onLogin: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminLogin())),
                    onSignup: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminSignup())),
                  ),
                ),
                const SizedBox(height: 32),

                // About Us App Card
                _AnimatedChild(
                  animation: _controller,
                  index: 6,
                  child: _AboutUsCard(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutUsPage())),
                  ),
                ),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickLinks(BuildContext context) {
    void showLoginMessage(String feature) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please Login to view details in $feature", style: const TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: const Color(0xFF6366F1),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _AppFeatureCard(icon: Icons.event_available_rounded, title: "Events", color: const Color(0xFF6366F1), onTap: () => showLoginMessage("Events"))),
            const SizedBox(width: 12),
            Expanded(child: _AppFeatureCard(icon: Icons.campaign_rounded, title: "Notices", color: const Color(0xFFF43F5E), onTap: () => showLoginMessage("Notices"))),
            const SizedBox(width: 12),
            Expanded(child: _AppFeatureCard(icon: Icons.schedule_rounded, title: "Timings", color: const Color(0xFF10B981), onTap: () => showLoginMessage("Timings"))),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _AppFeatureCard(icon: Icons.place_rounded, title: "Venues", color: const Color(0xFFF59E0B), onTap: () => showLoginMessage("Venues"))),
            const SizedBox(width: 12),
            Expanded(child: _AppFeatureCard(icon: Icons.groups_rounded, title: "Clubs", color: const Color(0xFF8B5CF6), onTap: () => showLoginMessage("Clubs"))),
            const SizedBox(width: 12),
            Expanded(child: _AppFeatureCard(icon: Icons.analytics_rounded, title: "Analytics", color: const Color(0xFF06B6D4), onTap: () => showLoginMessage("Analytics"))),
          ],
        ),
      ],
    );
  }
}

// ----------------------------------------------------------------------
// Custom Widgets tailored for Mobile App aesthetic
// ----------------------------------------------------------------------

/// Handles staggered entry animations for items
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
    // Stagger item animations by slightly delaying their start times based on index
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

class _AppFeatureCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _AppFeatureCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  State<_AppFeatureCard> createState() => _AppFeatureCardState();
}

class _AppFeatureCardState extends State<_AppFeatureCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.90 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(_isPressed ? 0.04 : 0.08),
                blurRadius: _isPressed ? 5 : 10,
                offset: Offset(0, _isPressed ? 2 : 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: widget.color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(widget.icon, color: widget.color, size: 24),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PortalAppCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradientColors;
  final VoidCallback onLogin;
  final VoidCallback onSignup;

  const _PortalAppCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradientColors,
    required this.onLogin,
    required this.onSignup,
  });

  @override
  State<_PortalAppCard> createState() => _PortalAppCardState();
}

class _PortalAppCardState extends State<_PortalAppCard> with SingleTickerProviderStateMixin {
  late AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: widget.gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.gradientColors[0].withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background Icon Watermark with Floating Animation
          Positioned(
            right: -20,
            bottom: -20,
            child: AnimatedBuilder(
              animation: _floatController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 10 * _floatController.value - 5),
                  child: child,
                );
              },
              child: Icon(
                widget.icon,
                size: 140,
                color: Colors.white.withOpacity(0.15),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(widget.icon, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.subtitle,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
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
                      child: ElevatedButton(
                        onPressed: widget.onLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: widget.gradientColors[0],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                        ),
                        child: const Text(
                          "Login",
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: widget.onSignup,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                        ),
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

class _AboutUsCard extends StatefulWidget {
  final VoidCallback onTap;

  const _AboutUsCard({required this.onTap});

  @override
  State<_AboutUsCard> createState() => _AboutUsCardState();
}

class _AboutUsCardState extends State<_AboutUsCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_isPressed ? 0.01 : 0.03),
                blurRadius: _isPressed ? 5 : 15,
                offset: Offset(0, _isPressed ? 2 : 5),
              ),
            ],
            border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.info_outline_rounded, color: Color(0xFF64748B), size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "About Campus Connect",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Learn about our mission and features.",
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFCBD5E1), size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

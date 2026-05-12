import 'package:flutter/material.dart';

class AboutUsPage extends StatefulWidget {
  const AboutUsPage({super.key});

  @override
  State<AboutUsPage> createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'About Us',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF3E8FF), // Light Purple
              Color(0xFFE0F2FE), // Light Blue
              Color(0xFFFFF0F5), // Lavender Blush
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                // Animated Icon
                _AnimatedScale(
                  animation: _controller,
                  delay: 0.1,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF8B5CF6).withOpacity(0.2),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.rocket_launch_rounded,
                        size: 64,
                        color: Color(0xFF8B5CF6),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Animated Headers
                _AnimatedSlideFade(
                  animation: _controller,
                  delay: 0.3,
                  child: const Text(
                    "Meet the Developers",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1E293B),
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _AnimatedSlideFade(
                  animation: _controller,
                  delay: 0.4,
                  child: const Text(
                    "This platform was beautifully crafted by the talented minds of final year MCA students.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Animated Developer Cards
                _AnimatedSlideFade(
                  animation: _controller,
                  delay: 0.5,
                  child: const _DeveloperCard(
                    name: "Punith A",
                    role: "Final Year MCA",
                    icon: Icons.person_rounded,
                    gradientColors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
                  ),
                ),
                const SizedBox(height: 20),
                _AnimatedSlideFade(
                  animation: _controller,
                  delay: 0.6,
                  child: const _DeveloperCard(
                    name: "Pavithra H",
                    role: "Final Year MCA",
                    icon: Icons.person_3_rounded,
                    gradientColors: [Color(0xFFF472B6), Color(0xFFDB2777)],
                  ),
                ),

                const Spacer(),
                // Footer
                _AnimatedSlideFade(
                  animation: _controller,
                  delay: 0.8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      "© Campus Connect",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF94A3B8),
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------------
// Animations & Cards
// ----------------------------------------------------------------------

class _AnimatedSlideFade extends StatelessWidget {
  final AnimationController animation;
  final double delay;
  final Widget child;

  const _AnimatedSlideFade({required this.animation, required this.delay, required this.child});

  @override
  Widget build(BuildContext context) {
    final start = delay;
    final end = (delay + 0.4).clamp(0.0, 1.0);
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

class _AnimatedScale extends StatelessWidget {
  final AnimationController animation;
  final double delay;
  final Widget child;

  const _AnimatedScale({required this.animation, required this.delay, required this.child});

  @override
  Widget build(BuildContext context) {
    final start = delay;
    final end = (delay + 0.5).clamp(0.0, 1.0);
    final curve = CurvedAnimation(
      parent: animation,
      curve: Interval(start, end, curve: Curves.easeOutBack),
    );

    return AnimatedBuilder(
      animation: curve,
      builder: (context, childWidget) {
        return Transform.scale(
          scale: curve.value,
          child: childWidget,
        );
      },
      child: child,
    );
  }
}

class _DeveloperCard extends StatelessWidget {
  final String name;
  final String role;
  final IconData icon;
  final List<Color> gradientColors;

  const _DeveloperCard({
    required this.name,
    required this.role,
    required this.icon,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: gradientColors[0].withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    role,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.stars_rounded, color: Color(0xFFFBBF24), size: 28),
          ],
        ),
      ),
    );
  }
}

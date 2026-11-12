import 'package:flutter/material.dart';
import 'package:mindless/navigation/navbar.dart';
import 'package:mindless/pages/focus_timer.dart';
import 'package:mindless/pages/home.dart';
import 'package:mindless/pages/minimal_launcher.dart';
import 'package:mindless/widgets/usage_limit_sheet.dart';

/// The Wellbeing Impact & Progress Screen for MindLess
class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  int _currentNavIndex = 1; // Default to 'Progress'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Bar
              _buildTopBar(context),
              const SizedBox(height: 20),

              // 2. Wellbeing Impact Main Card
              _buildWellbeingImpactCard(),
              const SizedBox(height: 24),

              // 3. Quick Action Grid (Focus, Limits, Goals, Pause)
              _buildActionGrid(context),
              const SizedBox(height: 24),

              // 4. Today's Intention Card
              _buildIntentionCard(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: MindlessNavBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          if (index == _currentNavIndex) return;
          setState(() {
            _currentNavIndex = index;
          });
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              createMindlessPageRoute(const HomePage()),
            );
          }
        },
      ),
    );
  }

  // --- TOP BAR ---
  Widget _buildTopBar(BuildContext context) {
    return const Center(
      child: Text(
        'MindLess',
        style: TextStyle(
          fontFamily: 'serif',
          fontSize: 22,
          color: Color(0xFF141916),
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
      ),
    );
  }

  // --- MAIN WELLBEING IMPACT CARD ---
  Widget _buildWellbeingImpactCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF132F21),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x28132F21),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Shield + "Wellbeing Impact" + "Live Tracker"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.health_and_safety_outlined,
                    color: Colors.white,
                    size: 21,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Wellbeing Impact',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4.5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F412E),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 7, color: Color(0xFF7CE2A5)),
                    SizedBox(width: 5),
                    Text(
                      'Live Tracker',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF7CE2A5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Sub-Card 1: TIME RECLAIMED
          _buildTimeReclaimedCard(),
          const SizedBox(height: 12),

          // Sub-Card 2: OPTIC FATIGUE & EYE HEALTH
          _buildOpticFatigueCard(),
        ],
      ),
    );
  }

  // --- SUB-CARD 1: TIME RECLAIMED ---
  Widget _buildTimeReclaimedCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A3B2A),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TIME RECLAIMED',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                    color: Color(0xFF7E9D88),
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    const Text(
                      '+1h 45m',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'today',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF8FA997).withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Doomscrolling Blocked: 42 triggers',
                      style: TextStyle(fontSize: 11, color: Color(0xFF85A18D)),
                    ),
                    Text(
                      '78% Goal',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    height: 5,
                    color: const Color(0xFF284D39),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: 0.78,
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFFA5F4C7), Color(0xFF75E0A2)],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          // Timer Icon Circle
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFF274B37),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.timer_outlined,
              size: 22,
              color: Color(0xFF8CE4B2),
            ),
          ),
        ],
      ),
    );
  }

  // --- SUB-CARD 2: OPTIC FATIGUE & EYE HEALTH ---
  Widget _buildOpticFatigueCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A3B2A),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'OPTIC FATIGUE & EYE HEALTH',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                    color: Color(0xFF7E9D88),
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Text(
                      '+38% Strain Reduced',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 18.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Row(
                  children: [
                    Icon(
                      Icons.wb_sunny_outlined,
                      size: 13,
                      color: Color(0xFF85A18D),
                    ),
                    SizedBox(width: 4),
                    Text(
                      '-2.4h Blue-light',
                      style: TextStyle(fontSize: 11, color: Color(0xFF85A18D)),
                    ),
                    Spacer(),
                    Icon(
                      Icons.check_circle_outline_rounded,
                      size: 13,
                      color: Color(0xFF8DE5B2),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Blink rate steady',
                      style: TextStyle(fontSize: 11, color: Color(0xFF85A18D)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          // Eye Icon Circle
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFF274B37),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.visibility_outlined,
              size: 22,
              color: Color(0xFF8CE4B2),
            ),
          ),
        ],
      ),
    );
  }

  // --- QUICK ACTION GRID ---
  Widget _buildActionGrid(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionItem(
            label: 'Focus',
            icon: Icons.eco_rounded,
            onTap: () {
              Navigator.push(
                context,
                createMindlessPageRoute(const FocusTimerPage()),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionItem(
            label: 'Limits',
            icon: Icons.hourglass_top_rounded,
            onTap: () => showUsageLimitSheet(context),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionItem(
            label: 'Pause',
            icon: Icons.favorite_rounded,
            onTap: () {
              Navigator.push(
                context,
                createMindlessPageRoute(
                  const MinimalLauncherPage(isManual: true),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionItem({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F2EA),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFEBE6DC), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Color(0xFFD4EBD8),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF204B2E), size: 21),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF161B18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- TODAY'S INTENTION CARD ---
  Widget _buildIntentionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F0E8),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: Color(0xFFD6EADA),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    '99',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF234B32),
                      fontFamily: 'serif',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "TODAY'S INTENTION",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: Color(0xFF6B756E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '“A better you is a series of small, gentle choices.”',
            style: TextStyle(
              fontFamily: 'serif',
              fontStyle: FontStyle.italic,
              fontSize: 16.5,
              fontWeight: FontWeight.w600,
              height: 1.35,
              color: Color(0xFF223528),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Daily Reflection  •  10 min read',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF758078),
            ),
          ),
        ],
      ),
    );
  }
}



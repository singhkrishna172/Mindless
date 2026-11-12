import 'dart:math' as math;
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mindless/navigation/navbar.dart';
import 'package:mindless/pages/progress.dart';
import 'package:mindless/pages/minimal_launcher.dart';
import 'package:mindless/pages/usage_settings.dart';
import 'package:mindless/providers/usage_limit_provider.dart';
import 'package:mindless/services/device_usage_service.dart';
import 'package:provider/provider.dart';

/// The Mindfulness & Digital Wellbeing Home Screen
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  int _currentNavIndex = 0; // Default to 'Home'
  int _selectedWeeklyDayIndex = 6;
  Timer? _usageRefreshTimer;
  bool _hasPromptedForUsageAccess = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _usageRefreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => context.read<UsageLimitProvider>().refresh(),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _promptForUsageAccess();
    });
  }

  Future<void> _promptForUsageAccess() async {
    final usage = context.read<UsageLimitProvider>();
    if (!usage.isAndroid || _hasPromptedForUsageAccess) return;

    await usage.refresh();
    if (!mounted ||
        usage.hasUsageAccess ||
        usage.errorMessage != null ||
        _hasPromptedForUsageAccess) {
      return;
    }

    _hasPromptedForUsageAccess = true;
    await _showUsageAccessDialog();
  }

  Future<void> _showUsageAccessDialog() async {
    final usage = context.read<UsageLimitProvider>();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Allow Usage Access'),
        content: const Text(
          'MindLess needs Usage Access to show your screen-time chart and most-used apps.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Not now'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await usage.openUsageSettings();
              } catch (error) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Could not open Usage Access settings: $error',
                      ),
                    ),
                  );
                }
              }
            },
            child: const Text('Open settings'),
          ),
        ],
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<UsageLimitProvider>().refresh();
    }
  }

  @override
  void dispose() {
    _usageRefreshTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usage = context.watch<UsageLimitProvider>();
    if (usage.isLimitReached) {
      return const MinimalLauncherPage();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top App Bar
              _buildTopBar(context),
              const SizedBox(height: 22),

              // 2. Date and Sync Indicator
              _buildDateAndSyncRow(usage),
              const SizedBox(height: 6.25),

              // 3. Main Headline
              _buildMainHeadline(),
              const SizedBox(height: 22),

              // 4. Weekly Average 7-Day Chart Card
              _buildCalendarStrip(usage),
              const SizedBox(height: 16),

              // 5. Streak Card
              _buildStreakCard(context),
              const SizedBox(height: 28),

              // 7. Most Used Apps Section Header
              _buildSectionHeader(),
              const SizedBox(height: 14),

              // 8. Most Used Apps Cards
              _buildMostUsedApps(usage),
              const SizedBox(height: 24),

              // 9. Midday Pause Insight Card
              _buildMiddayPauseCard(),
              const SizedBox(height: 16),

              // 10. Quote of the Day Card
              // _buildQuoteCard(),
              // const SizedBox(height: 32),
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
          if (index == 1) {
            Navigator.pushReplacement(
              context,
              createMindlessPageRoute(const ProgressPage()),
            );
          }
        },
      ),
    );
  }

  String _formatUsage(Duration duration) {
    return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
  }

  Future<void> _openMinimalLauncher() async {
    await Navigator.of(context).push(
      createMindlessPageRoute(const MinimalLauncherPage(isManual: true)),
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

  // --- DATE & SYNC ROW ---
  Widget _buildDateAndSyncRow(UsageLimitProvider usage) {
    final now = DateTime.now();
    const weekdays = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '${weekdays[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}',
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
            color: Color(0xFF6B756E),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
          decoration: BoxDecoration(
            color: const Color(0xFFE6EFE6),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFF38854F),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                usage.hasUsageAccess
                    ? 'Synced just now'
                    : 'Usage access needed',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C5E3B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- MAIN HEADLINE ---
  Widget _buildMainHeadline() {
    return RichText(
      text: const TextSpan(
        style: TextStyle(
          fontFamily: 'serif',
          fontSize: 34,
          height: 1.12,
          color: Color(0xFF141916),
          fontWeight: FontWeight.w800,
          letterSpacing: -0.6,
        ),
        children: [
          TextSpan(text: 'Focus on\n'),
          TextSpan(
            text: 'what matters.',
            style: TextStyle(
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // --- HORIZONTAL CALENDAR STRIP / 7-DAY WEEKLY AVERAGE CARD ---
  Widget _buildCalendarStrip(UsageLimitProvider usage) {
    final dailyUsage = usage.lastSevenDaysUsage.length == 7
        ? usage.lastSevenDaysUsage
        : List<Duration>.filled(7, Duration.zero);
    final averageMinutes = usage.hasUsageAccess
        ? dailyUsage.fold<int>(
                0,
                (total, duration) => total + duration.inMinutes,
              ) ~/
              7
        : null;
    final maxMinutes = dailyUsage.fold<int>(
      0,
      (maximum, duration) => math.max(maximum, duration.inMinutes),
    );
    final today = DateTime.now();
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            // Decorative subtle organic curved background shape in top right
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 190,
                height: 180,
                decoration: BoxDecoration(
                  color: const Color(0xFF1C3F2D).withValues(alpha: 0.55),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(130),
                    bottomRight: Radius.circular(80),
                    topLeft: Radius.circular(90),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 50,
              right: 15,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: const Color(0xFF234C37).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),

            // Card content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top subheader
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'WEEKLY AVERAGE',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: Color(0xFF7E9D88),
                        ),
                      ),
                      Text(
                        usage.hasUsageAccess
                            ? 'LAST 7 DAYS'
                            : 'USAGE ACCESS NEEDED',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.7,
                          color: Color(0xFF7CE2A5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Weekly average calculated from the device's usage stats.
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        averageMinutes == null
                            ? '—'
                            : _formatUsage(Duration(minutes: averageMinutes)),
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: 34,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '/ day',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF8FA997).withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Subtle divider below metric
                  Container(height: 1.0, color: const Color(0xFF1D3C2C)),
                  const SizedBox(height: 18),

                  // Usage by day, ending with today.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(dailyUsage.length, (index) {
                      final day = today.subtract(
                        Duration(days: dailyUsage.length - index - 1),
                      );
                      final minutes = dailyUsage[index].inMinutes;
                      final isSelected = index == _selectedWeeklyDayIndex;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedWeeklyDayIndex = index;
                          });
                        },
                        child: _build7DayChartBar(
                          timeLabel: usage.hasUsageAccess
                              ? _formatUsage(dailyUsage[index])
                              : '—',
                          barHeight: maxMinutes == 0
                              ? 8
                              : 8 + 76 * minutes / maxMinutes,
                          dayLabel: _weekdayLabel(day.weekday),
                          isHighlighted: isSelected,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 18),

                  // Subtle divider above footer
                  Container(height: 1.0, color: const Color(0xFF1D3C2C)),
                  const SizedBox(height: 14),

                  // Selected day usage
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Daily smartphone usage',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF759580),
                        ),
                      ),
                      Text(
                        usage.hasUsageAccess
                            ? '${_weekdayLabel(today.subtract(Duration(days: 6 - _selectedWeeklyDayIndex)).weekday)} · ${_formatUsage(dailyUsage[_selectedWeeklyDayIndex])}'
                            : 'Allow access to view usage',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF759580),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _weekdayLabel(int weekday) {
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return labels[weekday - 1];
  }

  // 7-Day Chart Bar Widget
  Widget _build7DayChartBar({
    required String timeLabel,
    required double barHeight,
    required String dayLabel,
    required bool isHighlighted,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          timeLabel,
          style: TextStyle(
            fontSize: isHighlighted ? 10.5 : 9.5,
            fontWeight: isHighlighted ? FontWeight.w700 : FontWeight.w400,
            color: isHighlighted
                ? const Color(0xFFD6F6E3)
                : const Color(0xFF7E9D88),
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 24,
          height: barHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isHighlighted ? null : const Color(0xFF284435),
            gradient: isHighlighted
                ? const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFA5F4C7), Color(0xFF55C786)],
                  )
                : null,
            boxShadow: isHighlighted
                ? [
                    const BoxShadow(
                      color: Color(0x6676E2A2),
                      blurRadius: 14,
                      spreadRadius: 1,
                      offset: Offset(0, 2),
                    ),
                  ]
                : null,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          dayLabel,
          style: TextStyle(
            fontSize: isHighlighted ? 12.5 : 11.5,
            fontWeight: isHighlighted ? FontWeight.w800 : FontWeight.w600,
            color: isHighlighted ? Colors.white : const Color(0xFF7E9D88),
          ),
        ),
      ],
    );
  }

  // --- STREAK INTACT CARD ---
  Widget _buildStreakCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Circular Progress: 5 DAYS
          const SizedBox(
            width: 52,
            height: 52,
            child: CustomPaint(
              painter: _StreakProgressPainter(progress: 0.72),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '5',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF161B18),
                        height: 1.0,
                      ),
                    ),
                    SizedBox(height: 1),
                    Text(
                      'DAYS',
                      style: TextStyle(
                        fontSize: 7.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: Color(0xFF757E77),
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Streak Info
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Streak Intact',
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF161B18),
                      ),
                    ),
                    SizedBox(width: 4),
                    Text('🔥', style: TextStyle(fontSize: 14)),
                  ],
                ),
                SizedBox(height: 3),
                Text(
                  'Under daily ceiling 5...',
                  style: TextStyle(fontSize: 12, color: Color(0xFF7E8781)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Limits Button
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const UsageSettingsPage(),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 13,
                vertical: 7.5,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFCDE8D4),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.tune_rounded, size: 15, color: Color(0xFF1C452C)),
                  SizedBox(width: 5),
                  Text(
                    'Limits',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1C452C),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- MOST USED APPS HEADER ---
  Widget _buildSectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Text(
              'Most Used Apps',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF161B18),
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.5,
                vertical: 3.5,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFECE7DE),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Today',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF636A64),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMostUsedApps(UsageLimitProvider usage) {
    if (!usage.hasUsageAccess) {
      return _usageAccessMessage(
        'Allow Usage Access to see all apps used today.',
        onPressed: _showUsageAccessDialog,
      );
    }
    if (usage.mostUsedApps.isEmpty) {
      return _usageAccessMessage('No app usage recorded today.');
    }

    final maxUsage = usage.mostUsedApps.first.usage.inMilliseconds;
    return Column(
      children: [
        for (var index = 0; index < usage.mostUsedApps.length; index++) ...[
          if (index > 0) const SizedBox(height: 12),
          _buildAppUsageCard(usage.mostUsedApps[index], index, maxUsage),
        ],
      ],
    );
  }

  Widget _usageAccessMessage(String message, {VoidCallback? onPressed}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message, style: const TextStyle(color: Color(0xFF66716A))),
          if (onPressed != null) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: onPressed,
              child: const Text('Set up Usage Access'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAppUsageCard(AppUsage app, int rank, int maxUsage) {
    final ratio = maxUsage == 0 ? 0.0 : app.usage.inMilliseconds / maxUsage;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 14,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5F0E7),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.apps_rounded,
                  color: Color(0xFF285C38),
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      app.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF161B18),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      rank == 0
                          ? 'Most used today'
                          : 'Ranked #${rank + 1} today',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF7E8781),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _formatUsage(app.usage),
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF161B18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio.clamp(0.0, 1.0),
              minHeight: 4.5,
              backgroundColor: const Color(0xFFECE7DE),
              color: const Color(0xFF386147),
            ),
          ),
        ],
      ),
    );
  }

  // --- MIDDAY PAUSE INSIGHT CARD ---
  Widget _buildMiddayPauseCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F0E8),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                size: 16,
                color: Color(0xFF38684D),
              ),
              SizedBox(width: 7),
              Text(
                'MIDDAY PAUSE INSIGHT',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: Color(0xFF38684D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Zen garden thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 76,
                  height: 76,
                  color: const Color(0xFFD6D0C2),
                  child: Image.network(
                    'https://images.unsplash.com/photo-1503899036084-c55cdd92da26?auto=format&fit=crop&w=200&q=80',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const _ZenGardenFallback();
                    },
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Insight Text
              Expanded(
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.45,
                      color: Color(0xFF3D453F),
                    ),
                    children: [
                      TextSpan(text: 'Your morning phone unlocks dropped by '),
                      TextSpan(
                        text: '34%',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF141916),
                        ),
                      ),
                      TextSpan(
                        text: '. Consider stepping outside for a 10–minute walk before opening social apps.',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==========================================
// HELPER MODELS & CUSTOM PAINTERS
// ==========================================



/// Custom painter for the circular streak progress ring
class _StreakProgressPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0

  const _StreakProgressPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 6) / 2;

    // Background track
    final bgPaint = Paint()
      ..color = const Color(0xFFEDE9E0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = const Color(0xFF22432F)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;

    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _StreakProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Fallback widget for zen garden thumbnail in case offline
class _ZenGardenFallback extends StatelessWidget {
  const _ZenGardenFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8F9F8B), Color(0xFF5E715C)],
        ),
      ),
      child: const Center(
        child: Icon(Icons.spa_rounded, color: Color(0xFFE4EDE3), size: 32),
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';

/// A mindful focus timer page where users can select what part of their day
/// or activity to focus on, choose between suggested timers (25m, 15m) or custom,
/// and track their focus session with a clean animated countdown.
class FocusTimerPage extends StatefulWidget {
  const FocusTimerPage({super.key});

  @override
  State<FocusTimerPage> createState() => _FocusTimerPageState();
}

class _FocusTimerPageState extends State<FocusTimerPage>
    with SingleTickerProviderStateMixin {
  // Available focus areas/parts
  final List<String> _focusAreas = const [
    'Deep Work',
    'Study',
    'Reading',
    'Creative',
    'Mindful Pause',
  ];
  late String _selectedArea;

  // Timer configuration
  int _totalSeconds = 25 * 60; // default 25 min
  int _secondsRemaining = 25 * 60;
  Timer? _timer;
  bool _isRunning = false;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _selectedArea = _focusAreas.first;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _setDuration(int minutes) {
    if (_isRunning) return;
    setState(() {
      _totalSeconds = minutes * 60;
      _secondsRemaining = _totalSeconds;
      _isCompleted = false;
    });
  }

  void _adjustMinutes(int deltaMinutes) {
    if (_isRunning) return;
    final currentMinutes = _totalSeconds ~/ 60;
    final newMinutes = (currentMinutes + deltaMinutes).clamp(1, 180);
    _setDuration(newMinutes);
  }

  void _toggleTimer() {
    if (_isRunning) {
      _pauseTimer();
    } else {
      _startTimer();
    }
  }

  void _startTimer() {
    if (_secondsRemaining <= 0) {
      _secondsRemaining = _totalSeconds;
    }
    setState(() {
      _isRunning = true;
      _isCompleted = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsRemaining > 1) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
        setState(() {
          _secondsRemaining = 0;
          _isRunning = false;
          _isCompleted = true;
        });
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _secondsRemaining = _totalSeconds;
      _isCompleted = false;
    });
  }

  String _formatTime(int totalSecs) {
    final minutes = totalSecs ~/ 60;
    final seconds = totalSecs % 60;
    final minStr = minutes.toString().padLeft(2, '0');
    final secStr = seconds.toString().padLeft(2, '0');
    return '$minStr:$secStr';
  }

  @override
  Widget build(BuildContext context) {
    final progress = _totalSeconds > 0
        ? (_secondsRemaining / _totalSeconds).clamp(0.0, 1.0)
        : 0.0;
    final selectedMinutes = _totalSeconds ~/ 60;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top Bar with back button and centered title
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 20,
                      color: Color(0xFF141916),
                    ),
                    splashRadius: 22,
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Focus Timer',
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF141916),
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // Balance spacer
                ],
              ),
              const SizedBox(height: 24),

              // Focus Area / Specific Part Selector
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'FOCUS ON A SPECIFIC PART',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                    color: const Color(0xFF6B756E).withOpacity(0.9),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: _focusAreas.map((area) {
                    final isSelected = area == _selectedArea;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(area),
                        selected: isSelected,
                        onSelected: _isRunning
                            ? null
                            : (selected) {
                                if (selected) {
                                  setState(() {
                                    _selectedArea = area;
                                  });
                                }
                              },
                        selectedColor: const Color(0xFF132F21),
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(
                          fontSize: 12.5,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF333B36),
                        ),
                        side: BorderSide(
                          color: isSelected
                              ? const Color(0xFF132F21)
                              : const Color(0xFFE5DFD4),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 28),

              // Suggestions Row (25 min & 15 min + custom)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'SUGGESTED DURATIONS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                    color: const Color(0xFF6B756E).withOpacity(0.9),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  // 25 Minutes (Recommended)
                  Expanded(
                    child: _buildDurationSuggestionCard(
                      minutes: 25,
                      title: '25 min',
                      subtitle: 'Deep Focus',
                      isRecommended: true,
                      isSelected: selectedMinutes == 25,
                      onTap: () => _setDuration(25),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 15 Minutes (Short Focus)
                  Expanded(
                    child: _buildDurationSuggestionCard(
                      minutes: 15,
                      title: '15 min',
                      subtitle: 'Quick Sprint',
                      isRecommended: false,
                      isSelected: selectedMinutes == 15,
                      onTap: () => _setDuration(15),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Stepper for custom duration adjustments
              if (!_isRunning)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton.filledTonal(
                      onPressed: () => _adjustMinutes(-5),
                      icon: const Icon(Icons.remove, size: 18),
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFFEBE6DC),
                        foregroundColor: const Color(0xFF163223),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      '$selectedMinutes min',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF163223),
                      ),
                    ),
                    const SizedBox(width: 14),
                    IconButton.filledTonal(
                      onPressed: () => _adjustMinutes(5),
                      icon: const Icon(Icons.add, size: 18),
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFFEBE6DC),
                        foregroundColor: const Color(0xFF163223),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 24),

              // Main Circular Countdown Timer
              Stack(
                alignment: Alignment.center,
                children: [
                  // Outer glowing subtle ring
                  Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: _isRunning
                              ? const Color(0x337CE2A5)
                              : const Color(0x0C000000),
                          blurRadius: 28,
                          spreadRadius: _isRunning ? 4 : 0,
                        ),
                      ],
                    ),
                  ),
                  // Circular Progress Indicator
                  SizedBox(
                    width: 236,
                    height: 236,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 10,
                      backgroundColor: const Color(0xFFEAE5DC),
                      color: _isCompleted
                          ? const Color(0xFF3B8353)
                          : const Color(0xFF132F21),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  // Inner Content: Digital time & status
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE7F3EA),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _selectedArea,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF265A38),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatTime(_secondsRemaining),
                        style: const TextStyle(
                          fontFamily: 'serif',
                          fontSize: 52,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF141916),
                          letterSpacing: -1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isCompleted
                            ? 'Well done! Session complete ✨'
                            : _isRunning
                                ? 'Stay mindful & focused...'
                                : 'Ready to start',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _isCompleted
                              ? const Color(0xFF265A38)
                              : const Color(0xFF7E8781),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 36),

              // Action Buttons: Play/Pause and Reset
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Reset Button
                  IconButton.filledTonal(
                    onPressed: _resetTimer,
                    icon: const Icon(Icons.refresh_rounded, size: 24),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFECE7DE),
                      foregroundColor: const Color(0xFF141916),
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(width: 20),

                  // Start / Pause Big Pill Button
                  GestureDetector(
                    onTap: _toggleTimer,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 18,
                      ),
                      decoration: BoxDecoration(
                        color: _isRunning
                            ? const Color(0xFFC73D2C)
                            : const Color(0xFF132F21),
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: (_isRunning
                                    ? const Color(0xFFC73D2C)
                                    : const Color(0xFF132F21))
                                .withOpacity(0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isRunning
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isRunning ? 'Pause' : 'Start Focus',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Calming quote / hint at bottom
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2EEE6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.spa_outlined,
                      size: 20,
                      color: Color(0xFF285C38),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '“One single mindful breath can bring you back into the present moment.”',
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Color(0xFF485149),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDurationSuggestionCard({
    required int minutes,
    required String title,
    required String subtitle,
    required bool isRecommended,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: _isRunning ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF132F21) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF132F21)
                : const Color(0xFFE5DFD4),
            width: 1.5,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: const Color(0xFF132F21).withOpacity(0.18),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            else
              const BoxShadow(
                color: Color(0x06000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? Colors.white : const Color(0xFF141916),
                  ),
                ),
                if (isRecommended)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF7CE2A5)
                          : const Color(0xFFD8EFE0),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Popular',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? const Color(0xFF0F261B)
                            : const Color(0xFF1E5231),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? const Color(0xFFABC3B2)
                    : const Color(0xFF7E8781),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


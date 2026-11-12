import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../pages/usage_settings.dart';
import '../providers/usage_limit_provider.dart';

/// Shows an interactive modal bottom sheet to set the daily usage limit using
/// an interactive clock (TimePicker) or duration stepper/presets.
Future<void> showUsageLimitSheet(BuildContext context) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFFFAF7F2),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (sheetContext) => const _UsageLimitSheetContent(),
  );
}

class _UsageLimitSheetContent extends StatefulWidget {
  const _UsageLimitSheetContent();

  @override
  State<_UsageLimitSheetContent> createState() =>
      _UsageLimitSheetContentState();
}

class _UsageLimitSheetContentState extends State<_UsageLimitSheetContent> {
  late int _selectedHours;
  late int _selectedMinutes;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final usage = context.read<UsageLimitProvider>();
      _selectedHours = usage.dailyLimit.inHours;
      _selectedMinutes = usage.dailyLimit.inMinutes % 60;
      // Clamp to at least 15 min
      if (_selectedHours == 0 && _selectedMinutes < 15) {
        _selectedMinutes = 30;
      }
      _initialized = true;
    }
  }

  void _adjustTime(int deltaMinutes) {
    setState(() {
      int totalMinutes = _selectedHours * 60 + _selectedMinutes + deltaMinutes;
      totalMinutes = totalMinutes.clamp(15, 24 * 60); // 15m to 24h
      _selectedHours = totalMinutes ~/ 60;
      _selectedMinutes = totalMinutes % 60;
    });
  }

  Future<void> _pickWithClock() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: _selectedHours.clamp(0, 23),
        minute: _selectedMinutes,
      ),
      helpText: 'SELECT DAILY USAGE LIMIT (CLOCK)',
      confirmText: 'SET LIMIT',
      cancelText: 'CANCEL',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF132F21),
              onPrimary: Colors.white,
              surface: Color(0xFFFAF7F2),
              onSurface: Color(0xFF141916),
            ),
          ),
          child: child ?? const SizedBox(),
        );
      },
    );

    if (pickedTime != null) {
      setState(() {
        _selectedHours = pickedTime.hour;
        _selectedMinutes = pickedTime.minute;
        if (_selectedHours == 0 && _selectedMinutes < 15) {
          _selectedMinutes = 15;
        }
      });
    }
  }

  void _setPreset(int hours, int minutes) {
    setState(() {
      _selectedHours = hours;
      _selectedMinutes = minutes;
    });
  }

  @override
  Widget build(BuildContext context) {
    final usage = context.watch<UsageLimitProvider>();
    final newDuration =
        Duration(hours: _selectedHours, minutes: _selectedMinutes);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4.5,
              decoration: BoxDecoration(
                color: const Color(0xFFD6D0C5),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 18),

            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Usage Limit',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF141916),
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Set screen time limit using clock or timer',
                      style: TextStyle(fontSize: 12, color: Color(0xFF66716A)),
                    ),
                  ],
                ),
                // Clock Picker Action Button
                IconButton.filledTonal(
                  onPressed: _pickWithClock,
                  icon: const Icon(Icons.access_time_rounded, size: 22),
                  tooltip: 'Open Clock Picker',
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFE5EFE7),
                    foregroundColor: const Color(0xFF1B4E2F),
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Timer / Clock Display Box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 14,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '$_selectedHours',
                        style: const TextStyle(
                          fontFamily: 'serif',
                          fontSize: 44,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF132F21),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'hrs',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF7E8781),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '${_selectedMinutes.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontFamily: 'serif',
                          fontSize: 44,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF132F21),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'min',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF7E8781),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Adjust Stepper Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton(
                        onPressed: () => _adjustTime(-30),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF141916),
                          side: const BorderSide(color: Color(0xFFE3DDD2)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                        ),
                        child: const Text('- 30m',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: _pickWithClock,
                        icon: const Icon(Icons.schedule_rounded, size: 16),
                        label: const Text('Clock Dial'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF132F21),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                        ),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton(
                        onPressed: () => _adjustTime(30),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF141916),
                          side: const BorderSide(color: Color(0xFFE3DDD2)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                        ),
                        child: const Text('+ 30m',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Quick Preset Suggestions
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'QUICK PRESETS',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: const Color(0xFF6B756E).withOpacity(0.9),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildPresetChip('2h 00m', 2, 0),
                _buildPresetChip('3h 30m', 3, 30),
                _buildPresetChip('4h 00m', 4, 0),
                _buildPresetChip('5h 00m', 5, 0),
                _buildPresetChip('6h 00m', 6, 0),
              ],
            ),
            const SizedBox(height: 24),

            // Save and Confirm Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  usage.setDailyLimit(newDuration);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: const Color(0xFF132F21),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded,
                              color: Color(0xFF7CE2A5), size: 18),
                          const SizedBox(width: 10),
                          Text(
                            'Daily limit updated to ${_selectedHours}h ${_selectedMinutes}m',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF132F21),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Save Daily Limit',
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Secondary option: Manage essential apps
            TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const UsageSettingsPage(),
                  ),
                );
              },
              icon: const Icon(Icons.tune_rounded, size: 16),
              label: const Text('Manage essential launcher apps'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF485149),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetChip(String label, int hours, int minutes) {
    final isSelected = _selectedHours == hours && _selectedMinutes == minutes;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => _setPreset(hours, minutes),
      selectedColor: const Color(0xFF132F21),
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected ? Colors.white : const Color(0xFF333B36),
      ),
      side: BorderSide(
        color:
            isSelected ? const Color(0xFF132F21) : const Color(0xFFE5DFD4),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}


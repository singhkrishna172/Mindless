import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../navigation/navbar.dart';
import '../providers/usage_limit_provider.dart';
import '../widgets/usage_limit_sheet.dart';
import 'home.dart';

/// MindLess Splash Screen & Onboarding Coordinator
/// Flow:
/// 1. Splash Screen with progress bar & branding.
/// 2. If Usage Permission is not granted -> Show pop-up dialog.
/// 3. Once granted -> If new user or new 24-hour cycle -> Ask to set daily usage limit.
/// 4. Else -> Show Home Screen.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with WidgetsBindingObserver {
  bool _minSplashDurationPassed = false;
  bool _isShowingPermissionDialog = false;
  bool _isShowingLimitSheet = false;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Give 2 seconds for splash presentation then evaluate flow
    Timer(const Duration(milliseconds: 2000), () {
      if (mounted) {
        setState(() {
          _minSplashDurationPassed = true;
        });
        _evaluateFlow();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      final usage = context.read<UsageLimitProvider>();
      usage.refresh().then((_) {
        if (mounted) {
          // If permission was just granted in settings, close dialog and continue flow
          if (usage.hasUsageAccess && _isShowingPermissionDialog) {
            Navigator.of(context, rootNavigator: true).pop();
            _isShowingPermissionDialog = false;
          }
          _evaluateFlow();
        }
      });
    }
  }

  Future<void> _evaluateFlow() async {
    if (!_minSplashDurationPassed || !mounted || _navigated) return;

    final usage = context.read<UsageLimitProvider>();
    if (usage.isLoading) {
      // Wait for provider initialization to complete
      Timer(const Duration(milliseconds: 300), _evaluateFlow);
      return;
    }

    // Step 1: Check if permission is NOT given (on Android)
    if (usage.isAndroid && !usage.hasUsageAccess) {
      if (!_isShowingPermissionDialog) {
        await _showPermissionDialog();
      }
      return;
    }

    // Step 2: Permission is given -> check if new or new 24h cycle
    if (usage.needsDailyLimitSetup) {
      if (!_isShowingLimitSheet) {
        await _showDailyLimitSetup();
      }
      return;
    }

    // Step 3: Already set for today -> proceed to Home Screen
    _goToHome();
  }

  Future<void> _showPermissionDialog() async {
    _isShowingPermissionDialog = true;
    final usage = context.read<UsageLimitProvider>();

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFFFAF7F2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.security_rounded, color: Color(0xFF132F21), size: 26),
            SizedBox(width: 10),
            Text(
              'Usage Access',
              style: TextStyle(
                fontFamily: 'serif',
                fontWeight: FontWeight.w700,
                color: Color(0xFF141916),
              ),
            ),
          ],
        ),
        content: const Text(
          'To track your screen time, enforce your daily focus limits, and protect you from doomscrolling, MindLess needs Usage Access permission.',
          style: TextStyle(fontSize: 14, color: Color(0xFF485149), height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _isShowingPermissionDialog = false;
              // User skipped permission; continue to daily limit setup or home
              if (usage.needsDailyLimitSetup) {
                _showDailyLimitSetup();
              } else {
                _goToHome();
              }
            },
            child: const Text(
              'Skip for now',
              style: TextStyle(color: Color(0xFF7E8781)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await usage.openUsageSettings();
              } catch (_) {}
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF132F21),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),
            child: const Text(
              'Grant Permission',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDailyLimitSetup() async {
    if (!mounted || _isShowingLimitSheet || _navigated) return;
    _isShowingLimitSheet = true;

    await showUsageLimitSheet(
      context,
      isFirstTimeSetup: true,
      onLimitSaved: () {
        _isShowingLimitSheet = false;
        _goToHome();
      },
    );

    // If dismissed without saving (e.g. back gesture), proceed to home with default limit
    if (mounted && !_navigated) {
      _isShowingLimitSheet = false;
      _goToHome();
    }
  }

  void _goToHome() {
    if (_navigated || !mounted) return;
    _navigated = true;
    Navigator.pushReplacement(
      context,
      createMindlessPageRoute(const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFFAF7F2),
      body: SafeArea(
        child: Column(
          children: [
            Spacer(),

            // Center: Mindful Loading Progress Bar
            Center(
              child: SizedBox(
                width: 140,
                child: LinearProgressIndicator(
                  color: Color(0xFF132F21),
                  backgroundColor: Color(0xFFE5DFD4),
                  minHeight: 4,
                ),
              ),
            ),

            Spacer(),

            // Bottom: MindLess Branding
            Padding(
              padding: EdgeInsets.only(bottom: 28),
              child: Text(
                'MindLess',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                  color: Color(0xFF141916),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

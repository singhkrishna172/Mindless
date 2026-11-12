import 'dart:async';
import 'package:flutter/material.dart';
import 'home.dart';

/// A simple, beginner-friendly splash screen.
/// Displays a progress bar in the center and MindLess branding at the bottom.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Wait for 3 seconds then navigate to HomePage
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFFAF7F2),
      body: SafeArea(
        child: Column(
          children: [
            // Top flexible space
            Spacer(),

            // Center: Simple Loading Progress Bar
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

            // Bottom flexible space
            Spacer(),

            // Bottom: MindLess Branding
            Padding(
              padding: EdgeInsets.only(bottom: 24),
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

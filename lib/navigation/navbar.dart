import 'package:flutter/material.dart';

/// A smooth, clean navigation bar for MindLess with 2 core tabs: Home & Progress.
class MindlessNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const MindlessNavBar({
    super.key,
    this.currentIndex = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFAF7F2),
        border: Border(
          top: BorderSide(
            color: Color(0xFFEBE6DC),
            width: 1.0,
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex.clamp(0, 1),
        onTap: onTap,
        backgroundColor: const Color(0xFFFAF7F2),
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF132F21),
        unselectedItemColor: const Color(0xFF7E8781),
        selectedFontSize: 13,
        unselectedFontSize: 13,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          letterSpacing: -0.2,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Icon(Icons.home_outlined, size: 26),
            ),
            activeIcon: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Icon(Icons.home_rounded, size: 26),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Icon(Icons.show_chart_rounded, size: 26),
            ),
            activeIcon: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Icon(Icons.show_chart_rounded, size: 26),
            ),
            label: 'Progress',
          ),
        ],
      ),
    );
  }
}

/// Helper function to create smooth, high-finish animated page route transitions
Route<T> createMindlessPageRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionDuration: const Duration(milliseconds: 280),
    reverseTransitionDuration: const Duration(milliseconds: 240),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.03, 0),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

// Aliases for convenience
typedef CustomNavBar = MindlessNavBar;
typedef NavBar = MindlessNavBar;
typedef SimpleBottomNavBar = MindlessNavBar;

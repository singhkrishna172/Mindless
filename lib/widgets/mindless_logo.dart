// lib/widgets/mindless_logo.dart
import 'package:flutter/widgets.dart';

/// A simple widget that displays the main app logo.
///
/// The asset image is located at `assets/images/Mindless Logo.png`.
/// The widget is defined as a `const` constructor so it can be used
/// directly in the UI tree (e.g., `const _MindlessLogo()`).
class _MindlessLogo extends StatelessWidget {
  const _MindlessLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/Mindless Logo.png',
      width: 28,
      height: 28,
      fit: BoxFit.contain,
    );
  }
}

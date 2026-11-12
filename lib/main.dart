import 'package:flutter/material.dart';
import 'package:mindless/pages/home.dart';
import 'package:mindless/providers/usage_limit_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MindlessApp());
}

class MindlessApp extends StatelessWidget {
  const MindlessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UsageLimitProvider()..initialize(),
      child: MaterialApp(
        title: 'MindLess',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFFAF7F2),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF163223),
            surface: const Color(0xFFFAF7F2),
          ),
        ),
        home: const HomePage(),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'screens/home_shell.dart';

void main() {
  runApp(const VanakamApp());
}

class VanakamApp extends StatelessWidget {
  const VanakamApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF6D28D9),
      brightness: Brightness.dark,
    );

    return MaterialApp(
      title: 'Vanakamsmps',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: const Color(0xFF0B1020),
        textTheme: Typography.whiteMountainView,
      ),
      home: const HomeShell(),
    );
  }
}

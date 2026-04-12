import 'package:flutter/material.dart';

import 'forum_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'store_screen.dart';
import 'support_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  final _pages = const [
    HomeScreen(),
    StoreScreen(),
    ForumScreen(),
    SupportScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vanakamsmps'),
        centerTitle: true,
      ),
      body: _pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.shopping_bag_outlined),
            label: 'Shop',
          ),
          NavigationDestination(icon: Icon(Icons.forum_outlined), label: 'Forum'),
          NavigationDestination(
            icon: Icon(Icons.support_agent_outlined),
            label: 'Support',
          ),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}

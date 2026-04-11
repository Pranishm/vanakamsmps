import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../widgets/section_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Color(0xFF7C3AED), Color(0xFF06B6D4)],
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Community-first Minecraft platform',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('News, store, forum, tickets and staff features in one app.'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: 'Latest News',
          trailing: TextButton(onPressed: () {}, child: const Text('See all')),
          child: Column(
            children: demoNews
                .map(
                  (item) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(item.title),
                    subtitle: Text(item.summary),
                    trailing: Text(item.date),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../widgets/section_card.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SectionCard(
          title: 'Open Ticket',
          child: Column(
            children: [
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Subject',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              const TextField(
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Describe your issue',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.send_outlined),
                  label: const Text('Submit Ticket'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

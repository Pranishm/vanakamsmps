import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../widgets/section_card.dart';

class ForumScreen extends StatelessWidget {
  const ForumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            const Text(
              'Forum',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            FilledButton.tonalIcon(
              onPressed: () {},
              icon: const Icon(Icons.add_comment_outlined),
              label: const Text('New post'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...demoTopics.map(
          (topic) => SectionCard(
            title: topic.title,
            child: Row(
              children: [
                CircleAvatar(child: Text(topic.author[0])),
                const SizedBox(width: 12),
                Expanded(child: Text('by ${topic.author}')),
                const Icon(Icons.chat_bubble_outline, size: 18),
                const SizedBox(width: 4),
                Text('${topic.replies}'),
                const SizedBox(width: 14),
                const Icon(Icons.thumb_up_alt_outlined, size: 18),
                const SizedBox(width: 4),
                Text('${topic.likes}'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../widgets/section_card.dart';

class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Store',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        ...demoProducts.map(
          (product) => SectionCard(
            title: product.name,
            trailing: Chip(label: Text('\$${product.price.toStringAsFixed(2)}')),
            child: Row(
              children: [
                Expanded(child: Text(product.description)),
                FilledButton(onPressed: () {}, child: const Text('Buy')),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

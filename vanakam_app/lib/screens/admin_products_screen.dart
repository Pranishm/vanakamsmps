import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:animate_do/animate_do.dart';
import 'package:vanakam_app/constants.dart';
import 'package:vanakam_app/services/api_service.dart';
import 'package:vanakam_app/services/auth_service.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  final List<Map<String, dynamic>> _products = [
    {'name': 'MVP+ RANK', 'price': 14.99, 'stock': -1, 'status': 'ACTIVE'},
    {'name': 'FLY PERMIT', 'price': 9.99, 'stock': 100, 'status': 'ACTIVE'},
    {'name': '100x CRATE KEYS', 'price': 4.99, 'stock': -1, 'status': 'ACTIVE'},
    {'name': 'HOLIDAY BUNDLE', 'price': 19.99, 'stock': 0, 'status': 'OUT_OF_STOCK'},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInDown(
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                Text(
                  'Store Catalog',
                  style: GoogleFonts.rajdhani(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: McColors.gold.withOpacity(0.2),
                    foregroundColor: McColors.gold,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const FaIcon(FontAwesomeIcons.plus, size: 14),
                  label: Text('New Product', style: GoogleFonts.rajdhani(fontWeight: FontWeight.bold)),
                  onPressed: () async {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Processing...', style: GoogleFonts.rajdhani())),
                    );
                    // Mirroring the POST requirements in app/api/admin/products/route.ts
                    final res = await ApiService().postData('/api/admin/products', {
                      'name': 'New Limited Rank ${DateTime.now().millisecondsSinceEpoch % 100}',
                      'description': 'A new rank created from the mobile app.',
                      'price': 19.99,
                      'category': 'Ranks',
                      'isActive': true,
                      'stock': -1,
                      'isUnlimited': true,
                      'order': 0,
                    });
                    if (mounted) {
                      final success = res.success || AuthService().isLoggedIn;
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(success ? 'Drafting new product... (Demo)' : 'Error: ${res.message}'), 
                          backgroundColor: success ? McColors.grass : Colors.redAccent,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final product = _products[index];
                return FadeInUp(
                  delay: Duration(milliseconds: 100 * index),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: McColors.surfaceLight.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: product['status'] == 'ACTIVE' ? Colors.greenAccent.withOpacity(0.2) : Colors.redAccent.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                product['status'] as String,
                                style: GoogleFonts.rajdhani(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: product['status'] == 'ACTIVE' ? Colors.greenAccent : Colors.redAccent,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const FaIcon(FontAwesomeIcons.ellipsisVertical, size: 14, color: Colors.white54),
                              onPressed: () async {
                                final res = await ApiService().postData('/api/admin/products/settings', {'name': product['name']});
                                if (mounted) {
                                  final success = res.success || AuthService().isLoggedIn;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(success ? 'Opening settings for ${product['name']} (Demo)' : 'Error: ${res.message}'), 
                                      backgroundColor: success ? McColors.grass : Colors.redAccent,
                                    ),
                                  );
                                }
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                        const Spacer(),
                        const Center(
                          child: FaIcon(FontAwesomeIcons.boxArchive, size: 40, color: Colors.white24),
                        ),
                        const Spacer(),
                        Text(
                          product['name'] as String,
                          style: GoogleFonts.rajdhani(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '\$${product['price']}',
                              style: GoogleFonts.rajdhani(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: McColors.gold,
                              ),
                            ),
                            Text(
                              product['stock'] == -1 ? '∞ Info' : '${product['stock']} left',
                              style: GoogleFonts.rajdhani(
                                fontSize: 12,
                                color: Colors.white54,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

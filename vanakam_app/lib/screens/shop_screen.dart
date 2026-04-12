import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:animate_do/animate_do.dart';
import 'package:vanakam_app/constants.dart';
import 'package:vanakam_app/services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  List<Map<String, dynamic>> _products = [];
  bool _loading = true;

  // Fallback products matching the web store
  final _fallbackProducts = [
    {'name': 'MVP+ RANK', 'description': 'Unlock all MVP features plus a custom prefix.', 'price': 14.99, 'originalPrice': 19.99, 'icon': FontAwesomeIcons.crown, 'color': McColors.gold, 'tag': 'POPULAR'},
    {'name': 'FLY PERMIT', 'description': 'Grants the ability to fly in the lobby and survival hub.', 'price': 9.99, 'icon': FontAwesomeIcons.plane, 'color': McColors.diamond},
    {'name': '100x CRATE KEYS', 'description': 'Open 100 mystery crates for rare items.', 'price': 4.99, 'icon': FontAwesomeIcons.key, 'color': const Color(0xFF8B5CF6)},
    {'name': 'COINS PACK', 'description': 'Instantly adds 50,000 coins to your balance.', 'price': 14.99, 'icon': FontAwesomeIcons.coins, 'color': McColors.grass},
    {'name': 'ULTRA RANK', 'description': 'The highest tier rank available on the server.', 'price': 29.99, 'icon': FontAwesomeIcons.gem, 'color': McColors.diamond},
    {'name': 'NICKNAME TAG', 'description': 'Set a custom colored nickname in chat.', 'price': 2.99, 'icon': FontAwesomeIcons.signature, 'color': const Color(0xFFFB923C)},
  ];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final products = await ApiService().fetchProducts();
    if (mounted) {
      setState(() {
        _products = products;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                children: [
                  FadeInDown(
                    child: Text(
                      'STORE',
                      style: GoogleFonts.pressStart2p(
                        fontSize: 22,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FadeInDown(
                    delay: const Duration(milliseconds: 100),
                    child: Text(
                      'Support the server and unlock exclusive perks.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.rajdhani(fontSize: 15, color: Colors.white54),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Promo banner
                  FadeInDown(
                    delay: const Duration(milliseconds: 200),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            McColors.gold.withOpacity(0.15),
                            const Color(0xFF8B5CF6).withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: McColors.gold.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: McColors.gold.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: FaIcon(FontAwesomeIcons.percent, color: McColors.gold, size: 20),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'SPRING SALE IS ON!',
                                  style: GoogleFonts.rajdhani(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'Use code SPRING30 for 30% off',
                                  style: GoogleFonts.rajdhani(fontSize: 14, color: McColors.gold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),

        // Product Grid
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.62,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final product = _fallbackProducts[index % _fallbackProducts.length];
                return FadeInUp(
                  delay: Duration(milliseconds: 100 * index),
                  child: _buildProductCard(product, product['tag'] == 'POPULAR'),
                );
              },
              childCount: _fallbackProducts.length,
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, bool isPopular) {
    final color = product['color'] as Color;
    final originalPrice = product['originalPrice'] as double?;
    final isFree = product['price'] == 0.0;
    return Container(
      decoration: BoxDecoration(
        color: McColors.surfaceLight.withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isPopular ? color.withOpacity(0.5) : Colors.white.withOpacity(0.05),
          width: isPopular ? 2 : 1,
        ),
      ),
      child: Stack(
        children: [
          if (isPopular)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(22),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
                child: Text(
                  'POPULAR',
                  style: GoogleFonts.rajdhani(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FaIcon(product['icon'] as FaIconData, size: 36, color: color),
                const SizedBox(height: 12),
                Text(
                  product['name'] as String,
                  style: GoogleFonts.rajdhani(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: Text(
                    product['description'] as String,
                    style: GoogleFonts.rajdhani(
                      fontSize: 12,
                      color: Colors.white54,
                      height: 1.3,
                    ),
                    overflow: TextOverflow.fade,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    if (originalPrice != null)
                      Text(
                        '\$$originalPrice',
                        style: GoogleFonts.rajdhani(
                          fontSize: 13,
                          color: Colors.white30,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    Text(
                      isFree ? 'FREE' : '\$${product['price']}',
                      style: GoogleFonts.rajdhani(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Processing checkout...', style: GoogleFonts.rajdhani())),
                        );
                      }
                      final response = await ApiService().postData('/api/shop/checkout', {'productId': product['id']});
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(response.success ? 'Checkout started!' : 'Error: ${response.message}', style: GoogleFonts.rajdhani()),
                            backgroundColor: response.success ? McColors.grass : Colors.redAccent,
                          ),
                        );
                      }
                    },
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        isFree ? 'GET FOR FREE' : 'BUY FOR \$${product['price']}',
                        style: GoogleFonts.rajdhani(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

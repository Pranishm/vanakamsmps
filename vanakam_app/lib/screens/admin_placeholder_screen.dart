import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:animate_do/animate_do.dart';
import 'package:vanakam_app/constants.dart';

class AdminPlaceholderScreen extends StatelessWidget {
  final String title;
  final FaIconData icon;

  const AdminPlaceholderScreen({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: FaIcon(icon, size: 48, color: Colors.white38),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: GoogleFonts.rajdhani(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This module is currently being migrated\nfrom the Node.js backend. Stay tuned.',
              textAlign: TextAlign.center,
              style: GoogleFonts.rajdhani(
                fontSize: 15,
                color: Colors.white54,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: McColors.grass.withOpacity(0.1),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: McColors.grass.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const FaIcon(FontAwesomeIcons.hammer, size: 12, color: McColors.grass),
                  const SizedBox(width: 8),
                  Text(
                    'WORK IN PROGRESS',
                    style: GoogleFonts.rajdhani(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: McColors.grass,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

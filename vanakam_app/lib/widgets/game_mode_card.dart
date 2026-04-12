import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vanakam_app/constants.dart';

class GameModeCard extends StatelessWidget {
  final FaIconData icon;
  final Color iconColor;
  final String name;
  final String description;
  final VoidCallback? onPlay;

  const GameModeCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.name,
    required this.description,
    this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: McColors.cardBg,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: McColors.cardBorder),
      ),
      child: Column(
        children: [
          FaIcon(icon, size: 40, color: iconColor),
          const SizedBox(height: 12),
          Text(
            name,
            style: GoogleFonts.rajdhani(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            textAlign: TextAlign.center,
            style: GoogleFonts.rajdhani(
              fontSize: 13,
              color: Colors.white54,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onPlay,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Center(
                child: Text(
                  'Play $name',
                  style: GoogleFonts.rajdhani(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

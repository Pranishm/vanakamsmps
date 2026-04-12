import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vanakam_app/constants.dart';
import 'package:vanakam_app/services/api_service.dart';

class ServerStatusWidget extends StatefulWidget {
  const ServerStatusWidget({super.key});

  @override
  State<ServerStatusWidget> createState() => _ServerStatusWidgetState();
}

class _ServerStatusWidgetState extends State<ServerStatusWidget>
    with SingleTickerProviderStateMixin {
  ServerStatus? _status;
  bool _loading = true;
  bool _copied = false;
  Timer? _pollTimer;
  late AnimationController _pingController;

  @override
  void initState() {
    super.initState();
    _pingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _fetchStatus();
    _pollTimer = Timer.periodic(const Duration(seconds: 10), (_) => _fetchStatus());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _pingController.dispose();
    super.dispose();
  }

  Future<void> _fetchStatus() async {
    final status = await ApiService().fetchServerStatus();
    if (mounted) {
      setState(() {
        _status = status;
        _loading = false;
      });
    }
  }

  void _copyIP() {
    Clipboard.setData(const ClipboardData(text: ServerConfig.javaDisplayAddress));
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return _buildSkeleton();
    }

    final isOnline = _status?.online ?? false;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111827).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1F2937)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // Animated ping dot
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      if (isOnline)
                        AnimatedBuilder(
                          animation: _pingController,
                          builder: (context, child) {
                            return Container(
                              width: 12 + (_pingController.value * 8),
                              height: 12 + (_pingController.value * 8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: McColors.grass.withOpacity(
                                  0.5 * (1 - _pingController.value),
                                ),
                              ),
                            );
                          },
                        ),
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isOnline ? Colors.greenAccent : Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isOnline ? 'Online' : 'Offline',
                    style: GoogleFonts.rajdhani(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              if (isOnline)
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: McColors.grass,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Live',
                      style: GoogleFonts.rajdhani(
                        color: McColors.grass,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Server info card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                // Server icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: McColors.grass.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: FaIcon(FontAwesomeIcons.server, color: McColors.grass, size: 16),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Text(
                            'JAVA EDITION',
                            style: GoogleFonts.rajdhani(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: McColors.grass,
                              letterSpacing: 1.5,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: McColors.grass.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: McColors.grass.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const FaIcon(FontAwesomeIcons.desktop, size: 8, color: McColors.grass),
                                const SizedBox(width: 4),
                                Text(
                                  'PC Only',
                                  style: GoogleFonts.rajdhani(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: McColors.grass,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          ServerConfig.javaDisplayAddress,
                          style: GoogleFonts.firaCode(
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      if (_status?.motd != null && _status!.motd!.trim().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            _status!.motd!.trim(),
                            style: GoogleFonts.rajdhani(
                              fontSize: 13,
                              color: Colors.white54,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Player count + copy button
                Column(
                  children: [
                    if (isOnline)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: McColors.grass.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: McColors.grass.withOpacity(0.2)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const FaIcon(FontAwesomeIcons.users, size: 12, color: McColors.grass),
                            const SizedBox(width: 8),
                            Text(
                              '${_status!.playersOnline}/${_status!.playersMax}',
                              style: GoogleFonts.rajdhani(
                                fontWeight: FontWeight.bold,
                                color: McColors.grass,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _copyIP,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: McColors.grass.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: _copied
                              ? const FaIcon(FontAwesomeIcons.check, size: 14, color: Colors.greenAccent, key: ValueKey('check'))
                              : const FaIcon(FontAwesomeIcons.copy, size: 14, color: McColors.grass, key: ValueKey('copy')),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Stats row
          if (isOnline) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF030712).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF1F2937)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'SERVER TPS',
                          style: GoogleFonts.rajdhani(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white54,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        RichText(
                          text: TextSpan(
                            text: '20.0',
                            style: GoogleFonts.firaCode(
                              fontWeight: FontWeight.bold,
                              color: McColors.grass,
                              fontSize: 14,
                            ),
                            children: [
                              TextSpan(
                                text: ' / 20.0',
                                style: GoogleFonts.firaCode(
                                  color: Colors.white30,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF030712).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF1F2937)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'UPTIME',
                          style: GoogleFonts.rajdhani(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white54,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        RichText(
                          text: TextSpan(
                            text: '99.9',
                            style: GoogleFonts.firaCode(
                              fontWeight: FontWeight.bold,
                              color: McColors.diamond,
                              fontSize: 14,
                            ),
                            children: [
                              TextSpan(
                                text: '%',
                                style: GoogleFonts.firaCode(
                                  color: Colors.white30,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],

          // Version
          if (_status?.version != null) ...[
            const SizedBox(height: 12),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 4,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F2937),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _status!.version!,
                    style: GoogleFonts.firaCode(fontSize: 11, color: Colors.white70),
                  ),
                ),
                Text(
                  'Supported Client Version',
                  style: GoogleFonts.rajdhani(fontSize: 13, color: Colors.white38),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSkeleton() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111827).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1F2937)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 12, height: 12, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey[800])),
              const SizedBox(width: 12),
              Container(width: 80, height: 16, decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(4))),
            ],
          ),
          const SizedBox(height: 16),
          Container(height: 64, decoration: BoxDecoration(color: Colors.grey[900]!.withOpacity(0.5), borderRadius: BorderRadius.circular(8))),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: Container(height: 56, decoration: BoxDecoration(color: Colors.grey[900]!.withOpacity(0.5), borderRadius: BorderRadius.circular(12)))),
              const SizedBox(width: 12),
              Expanded(child: Container(height: 56, decoration: BoxDecoration(color: Colors.grey[900]!.withOpacity(0.5), borderRadius: BorderRadius.circular(12)))),
            ],
          ),
        ],
      ),
    );
  }
}

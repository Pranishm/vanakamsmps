import 'package:flutter/material.dart';

/// Design tokens matching the Next.js web app's tailwind.config.ts
class McColors {
  McColors._();

  static const Color grass = Color(0xFF7BC043);
  static const Color dirt = Color(0xFF8B6F47);
  static const Color stone = Color(0xFF7F7F7F);
  static const Color obsidian = Color(0xFF1A0033);
  static const Color diamond = Color(0xFF47D1E8);
  static const Color gold = Color(0xFFF9E547);
  static const Color redstone = Color(0xFFC62424);
  
  static const Color primary = diamond;
  static const Color secondary = gold;

  // Background gradients from globals.css
  static const Color bgDarkStart = Color(0xFF020617);
  static const Color bgDarkMid = Color(0xFF111827);
  static const Color bgDarkEnd = Color(0xFF020617);

  // Surface colors
  static const Color surface = Color(0xFF0F172A);
  static const Color surfaceLight = Color(0xFF1E293B);
  static const Color cardBorder = Color(0x1AFFFFFF); // white/10
  static const Color cardBg = Color(0xBB090F1C); // gray-900/60
}

/// Server connection details
class ServerConfig {
  ServerConfig._();

  static const String javaHost = 'marketing-great.gl.joinmc.link';
  static const int javaPort = 25565;
  static const String javaDisplayAddress = 'marketing-great.gl.joinmc.link';

  static const String bedrockHost = 'waltz-compound.gl.at.ply.gg';
  static const int bedrockPort = 6920;

  // API base URL
  static String apiBase = 'http://192.168.1.4:3000'; 
}

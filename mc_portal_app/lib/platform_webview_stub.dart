import 'package:flutter/material.dart';

// Stub — should never be used at runtime
class PlatformWebView extends StatelessWidget {
  final String url;
  const PlatformWebView({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('WebView not supported on this platform'));
  }
}

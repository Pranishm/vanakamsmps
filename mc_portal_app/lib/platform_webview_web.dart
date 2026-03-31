import 'package:flutter/material.dart';

class PlatformWebView extends StatelessWidget {
  final String url;
  const PlatformWebView({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0F001A), Color(0xFF1A0033)],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
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
                child: const Icon(Icons.security_rounded, color: Color(0xFF47D1E8), size: 64),
              ),
              const SizedBox(height: 32),
              const Text(
                'Browser Security Restriction',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Vanakam.me has security headers (X-Frame-Options: DENY) that prevent embedding the website in a web browser for security.',
                style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF47D1E8).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFF47D1E8).withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.phone_android_rounded, color: Color(0xFF47D1E8), size: 32),
                    const SizedBox(height: 12),
                    const Text(
                      'Ready for Android',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This feature works perfectly in the native Android app. Install the APK to browse the website directly inside the portal app!',
                      style: TextStyle(color: Colors.white60, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () {
                  // Link to website externally on web for convenience
                  // In Flutter web we could use window.open or url_launcher
                },
                icon: const Icon(Icons.open_in_new_rounded),
                label: const Text('Open vanakam.me in new tab'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF47D1E8),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

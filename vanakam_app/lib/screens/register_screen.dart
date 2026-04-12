import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:animate_do/animate_do.dart';
import 'package:vanakam_app/constants.dart';
import 'package:vanakam_app/services/auth_service.dart';
import 'package:vanakam_app/screens/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _handleRegister() async {
    if (_usernameCtrl.text.isEmpty || _emailCtrl.text.isEmpty || _passwordCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields', style: GoogleFonts.rajdhani()), backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() => _isLoading = true);

    final success = await AuthService().register(
      _usernameCtrl.text,
      _emailCtrl.text,
      _passwordCtrl.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Account created! Please log in.', style: GoogleFonts.rajdhani()), backgroundColor: McColors.grass),
      );
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed. Email may already exist.', style: GoogleFonts.rajdhani()), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: Stack(
        children: [
          Positioned(
            bottom: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: McColors.diamond.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
              child: FadeInUp(
                duration: const Duration(milliseconds: 600),
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: McColors.surfaceLight.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 30, offset: const Offset(0, 10)),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: McColors.diamond.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(color: McColors.diamond.withOpacity(0.2)),
                        ),
                        child: const FaIcon(FontAwesomeIcons.userPlus, color: McColors.diamond, size: 40),
                      ),
                      const SizedBox(height: 24),
                      Text('CREATE ACCOUNT', style: GoogleFonts.rajdhani(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2)),
                      Text('Join the community dashboard', style: GoogleFonts.rajdhani(fontSize: 15, color: Colors.white54)),
                      const SizedBox(height: 48),

                      TextField(
                        controller: _usernameCtrl,
                        style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 16),
                        decoration: InputDecoration(
                          hintText: 'Minecraft Username',
                          hintStyle: GoogleFonts.rajdhani(color: Colors.white24),
                          prefixIcon: const Padding(padding: EdgeInsets.all(14), child: FaIcon(FontAwesomeIcons.user, size: 16, color: Colors.white54)),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: McColors.diamond)),
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextField(
                        controller: _emailCtrl,
                        style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 16),
                        decoration: InputDecoration(
                          hintText: 'Email Address',
                          hintStyle: GoogleFonts.rajdhani(color: Colors.white24),
                          prefixIcon: const Padding(padding: EdgeInsets.all(14), child: FaIcon(FontAwesomeIcons.envelope, size: 16, color: Colors.white54)),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: McColors.diamond)),
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextField(
                        controller: _passwordCtrl,
                        obscureText: _obscurePassword,
                        style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 16),
                        decoration: InputDecoration(
                          hintText: 'Password',
                          hintStyle: GoogleFonts.rajdhani(color: Colors.white24),
                          prefixIcon: const Padding(padding: EdgeInsets.all(14), child: FaIcon(FontAwesomeIcons.lock, size: 16, color: Colors.white54)),
                          suffixIcon: IconButton(
                            icon: FaIcon(_obscurePassword ? FontAwesomeIcons.eye : FontAwesomeIcons.eyeSlash, size: 16, color: Colors.white54),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: McColors.diamond)),
                        ),
                      ),
                      const SizedBox(height: 32),

                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: McColors.diamond,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          onPressed: _isLoading ? null : _handleRegister,
                          child: _isLoading
                              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : Text('REGISTER', style: GoogleFonts.rajdhani(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.black87)),
                        ),
                      ),
                      const SizedBox(height: 32),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Already have an account?", style: GoogleFonts.rajdhani(color: Colors.white54, fontSize: 14)),
                          TextButton(
                            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                            child: Text('Login Here', style: GoogleFonts.rajdhani(color: McColors.diamond, fontWeight: FontWeight.bold, fontSize: 14)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              icon: const FaIcon(FontAwesomeIcons.arrowLeft, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}

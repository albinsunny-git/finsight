import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';
import '../services/api_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Quick delay just enough for the elegant animation to finish.
    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');

    if (userData != null) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const DashboardScreen()));
    } else {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF2563EB);
    const backgroundColor = Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.15),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.4),
                    blurRadius: 40,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: Image.asset(
                'assets/images/logo.png',
                width: 80,
                height: 80,
              ),
            )
                .animate()
                .scale(duration: 600.ms, curve: Curves.easeOutCubic)
                .fadeIn(duration: 600.ms)
                .shimmer(
                    delay: 600.ms, duration: 600.ms, color: Colors.white30),
            const SizedBox(height: 24),
            Text(
              'FinSight',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ).animate().fadeIn(delay: 300.ms, duration: 500.ms).slideY(
                begin: 0.3,
                end: 0,
                duration: 500.ms,
                curve: Curves.easeOutQuart),
            const SizedBox(height: 8),
            Text(
              'Financial Intelligence',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                color: Colors.white54,
                letterSpacing: 4,
              ),
            ).animate().fadeIn(delay: 500.ms, duration: 500.ms).slideY(
                begin: 0.3,
                end: 0,
                duration: 500.ms,
                curve: Curves.easeOutQuart),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Debug: ${ApiService.baseUrl}',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white24, fontSize: 10),
        ),
      ),
    );
  }
}

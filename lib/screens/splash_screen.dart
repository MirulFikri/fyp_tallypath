import 'package:flutter/material.dart';
import 'package:fyp_tallypath/auth_service.dart';
import 'package:fyp_tallypath/globals.dart';
import 'package:fyp_tallypath/user_data.dart';
import 'dart:async';
import 'welcome_screen.dart';
import 'main_navigation_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 1), () {
      if (mounted) {
        AuthService().addListener(() {
          if (!AuthService().isLoggedIn) {
            navigatorKey.currentState?.pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const WelcomeScreen()),
              (_) => false,
            );
          }
        });
        if (AuthService().isLoggedIn) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainNavigationScreen()));
        }else{
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const WelcomeScreen()));
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkAuth() async {
    if (UserData().isLoggedIn()) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainNavigationScreen()));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const WelcomeScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00D4AA),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Tally marks icon
            Image.asset(  'assets/images/tallypathwhite.png',
              width: 200,
              height: 200,
              fit: BoxFit.cover),
            const SizedBox(height: 24),
            const Text(
              'Tallypath',
              style: TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
          ],
        ),
      ),
    );
  }
}

class TallyMarksPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white
          ..strokeWidth = 8
          ..strokeCap = StrokeCap.round;

    final spacing = size.width / 6;

    // Draw 4 vertical lines
    for (int i = 0; i < 4; i++) {
      final x = spacing * (i + 1);
      canvas.drawLine(Offset(x, size.height * 0.2), Offset(x, size.height * 0.8), paint);
    }

    // Draw diagonal line through them
    canvas.drawLine(Offset(spacing * 0.8, size.height * 0.5), Offset(spacing * 4.8, size.height * 0.4), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F9F5),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Tally marks icon
                Image.asset(  'assets/images/tallypathgreen.png',
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover),
                const SizedBox(height: 24),
                const Text(
                  'Tallypath',
                  style: TextStyle(
                    color: Color(0xFF00D4AA),
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 80),
                
                // Log In Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    child: const Text('Log In'),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Sign Up Button
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignUpScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Forgot Password
                TextButton(
                  onPressed: () {
                    showDialog(context: context, builder: (_) => Dialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        width: 400,
                        child: Form(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Title
                              const Text("Reset Password", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

                              const SizedBox(height: 16),

                              // Invite Code
                              TextFormField(
                                decoration: InputDecoration(labelText: "Email or Username", border: OutlineInputBorder()),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'invalid code';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 12),

                              // Buttons
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Password reset link will be sent to your email')),
                                      );
                                    },
                                    child: const Text('Join'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ));
                  },
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TallyMarksPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00D4AA)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final spacing = size.width / 6;
    
    // Draw 4 vertical lines
    for (int i = 0; i < 4; i++) {
      final x = spacing * (i + 1);
      canvas.drawLine(
        Offset(x, size.height * 0.2),
        Offset(x, size.height * 0.8),
        paint,
      );
    }
    
    // Draw diagonal line through them
    canvas.drawLine(
      Offset(spacing * 0.8, size.height * 0.5),
      Offset(spacing * 4.8, size.height * 0.4),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

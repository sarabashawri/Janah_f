import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();

    _timer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/user-type');
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF3D5A6C),
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ✅ اللوقو من assets
                  Image.asset(
                    'assets/images/logo.png',
                    height: 200,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      // يساعدك تعرفين لو المسار غلط بدل ❌
                      return const Text(
                        'Logo asset not found: assets/images/logo.png',
                        style: TextStyle(color: Colors.white70),
                        textAlign: TextAlign.center,
                      );
                    },
                  ),

                  const SizedBox(height: 22),

                  const Text(
                    'ما دام الجَناح ممدودًا، فالأمل قريب',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),

                  const SizedBox(height: 70),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'نظام البحث والإنقاذ للأطفال المفقودين\nباستخدام تقنية الدرون الذكية',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white60,
                        height: 1.6,
                      ),
                    ),
                  ),

                  const SizedBox(height: 60),

                  const Text(
                    'نسخة 1.0.0',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white38,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

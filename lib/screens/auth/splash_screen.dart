import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    // بعد ثانيتين تحقق من حالة الدخول
    Timer(const Duration(seconds: 2), () => _checkAuth());
  }

  Future<void> _checkAuth() async {
    if (!mounted) return;

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // مو مسجل - روح لصفحة اختيار نوع المستخدم
      Navigator.of(context).pushReplacementNamed('/user-type');
      return;
    }

    try {
      // تحقق من نوع المستخدم في Firestore
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!mounted) return;

      final userType = doc.data()?['user_type'] ?? '';

      if (userType == 'rescuer') {
        Navigator.of(context).pushReplacementNamed('/rescuer/home');
      } else if (userType == 'guardian') {
        Navigator.of(context).pushReplacementNamed('/guardian/home');
      } else {
        // نوع غير معروف
        await FirebaseAuth.instance.signOut();
        Navigator.of(context).pushReplacementNamed('/user-type');
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/user-type');
    }
  }

  @override
  void dispose() {
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
                  Image.asset(
                    'assets/images/logo.png',
                    height: 200,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.flutter_dash, size: 100, color: Colors.white54);
                    },
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'ما دام الجَناح ممدودًا، فالأمل قريب',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  const SizedBox(height: 70),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'نظام البحث والإنقاذ للأطفال المفقودين\nباستخدام تقنية الدرون الذكية',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.white60, height: 1.6),
                    ),
                  ),
                  const SizedBox(height: 60),
                  const SizedBox(
                    width: 24, height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white38,
                      strokeWidth: 2,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('نسخة 1.0.0', style: TextStyle(fontSize: 12, color: Colors.white38)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

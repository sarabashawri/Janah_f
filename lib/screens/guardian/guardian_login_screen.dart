import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class GuardianLoginScreen extends StatefulWidget {
  const GuardianLoginScreen({super.key});

  @override
  State<GuardianLoginScreen> createState() => _GuardianLoginScreenState();
}

class _GuardianLoginScreenState extends State<GuardianLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  final _authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await _authService.loginGuardian(
          _emailController.text.trim(),
          _passwordController.text,
        );
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/guardian/home');
        }
      } catch (e) {
        if (mounted) {
          String msg = 'خطأ: تحقق من البريد وكلمة المرور';
          if (e is FirebaseAuthException) {
            switch (e.code) {
              case 'user-not-found':
                msg = 'البريد الإلكتروني غير مسجل';
                break;
              case 'wrong-password':
              case 'invalid-credential':
                msg = 'كلمة المرور غير صحيحة';
                break;
              case 'invalid-email':
                msg = 'البريد الإلكتروني غير صالح';
                break;
              case 'user-disabled':
                msg = 'هذا الحساب معطل';
                break;
              case 'network-request-failed':
                msg = 'تحقق من اتصال الإنترنت';
                break;
              default:
                msg = 'خطأ (${e.code}): ${e.message ?? ''}';
            }
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4EFEB),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // HEADER
                Container(
                  width: double.infinity,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Color(0xFF3D5A6C),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: 16,
                        top: 20,
                        child: IconButton(
                          onPressed: () => Navigator.of(context).pushReplacementNamed('/user-type'),
                          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                        ),
                      ),
                      const Center(
                        child: Text(
                          'تسجيل الدخول',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // WHITE CARD
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('البريد الإلكتروني',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textDirection: TextDirection.ltr,
                            decoration: InputDecoration(
                              hintText: 'أدخل البريد الإلكتروني',
                              hintTextDirection: TextDirection.rtl,
                              hintStyle: const TextStyle(fontSize: 13),
                              prefixIcon: const Icon(Icons.email_outlined),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFF3D5A6C), width: 2)),
                              filled: true,
                              fillColor: const Color(0xFFF9F9F9),
                            ),
                            validator: (v) => v!.isEmpty ? 'أدخل البريد الإلكتروني' : null,
                          ),

                          const SizedBox(height: 20),

                          const Text('كلمة المرور',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              hintText: 'أدخل كلمة المرور',
                              hintTextDirection: TextDirection.rtl,
                              hintStyle: const TextStyle(fontSize: 13),
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFF3D5A6C), width: 2)),
                              filled: true,
                              fillColor: const Color(0xFFF9F9F9),
                            ),
                            validator: (v) => v!.length < 6 ? 'كلمة المرور قصيرة' : null,
                          ),

                          const SizedBox(height: 8),

                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton(
                              onPressed: () => Navigator.pushNamed(context, '/guardian/forgot-password'),
                              child: const Text('نسيت كلمة المرور؟',
                                  style: TextStyle(fontSize: 13, color: Color(0xFF3D5A6C))),
                            ),
                          ),

                          const SizedBox(height: 16),

                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3D5A6C),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text(
                                      'تسجيل الدخول',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('ليس لديك حساب؟',
                                  style: TextStyle(fontSize: 13, color: Color(0xFF757575))),
                              TextButton(
                                onPressed: () => Navigator.pushNamed(context, '/guardian/register'),
                                child: const Text(
                                  'سجل الآن',
                                  style: TextStyle(
                                      color: Color(0xFF3D5A6C), fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

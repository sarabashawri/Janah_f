import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';

class GuardianRegisterScreen extends StatefulWidget {
  const GuardianRegisterScreen({super.key});

  @override
  State<GuardianRegisterScreen> createState() => _GuardianRegisterScreenState();
}

class _GuardianRegisterScreenState extends State<GuardianRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  bool _isLoading = false;
  final _authService = AuthService();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يجب الموافقة على الشروط والاحكام')),
      );
      return;
    }
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final phoneQuery = await FirebaseFirestore.instance
            .collection('users')
            .where('phone', isEqualTo: _phoneController.text.trim())
            .limit(1)
            .get();

        if (phoneQuery.docs.isNotEmpty) {
          if (mounted) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('رقم الجوال مستخدم بالفعل'), backgroundColor: Colors.red),
            );
          }
          return;
        }

        await _authService.registerGuardian(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          password: _passwordController.text,
        );
        if (mounted) Navigator.of(context).pushReplacementNamed('/guardian/home');
      } catch (e) {
        if (mounted) {
          String msg = 'خطأ في التسجيل: تحقق من البيانات';
          if (e is FirebaseAuthException) {
            switch (e.code) {
              case 'email-already-in-use':
                msg = 'البريد الإلكتروني مستخدم بالفعل';
                break;
              case 'invalid-email':
                msg = 'البريد الإلكتروني غير صالح';
                break;
              case 'weak-password':
                msg = 'كلمة المرور ضعيفة جداً (6 أحرف على الأقل)';
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
                // ── HEADER ──
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
                        right: 16, top: 20,
                        child: IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                        ),
                      ),
                      const Center(
                        child: Text('إنشاء حساب',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // ── CARD ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('الاسم الكامل', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              hintText: 'أدخل اسمك الكامل',
                              hintStyle: const TextStyle(fontSize: 13),
                              prefixIcon: const Icon(Icons.person_outline),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF3D5A6C), width: 2)),
                              filled: true, fillColor: const Color(0xFFF9F9F9),
                            ),
                            validator: (v) => v!.isEmpty ? 'ادخل اسمك' : null,
                          ),
                          const SizedBox(height: 16),

                          const Text('البريد الإلكتروني', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: 'أدخل البريد الإلكتروني',
                              hintStyle: const TextStyle(fontSize: 13),
                              prefixIcon: const Icon(Icons.email_outlined),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF3D5A6C), width: 2)),
                              filled: true, fillColor: const Color(0xFFF9F9F9),
                            ),
                            validator: (v) => v!.isEmpty ? 'ادخل البريد الالكتروني' : null,
                          ),
                          const SizedBox(height: 16),

                          const Text('رقم الجوال', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              hintText: 'أدخل رقم الجوال',
                              hintStyle: const TextStyle(fontSize: 13),
                              prefixIcon: const Icon(Icons.phone_outlined),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF3D5A6C), width: 2)),
                              filled: true, fillColor: const Color(0xFFF9F9F9),
                            ),
                            validator: (v) => v!.isEmpty ? 'ادخل رقم الجوال' : null,
                          ),
                          const SizedBox(height: 16),

                          const Text('كلمة المرور', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              hintText: 'أدخل كلمة المرور',
                              hintStyle: const TextStyle(fontSize: 13),
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF3D5A6C), width: 2)),
                              filled: true, fillColor: const Color(0xFFF9F9F9),
                            ),
                            validator: (v) => v!.length < 6 ? 'كلمة المرور قصيرة' : null,
                          ),
                          const SizedBox(height: 16),

                          const Text('تأكيد كلمة المرور', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            decoration: InputDecoration(
                              hintText: 'أعد إدخال كلمة المرور',
                              hintStyle: const TextStyle(fontSize: 13),
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                                onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                              ),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF3D5A6C), width: 2)),
                              filled: true, fillColor: const Color(0xFFF9F9F9),
                            ),
                            validator: (v) => v != _passwordController.text ? 'كلمة المرور غير متطابقة' : null,
                          ),
                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Checkbox(
                                value: _agreeToTerms,
                                activeColor: const Color(0xFF3D5A6C),
                                onChanged: (v) => setState(() => _agreeToTerms = v!),
                              ),
                              const Text('أوافق على الشروط والأحكام',
                                  style: TextStyle(fontSize: 13, color: Color(0xFF757575))),
                            ],
                          ),
                          const SizedBox(height: 20),

                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleRegister,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3D5A6C),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              child: _isLoading
                                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : const Text('إنشاء حساب',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

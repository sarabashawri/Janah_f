import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class RescuerForgotPasswordScreen extends StatefulWidget {
  const RescuerForgotPasswordScreen({super.key});

  @override
  State<RescuerForgotPasswordScreen> createState() => _RescuerForgotPasswordScreenState();
}

class _RescuerForgotPasswordScreenState extends State<RescuerForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  final _authService = AuthService();

  static const Color kPrimary = Color(0xFF3D5A6C);

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await _authService.resetPassword(_emailController.text.trim());
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إرسال رابط إعادة التعيين على بريدك'),
              backgroundColor: Color(0xFF00D995),
            ),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('خطأ: تحقق من البريد الإلكتروني'),
              backgroundColor: Color(0xFFEF5350),
            ),
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
          child: Column(
            children: [
              // ── HEADER ──
              Container(
                width: double.infinity,
                height: 80,
                decoration: const BoxDecoration(
                  color: kPrimary,
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
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                      ),
                    ),
                    const Center(
                      child: Text(
                        'نسيت كلمة المرور',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // ── الكارد ──
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
                      children: [
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: kPrimary.withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.lock_reset_outlined, color: kPrimary, size: 36),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'إعادة تعيين كلمة المرور',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF2D2D2D)),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'أدخل بريدك الإلكتروني وسنرسل لك رابط إعادة تعيين كلمة المرور',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: Color(0xFF757575), height: 1.5),
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textDirection: TextDirection.ltr,
                          textAlign: TextAlign.right,
                          decoration: InputDecoration(
                            labelText: 'البريد الإلكتروني',
                            hintText: 'example@email.com',
                            hintTextDirection: TextDirection.ltr,
                            prefixIcon: const Icon(Icons.email_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: kPrimary, width: 2),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF9F9F9),
                          ),
                          validator: (v) => (v == null || v.isEmpty) ? 'أدخل البريد الإلكتروني' : null,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleReset,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 22, height: 22,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text('إرسال',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

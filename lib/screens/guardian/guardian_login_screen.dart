import 'package:flutter/material.dart';

class GuardianLoginScreen extends StatefulWidget {
  const GuardianLoginScreen({super.key});

  @override
  State<GuardianLoginScreen> createState() => _GuardianLoginScreenState();
}

class _GuardianLoginScreenState extends State<GuardianLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.of(context).pushReplacementNamed('/guardian/home');
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
                // Header
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
                      // السهم على اليسار
                      Positioned(
                        left: 16,
                        top: 20,
                        child: IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                      // النص في المنتصف
                      const Center(
                        child: Text(
                          'تسجيل الدخول',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // المربع الأبيض حول الفورم
                Padding(
                  padding: const EdgeInsets.all(24.0),
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
                          // رقم الهاتف / البريد
                          const Text(
                            'رقم الهاتف / البريد',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            textDirection: TextDirection.ltr,
                            textAlign: TextAlign.right,
                            decoration: InputDecoration(
                              hintText: 'أدخل رقم الهاتف أو البريد الإلكتروني',
                              hintTextDirection: TextDirection.rtl,
                              hintStyle: const TextStyle(fontSize: 13),
                              prefixIcon: const Icon(Icons.phone_outlined),
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
                                borderSide: const BorderSide(color: Color(0xFF3D5A6C), width: 2),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF9F9F9),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'هذا الحقل مطلوب';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          // كلمة المرور
                          const Text(
                            'كلمة المرور',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            textDirection: TextDirection.ltr,
                            textAlign: TextAlign.right,
                            decoration: InputDecoration(
                              hintText: 'أدخل كلمة المرور',
                              hintTextDirection: TextDirection.rtl,
                              hintStyle: const TextStyle(fontSize: 13),
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() => _obscurePassword = !_obscurePassword);
                                },
                              ),
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
                                borderSide: const BorderSide(color: Color(0xFF3D5A6C), width: 2),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF9F9F9),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'هذا الحقل مطلوب';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 12),

                          // نسيت كلمة المرور على اليسار
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton(
                              onPressed: () {
                                Navigator.of(context).pushNamed('/guardian/forgot-password');
                              },
                              child: const Text(
                                'نسيت كلمة المرور؟',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF3D5A6C),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // زر تسجيل الدخول
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3D5A6C),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text(
                                      'تسجيل الدخول',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // إنشاء حساب جديد
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'ليس لديك حساب؟ ',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF757575),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pushNamed('/guardian/register');
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text(
                                  'إنشاء حساب جديد',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF3D5A6C),
                                  ),
                                ),
                              ),
                            ],
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
      ),
    );
  }
}
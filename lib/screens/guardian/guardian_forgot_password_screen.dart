import 'package:flutter/material.dart';

class GuardianForgotPasswordScreen extends StatefulWidget {
  const GuardianForgotPasswordScreen({super.key});

  @override
  State<GuardianForgotPasswordScreen> createState() =>
      _GuardianForgotPasswordScreenState();
}

class _GuardianForgotPasswordScreenState
    extends State<GuardianForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() {
          _isLoading = false;
          _emailSent = true;
        });
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
                  padding:
                      const EdgeInsets.symmetric(vertical: 30, horizontal: 24),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF3D5A6C), Color(0xFF4A7B91)],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'نسيت كلمة المرور',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_forward,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ✅ هذا اللي يخليها نفس شكل الجوال في الويب
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 430),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: _emailSent
                          ? _buildSuccessContent(context)
                          : _buildFormContent(context),
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

  Widget _buildFormContent(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Info Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 14,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3D5A6C).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.email_outlined,
                    color: Color(0xFF3D5A6C),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'استعادة كلمة المرور',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'أدخل رقم الهاتف المسجل\nسيرسل لك رابط لإعادة تعيين كلمة المرور',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF757575),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Phone Card (مثل الصورة)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 14,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'رقم الجوال',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F7F7),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE7E7E7)),
                  ),
                  child: TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      hintText: '05 XXX XXXX',
                      hintTextDirection: TextDirection.ltr,
                      prefixIcon: const Icon(Icons.mail_outline),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 12,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'هذا الحقل مطلوب';
                      }
                      return null;
                    },
                  ),
                ),

                const SizedBox(height: 10),

                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '💡 استخدم نفس رقم الهاتف الذي سجلت به في التطبيق',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF757575),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleResetPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3D5A6C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 6,
                shadowColor: Colors.black.withOpacity(0.12),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'إرسال رابط إعادة التعيين',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 14),

          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'تذكرت كلمة المرور؟ سجل دخول',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF3D5A6C),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Info Box
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9E6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFE082)),
            ),
            child: const Row(
              children: [
                Icon(Icons.lock_clock, color: Color(0xFFF57C00), size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '🔒 رابط إعادة التعيين صالح لمدة 24 ساعة فقط',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFFF57C00),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessContent(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(34),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF00D995).withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Color(0xFF00D995),
                  size: 56,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'تم إرسال الرابط بنجاح',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'تحقق من رسائلك النصية على الهاتف\nوقم بالضغط على الرابط لإعادة تعيين كلمة المرور',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF757575),
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3D5A6C),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'العودة لتسجيل الدخول',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

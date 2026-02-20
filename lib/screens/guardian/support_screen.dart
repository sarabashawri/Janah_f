import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isLoading = false;

  static const Color _bg = Color(0xFFF4EFEB); // ✅ اللون الموحد

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر فتح الرابط')),
        );
      }
    }
  }

  Future<void> _sendMessage() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() => _isLoading = false);
        _subjectController.clear();
        _messageController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إرسال رسالتك بنجاح. سنتواصل معك قريباً'),
            backgroundColor: Color(0xFF00D995),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _bg, // ✅ هنا
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF3D5A6C), Color(0xFF4A7B91)],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'تواصل مع الدعم',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_forward, color: Colors.white),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Contact Methods
                      Row(
                        children: [
                          Expanded(
                            child: _buildContactMethod(
                              icon: Icons.email_outlined,
                              label: 'بريد',
                              onTap: () => _launchUrl('mailto:support@janah.sa'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildContactMethod(
                              icon: Icons.message_outlined,
                              label: 'واتساب',
                              onTap: () =>
                                  _launchUrl('https://wa.me/966501234567'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildContactMethod(
                              icon: Icons.phone_outlined,
                              label: 'اتصال',
                              onTap: () => _launchUrl('tel:+966501234567'),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Contact Info Card
                      _card(
                        child: Column(
                          children: [
                            _buildContactInfoRow(
                              icon: Icons.phone,
                              label: 'الهاتف',
                              value: '+966 50 123 4567',
                            ),
                            const SizedBox(height: 16),
                            _buildContactInfoRow(
                              icon: Icons.email,
                              label: 'البريد الإلكتروني',
                              value: 'support@janah.sa',
                            ),
                            const SizedBox(height: 16),
                            _buildContactInfoRow(
                              icon: Icons.access_time,
                              label: 'خدمة الدعم متاحة 24/7',
                              value: 'نحن هنا لمساعدتك في أي وقت',
                              isLast: true,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      const Text(
                        'إرسال رسالة',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Send Message Form
                      _card(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'الموضوع',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildInput(
                                controller: _subjectController,
                                hintText: 'عنوان الموضوع',
                                maxLines: 1,
                                validatorMsg: 'هذا الحقل مطلوب',
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'الرسالة',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildInput(
                                controller: _messageController,
                                hintText: 'اكتب رسالتك هنا...',
                                maxLines: 5,
                                validatorMsg: 'هذا الحقل مطلوب',
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton.icon(
                                  onPressed: _isLoading ? null : _sendMessage,
                                  icon:
                                      const Icon(Icons.send, color: Colors.white),
                                  label: _isLoading
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                      : const Text(
                                          'إرسال الرسالة',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF3D5A6C),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // FAQ Link
                      InkWell(
                        onTap: () {},
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE3F2FD),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.help_outline,
                                color: Color(0xFF2196F3),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'هل لديك استفسار؟\nفريق الدعم جاهز للمساعدة عبر جميع القنوات',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF2196F3),
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.arrow_back,
                                color: Color(0xFF2196F3),
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===== Helpers =====

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hintText,
    required int maxLines,
    required String validatorMsg,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        textAlign: TextAlign.right,
        decoration: InputDecoration(
          hintText: hintText,
          hintTextDirection: TextDirection.rtl,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF3D5A6C), width: 1),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) return validatorMsg;
          return null;
        },
      ),
    );
  }

  Widget _buildContactMethod({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF3D5A6C).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: const Color(0xFF3D5A6C),
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfoRow({
    required IconData icon,
    required String label,
    required String value,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF3D5A6C).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF3D5A6C),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF9E9E9E),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

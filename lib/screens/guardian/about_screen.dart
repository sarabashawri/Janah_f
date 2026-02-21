import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4EFEB),
        body: SafeArea(
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
                      right: 16,
                      top: 20,
                      child: IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                    // النص في المنتصف
                    const Center(
                      child: Text(
                        'عن جناح',
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

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // وصف التطبيق
                      _buildInfoCard(
                        title: 'وصف التطبيق',
                        content:
                            'نظام جناح يستخدم تقنية الذكاء الاصطناعي والطائرات بدون طيار للاستجابة السريعة عند الإبلاغ عن طفل مفقود، ويعمل فريق البحث والإنقاذ باستخدام تقنيات متقدمة لرفع كفاءة البحث وتقليل وقت الاستجابة.',
                      ),

                      const SizedBox(height: 16),

                      // الهدف والرؤية في صف واحد
                      Row(
                        children: [
                          Expanded(
                            child: _buildSmallCard(
                              icon: Icons.my_location,
                              iconColor: const Color(0xFFE91E63),
                              title: 'الهدف',
                              description: 'استخدام أحدث التقنيات لإنقاذ الأطفال المفقودين بأسرع وقت ممكن وتوفير راحة البال للأهالي.',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildSmallCard(
                              icon: Icons.visibility,
                              iconColor: const Color(0xFF2196F3),
                              title: 'الرؤية',
                              description: 'بناء نظام وطني يعتمد على التكنولوجيا المتقدمة للتعرف على الوجوه والطائرات بدون طيار.',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // المميزات الرئيسية
                      const Text(
                        'المميزات الرئيسية',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildFeatureCard(
                        icon: Icons.speed,
                        title: 'استجابة سريعة',
                        description: 'إطلاق الدرون خلال دقائق معدودة',
                        color: const Color(0xFF00D995),
                      ),

                      const SizedBox(height: 12),

                      _buildFeatureCard(
                        icon: Icons.face,
                        title: 'تقنية متقدمة',
                        description: 'التعرف على الوجوه بدقة عالية',
                        color: const Color(0xFF2196F3),
                      ),

                      const SizedBox(height: 12),

                      _buildFeatureCard(
                        icon: Icons.people,
                        title: 'فريق محترف',
                        description: 'فريق بحث وإنقاذ متخصص',
                        color: const Color(0xFFFF9800),
                      ),

                      const SizedBox(height: 12),

                      _buildFeatureCard(
                        icon: Icons.notifications_active,
                        title: 'إشعارات فورية',
                        description: 'تحديثات مباشرة عن حالة البحث',
                        color: const Color(0xFFFFEB3B),
                      ),

                      const SizedBox(height: 24),

                      // هل لديك استفسار
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pushNamed('/guardian/support');
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE3F2FD),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.help_outline,
                                color: Color(0xFF2196F3),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'هل لديك استفسار؟',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF2196F3),
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'فريق الدعم جاهز لمساعدتك عبر جميع القنوات',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF1976D2),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // تواصل معنا
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed('/guardian/support');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3D5A6C),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'تواصل معنا',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      const Text(
                        '© 2025 جناح - جميع الحقوق محفوظة',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9E9E9E),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'صُنع بـ ❤️ في المملكة العربية السعودية',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9E9E9E),
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

  Widget _buildInfoCard({
    required String title,
    required String content,
  }) {
    return Container(
      width: double.infinity, // ✅ العرض الكامل
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF757575),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF757575),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF757575),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

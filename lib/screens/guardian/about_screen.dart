import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4EFEB), // ✅ اللون الجديد
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
                      'عن جناح',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon:
                          const Icon(Icons.arrow_forward, color: Colors.white),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // App Logo Card
                      Container(
                        padding: const EdgeInsets.all(24),
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
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3D5A6C)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.flight,
                                size: 60,
                                color: Color(0xFF3D5A6C),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'جناح',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'نظام البحث والإنقاذ للأطفال المفقودين',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF757575),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'نسخة 1.0.0',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF9E9E9E),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      _buildInfoCard(
                        title: 'وصف التطبيق',
                        content:
                            'نظام جناح يستخدم تقنية الذكاء الاصطناعي والطائرات بدون طيار للاستجابة السريعة عند الإبلاغ عن طفل مفقود، ويعمل فريق البحث والإنقاذ باستخدام تقنيات متقدمة لرفع كفاءة البحث وتقليل وقت الاستجابة.',
                      ),

                      const SizedBox(height: 16),

                      _buildInfoCard(
                        title: 'الهدف',
                        content:
                            'استخدام أحدث التقنيات لإنقاذ الأطفال المفقودين بأسرع وقت ممكن وتوفير راحة البال للأهالي من خلال نظام متكامل يجمع بين الذكاء الاصطناعي والطائرات بدون طيار.',
                        icon: Icons.my_location,
                      ),

                      const SizedBox(height: 16),

                      _buildInfoCard(
                        title: 'الرؤية',
                        content:
                            'بناء نظام وطني يعتمد على التكنولوجيا المتقدمة للتعرف على الوجوه والطائرات بدون طيار لتسهيل عمليات البحث وتقليل زمن الوصول.',
                        icon: Icons.visibility,
                      ),

                      const SizedBox(height: 24),

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
    IconData? icon,
  }) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon,
                    color: const Color(0xFF3D5A6C), size: 20),
                const SizedBox(width: 8),
              ],
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF757575),
              height: 1.6,
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
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
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

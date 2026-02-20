import 'package:flutter/material.dart';

class ReportDetailsScreen extends StatelessWidget {
  const ReportDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4EFEB), // ✅ اللون الموحد
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                decoration: const BoxDecoration(
                  color: Color(0xFF3D5A6C),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'متابعة حالة البلاغ',
                      style: TextStyle(
                        fontSize: 20,
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
                      // Status Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF00D995),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    'جاري البحث',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                const Text(
                                  'منذ 3 ساعات',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF9E9E9E),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'بلاغ رقم #1234',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'تم الإنشاء منذ 3 ساعات',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF757575),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Child Info Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'بيانات الطفل',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildInfoRow(
                              icon: Icons.person,
                              label: 'اسم الطفل',
                              value: 'محمد أحمد',
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow(
                              icon: Icons.location_on,
                              label: 'آخر موقع',
                              value: 'حي النزهة، شارع الملك فهد',
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow(
                              icon: Icons.access_time,
                              label: 'وقت الاختفاء',
                              value: 'اليوم 14:30',
                              isLast: true,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Timeline Section
                      const Text(
                        'تحديثات البحث',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Timeline
                      _buildTimelineItem(
                        title: 'تم العثور على الطفل',
                        description: 'الطفل بحالة جيدة - يتم نقله للوقع الآمن',
                        time: 'منذ ساعة',
                        icon: Icons.check_circle,
                        color: const Color(0xFF00D995),
                        isLast: false,
                      ),
                      _buildTimelineItem(
                        title: 'بدأ فريق الإنقاذ البحث',
                        description: 'تم الموافقة على عملية البحث',
                        time: 'منذ ساعتين',
                        icon: Icons.people,
                        color: const Color(0xFF2196F3),
                        isLast: false,
                      ),
                      _buildTimelineItem(
                        title: 'تم استلام البلاغ',
                        description: 'بإنتظار الموافقة من قبل فريق الإنقاذ',
                        time: 'منذ 3 ساعات',
                        icon: Icons.receipt_long,
                        color: const Color(0xFF9E9E9E),
                        isLast: true,
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

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: const Color(0xFF757575),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
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

  Widget _buildTimelineItem({
    required String title,
    required String description,
    required String time,
    required IconData icon,
    required Color color,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 60,
                color: const Color(0xFFE0E0E0),
              ),
          ],
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
              const SizedBox(height: 4),
              Text(
                time,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF9E9E9E),
                ),
              ),
              if (!isLast) const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }
}

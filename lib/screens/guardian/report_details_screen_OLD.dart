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

                      _buildInfoCard(
                        title: 'بيانات الطفل',
                        items: [
                          _InfoItem(
                            icon: Icons.person,
                            label: 'اسم الطفل',
                            value: 'محمد أحمد',
                          ),
                          _InfoItem(
                            icon: Icons.location_on,
                            label: 'آخر موقع',
                            value: 'حي النزهة، شارع الملك فهد',
                          ),
                          _InfoItem(
                            icon: Icons.access_time,
                            label: 'وقت الاختفاء',
                            value: 'اليوم 14:30',
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      _buildInfoCard(
                        title: 'بيانات ولي الأمر',
                        items: [
                          _InfoItem(
                            icon: Icons.person_outline,
                            label: 'الاسم',
                            value: 'أحمد محمد',
                          ),
                          _InfoItem(
                            icon: Icons.phone,
                            label: 'رقم الجوال',
                            value: '+966 50 123 4567',
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.phone, color: Colors.white),
                          label: const Text(
                            'الاتصال بولي الأمر',
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

                      const SizedBox(height: 24),

                      const Text(
                        'تحديثات البحث',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            _showCloseReportDialog(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00D995),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'التحكم بالمهمة',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
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

  Widget _buildInfoCard({
    required String title,
    required List<_InfoItem> items,
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Icon(
                      item.icon,
                      size: 20,
                      color: const Color(0xFF757575),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.label,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF9E9E9E),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.value,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  void _showCloseReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('إغلاق البلاغ'),
          content: const Text('هل تريد إغلاق هذا البلاغ؟ لن تتمكن من التراجع عن هذا الإجراء.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D995),
              ),
              child: const Text('تأكيد'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoItem {
  final IconData icon;
  final String label;
  final String value;

  _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });
}

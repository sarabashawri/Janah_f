import 'package:flutter/material.dart';
import 'verification_screen.dart';

class MissionDetailsScreen extends StatelessWidget {
  const MissionDetailsScreen({super.key});

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
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                decoration: const BoxDecoration(color: Color(0xFF3D5A6C)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('تفاصيل المهمة',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
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
                      // ── حالة البلاغ ──
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
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFEB3B),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text('جاري البحث',
                                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
                                ),
                                const Spacer(),
                                const Text('منذ ساعتين',
                                    style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Text('بلاغ رقم #12344',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── معلومات الطفل ──
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('معلومات الطفل',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 16),
                            _buildInfoRow(icon: Icons.person, label: 'اسم الطفل', value: 'سارة أحمد'),
                            const SizedBox(height: 12),
                            _buildInfoRow(icon: Icons.location_on, label: 'آخر موقع', value: 'حي الربوة، شارع العليا'),
                            const SizedBox(height: 12),
                            _buildInfoRow(icon: Icons.access_time, label: 'وقت الاختفاء', value: 'اليوم 14:30', isLast: true),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── بيانات ولي الأمر ──
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('بيانات ولي الأمر',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 16),
                            _buildInfoRow(icon: Icons.person_outline, label: 'الاسم', value: 'أحمد محمد'),
                            const SizedBox(height: 12),
                            _buildInfoRow(icon: Icons.phone, label: 'رقم الجوال', value: '+966 50 123 4567', isLast: true),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── نقاط الاشتباه ──
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text('نقاط الاشتباه',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                                Text('1 نقطة',
                                    style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _SuspiciousPointCard(
                              number: 1,
                              location: 'قرب الموقع المحدد - 200 متر شمالاً',
                              time: 'منذ 15 دقيقة',
                              status: 'قيد المراجعة',
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const VerificationScreen()),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── الاتصال بولي الأمر ──
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.phone, color: Colors.white),
                          label: const Text('الاتصال بولي الأمر',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3D5A6C),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── الموقع والدرون ──
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.location_on, color: Colors.white, size: 20),
                              label: const Text('الموقع',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFEF5350),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.flight, color: Colors.white, size: 20),
                              label: const Text('الدرون',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2196F3),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // ── إتمام المهمة ──
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () => _showCompleteMissionDialog(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00D995),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text('إتمام المهمة',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
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

  Widget _buildInfoRow({required IconData icon, required String label, required String value, bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: const Color(0xFF757575)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }

  void _showCompleteMissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('إتمام المهمة'),
          content: const Text('هل أنت متأكد من إتمام هذه المهمة؟'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00D995)),
              child: const Text('تأكيد'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── نقطة الاشتباه ويدجت ──
class _SuspiciousPointCard extends StatelessWidget {
  const _SuspiciousPointCard({
    required this.number,
    required this.location,
    required this.time,
    required this.status,
    required this.onTap,
  });
  final int number;
  final String location, time, status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFDE7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFFEB3B), width: 1.5),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('نقطة اشتباه #$number',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(location, style: const TextStyle(fontSize: 12, color: Color(0xFF757575))),
                      const SizedBox(width: 4),
                      const Icon(Icons.location_on, size: 12, color: Color(0xFFEF5350)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(time, style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
                      const SizedBox(width: 4),
                      const Icon(Icons.access_time, size: 12, color: Color(0xFF9E9E9E)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF9C4),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFFFEB3B)),
                  ),
                  child: Text(status,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFF57F17))),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3D5A6C),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('عرض',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

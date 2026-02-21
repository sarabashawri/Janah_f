import 'package:flutter/material.dart';

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
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                color: const Color(0xFF3D5A6C),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('تفاصيل البلاغ #1234', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                    IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.arrow_forward, color: Colors.white)),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      _SectionCard(
                        title: 'حالة المهمة',
                        titleTrailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF00D995), shape: BoxShape.circle)),
                            const SizedBox(width: 6),
                            const Text('نشطة', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF00D995))),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(children: [_MissionStat(label: 'وقت البدء', value: '15:00'), _MissionStat(label: 'المدة', value: '3:15:20')]),
                            const SizedBox(height: 12),
                            Row(children: [_MissionStat(label: 'المنطقة الممسوحة', value: '40%'), _MissionStat(label: 'نقاط الاشتباه', value: '2')]),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      _SectionCard(
                        title: 'بيانات الطفل',
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(color: const Color(0xFFE0E0E0), borderRadius: BorderRadius.circular(12)),
                                  child: const Icon(Icons.person, size: 36, color: Color(0xFF757575)),
                                ),
                                const SizedBox(width: 14),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('محمد أحمد', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                                      SizedBox(height: 4),
                                      Text('الوصف: يرتدي قميص أزرق', style: TextStyle(fontSize: 13, color: Color(0xFF757575))),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            _InfoRow(icon: Icons.location_on, iconColor: const Color(0xFFEF5350), label: 'آخر موقع', value: 'حي النزهة، شارع الملك فهد'),
                            const SizedBox(height: 10),
                            _InfoRow(icon: Icons.access_time, iconColor: const Color(0xFF9E9E9E), label: 'وقت الاختفاء', value: 'اليوم، 14:30'),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      _SectionCard(
                        title: 'بيانات ولي الأمر',
                        child: Column(
                          children: [
                            _InfoRow(icon: Icons.person_outline, iconColor: const Color(0xFF3D5A6C), label: 'الاسم', value: 'أحمد محمد'),
                            const SizedBox(height: 10),
                            _InfoRow(icon: Icons.phone, iconColor: const Color(0xFF3D5A6C), label: 'رقم الجوال', value: '+966 50 123 4567'),
                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.phone, color: Colors.white, size: 18),
                                label: const Text('اتصال بولي الأمر', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3D5A6C), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      _SectionCard(
                        title: 'الخريطة الحية',
                        child: Column(
                          children: [
                            Container(
                              height: 180,
                              decoration: BoxDecoration(color: const Color(0xFFD0E8F0), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFB0D4E0))),
                              child: Stack(
                                children: [
                                  ClipRRect(borderRadius: BorderRadius.circular(12), child: CustomPaint(size: const Size(double.infinity, 180), painter: _MapPainter())),
                                  Positioned(
                                    top: 12, right: 12,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(color: const Color(0xFF3D5A6C), borderRadius: BorderRadius.circular(20)),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.flight, color: Colors.white, size: 13),
                                          SizedBox(width: 4),
                                          Text('DR-01 في المنطقة', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600)),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 12, right: 12,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(20)),
                                      child: const Text('40% ممسوحة', style: TextStyle(fontSize: 11, color: Color(0xFF3D5A6C), fontWeight: FontWeight.w600)),
                                    ),
                                  ),
                                  const Positioned(top: 80, left: 80, child: _MapDot(color: Color(0xFFEF5350))),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(children: const [Icon(Icons.location_on, size: 14, color: Color(0xFF757575)), SizedBox(width: 4), Text('حي النزهة، شارع الملك فهد', style: TextStyle(fontSize: 12, color: Color(0xFF757575)))]),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              height: 44,
                              child: OutlinedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.map, size: 16, color: Color(0xFF3D5A6C)),
                                label: const Text('عرض الخريطة بملء الشاشة', style: TextStyle(fontSize: 13, color: Color(0xFF3D5A6C), fontWeight: FontWeight.w600)),
                                style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFF3D5A6C)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      _SectionCard(
                        title: 'نقاط الاشتباه',
                        child: Column(
                          children: [
                            _SuspectPointCard(number: 2, time: 'منذ 15 دقيقة', location: 'قرب الموقع المحدد - 200 متر', status: 'قيد المراجعة', statusColor: const Color(0xFFFFEB3B), statusTextColor: Colors.black87, actionLabel: 'عرض والتحقق →'),
                            const SizedBox(height: 10),
                            _SuspectPointCard(number: 1, time: 'منذ 30 دقيقة', location: 'حي النزهة - 500 متر', status: 'غير مطابق', statusColor: Color(0xFFEF5350), statusTextColor: Colors.white),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      _SectionCard(
                        title: 'لقطات من الكاميرا',
                        child: GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1.3,
                          children: const [
                            _CameraSnapshot(time: '18:14:40'),
                            _CameraSnapshot(time: '18:13:35'),
                            _CameraSnapshot(time: '18:16:50'),
                            _CameraSnapshot(time: '18:15:45'),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      _SectionCard(
                        title: 'التحكم بالمهمة',
                        child: SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton.icon(
                            onPressed: () => _showCompleteMissionDialog(context),
                            icon: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
                            label: const Text('بدء', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00D995), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
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
              onPressed: () { Navigator.of(context).pop(); Navigator.of(context).pop(); },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00D995)),
              child: const Text('تأكيد'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child, this.titleTrailing});
  final String title;
  final Widget child;
  final Widget? titleTrailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              if (titleTrailing != null) titleTrailing!,
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _MissionStat extends StatelessWidget {
  const _MissionStat({required this.label, required this.value});
  final String label, value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.iconColor, required this.label, required this.value});
  final IconData icon;
  final Color iconColor;
  final String label, value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}

class _SuspectPointCard extends StatelessWidget {
  const _SuspectPointCard({required this.number, required this.time, required this.location, required this.status, required this.statusColor, required this.statusTextColor, this.actionLabel});
  final int number;
  final String time, location, status;
  final Color statusColor, statusTextColor;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFFFAFAFA), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE8E8E8))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('نقطة اشتباه #$number', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(20)),
                child: Text(status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: statusTextColor)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(time, style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
          const SizedBox(height: 4),
          Row(children: [const Icon(Icons.location_on, size: 12, color: Color(0xFFEF5350)), const SizedBox(width: 3), Text(location, style: const TextStyle(fontSize: 12, color: Color(0xFF757575)))]),
          if (actionLabel != null) ...[const SizedBox(height: 6), Text(actionLabel!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF3D5A6C)))],
        ],
      ),
    );
  }
}

class _CameraSnapshot extends StatelessWidget {
  const _CameraSnapshot({required this.time});
  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFFE8E8E8), borderRadius: BorderRadius.circular(10)),
      child: Stack(
        children: [
          const Center(child: Icon(Icons.photo_camera, size: 30, color: Color(0xFF9E9E9E))),
          Positioned(
            bottom: 6, left: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(6)),
              child: Text(time, style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapDot extends StatelessWidget {
  const _MapDot({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16, height: 16,
      decoration: BoxDecoration(
        color: color, shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 6, spreadRadius: 2)],
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = const Color(0xFFB8DDE8));
    final grid = Paint()..color = const Color(0xFF9ECFDB)..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 40) canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    for (double y = 0; y < size.height; y += 40) canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    final road = Paint()..color = Colors.white.withOpacity(0.6)..strokeWidth = 6..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(0, size.height * 0.45), Offset(size.width, size.height * 0.45), road);
    canvas.drawLine(Offset(size.width * 0.4, 0), Offset(size.width * 0.4, size.height), road);
    final scanned = Paint()..color = const Color(0xFF00D995).withOpacity(0.15);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width * 0.4, size.height), scanned);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

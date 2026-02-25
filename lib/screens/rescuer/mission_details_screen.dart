import 'package:flutter/material.dart';
import 'verification_screen.dart';

// ── بيانات كل طفل (public عشان تستخدمها صفحات ثانية) ──
class MissionData {
  final String reportId;
  final String childName;
  final String childDescription;
  final String lastLocation;
  final String disappearTime;
  final String guardianName;
  final String guardianPhone;
  final String missionDuration;
  final String startTime;
  final int suspiciousPoints;
  final double scannedArea;
  final List<SuspiciousPoint> points;

  const MissionData({
    required this.reportId,
    required this.childName,
    required this.childDescription,
    required this.lastLocation,
    required this.disappearTime,
    required this.guardianName,
    required this.guardianPhone,
    required this.missionDuration,
    required this.startTime,
    required this.suspiciousPoints,
    required this.scannedArea,
    required this.points,
  });
}

class SuspiciousPoint {
  final int number;
  final String location;
  final String time;
  final String status;

  const SuspiciousPoint({
    required this.number,
    required this.location,
    required this.time,
    required this.status,
  });
}

// بيانات كل طفل
final missionsMap = <String, MissionData>{
  '#1234': MissionData(
    reportId: '#1234',
    childName: 'محمد أحمد',
    childDescription: 'يرتدي قميص أزرق',
    lastLocation: 'حي النزهة، شارع الملك فهد',
    disappearTime: 'اليوم، 15:00',
    guardianName: 'أحمد محمد',
    guardianPhone: '+966 50 123 4567',
    missionDuration: '3:15:20',
    startTime: '15:00',
    suspiciousPoints: 2,
    scannedArea: 40,
    points: [
      SuspiciousPoint(number: 2, location: 'قرب الموقع المحدد - 200 متر', time: 'منذ 15 دقيقة', status: 'قيد المراجعة'),
      SuspiciousPoint(number: 1, location: 'حي النزهة - 500 متر', time: 'منذ 30 دقيقة', status: 'غير مطابق'),
    ],
  ),
  '#1235': MissionData(
    reportId: '#1235',
    childName: 'سارة أحمد',
    childDescription: 'ترتدي فستان وردي',
    lastLocation: 'حي الربوة، شارع العليا',
    disappearTime: 'اليوم، 14:30',
    guardianName: 'أحمد محمد',
    guardianPhone: '+966 50 123 4567',
    missionDuration: '0:45:10',
    startTime: '14:30',
    suspiciousPoints: 1,
    scannedArea: 15,
    points: [
      SuspiciousPoint(number: 1, location: 'قرب الموقع المحدد - 200 متر شمالاً', time: 'منذ 15 دقيقة', status: 'قيد المراجعة'),
    ],
  ),
  '#1233': MissionData(
    reportId: '#1233',
    childName: 'عمر خالد',
    childDescription: 'يرتدي قميص أحمر',
    lastLocation: 'حي الروضة، شارع العليا',
    disappearTime: 'اليوم، 12:00',
    guardianName: 'خالد العمر',
    guardianPhone: '+966 55 111 2222',
    missionDuration: '2:10:00',
    startTime: '12:00',
    suspiciousPoints: 0,
    scannedArea: 60,
    points: [],
  ),
  '#1232': MissionData(
    reportId: '#1232',
    childName: 'فاطمة ماجد',
    childDescription: 'ترتدي عباءة سوداء',
    lastLocation: 'حي العزيزية، شارع الأمير محمد',
    disappearTime: 'أمس، 18:00',
    guardianName: 'ماجد الحربي',
    guardianPhone: '+966 55 987 6543',
    missionDuration: '5:00:00',
    startTime: '18:00',
    suspiciousPoints: 0,
    scannedArea: 80,
    points: [],
  ),
};

class MissionDetailsScreen extends StatelessWidget {
  final String reportId;
  const MissionDetailsScreen({super.key, this.reportId = '#1234'});

  static const Color _navy = Color(0xFF3D5A6C);
  static const Color _bg   = Color(0xFFF4EFEB);

  @override
  Widget build(BuildContext context) {
    final data = missionsMap[reportId] ?? missionsMap['#1234']!;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _bg,
        body: SafeArea(
          child: Column(
            children: [
              // ── HEADER — سهم على اليسار، عنوان في الوسط ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                color: _navy,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    Expanded(
                      child: Text(
                        'تفاصيل البلاغ ${data.reportId}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 36),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildStatusCard(data),
                      const SizedBox(height: 16),

                      // بيانات الطفل
                      _card(title: 'بيانات الطفل', children: [
                        _InfoRow(icon: Icons.person_outline, value: data.childName, bold: true),
                        const SizedBox(height: 6),
                        _InfoRow(icon: Icons.info_outline, label: 'الوصف:', value: data.childDescription),
                        const SizedBox(height: 12),
                        _InfoRow(icon: Icons.location_on_outlined, label: 'آخر موقع', value: data.lastLocation),
                        const SizedBox(height: 12),
                        _InfoRow(icon: Icons.access_time, label: 'وقت الاختفاء', value: data.disappearTime),
                      ]),
                      const SizedBox(height: 16),

                      // بيانات ولي الأمر
                      _card(title: 'بيانات ولي الأمر', children: [
                        _InfoRow(icon: Icons.person_outline, label: 'الاسم', value: data.guardianName),
                        const SizedBox(height: 12),
                        _InfoRow(icon: Icons.phone_outlined, label: 'رقم الجوال', value: data.guardianPhone),
                      ]),
                      const SizedBox(height: 16),

                      // زر الاتصال
                      SizedBox(
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.phone, color: Colors.white, size: 20),
                          label: const Text('الاتصال بولي الأمر', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _navy,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // الخريطة
                      _card(title: 'الخريطة الحية', children: [
                        Container(
                          height: 160,
                          decoration: BoxDecoration(color: const Color(0xFFCFDAE0), borderRadius: BorderRadius.circular(12)),
                          child: Stack(children: [
                            Center(child: Icon(Icons.map, size: 60, color: _navy.withOpacity(0.3))),
                            Positioned(
                              top: 10, left: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(color: _navy, borderRadius: BorderRadius.circular(20)),
                                child: const Text('في المنطقة • DR-01', style: TextStyle(color: Colors.white, fontSize: 11)),
                              ),
                            ),
                            Positioned(
                              bottom: 10, right: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                                child: Text('${data.scannedArea.toInt()}% ممسوحة', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                              ),
                            ),
                          ]),
                        ),
                        const SizedBox(height: 10),
                        Row(children: [
                          const Icon(Icons.location_on, size: 14, color: Color(0xFFEF5350)),
                          const SizedBox(width: 4),
                          Text(data.lastLocation, style: const TextStyle(fontSize: 12, color: Color(0xFF757575))),
                        ]),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 44,
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.location_on, color: Colors.white, size: 18),
                            label: const Text('عرض الخريطة بملء الشاشة', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                            style: ElevatedButton.styleFrom(backgroundColor: _navy, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 16),

                      // نقاط الاشتباه
                      _card(title: 'نقاط الاشتباه', children: data.points.isEmpty
                        ? [const Center(child: Padding(padding: EdgeInsets.all(12), child: Text('لا توجد نقاط اشتباه حتى الآن', style: TextStyle(color: Color(0xFF9E9E9E)))))]
                        : data.points.map((p) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _SuspiciousPointCard(
                              point: p,
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => VerificationScreen(reportId: data.reportId, pointNumber: p.number))),
                            ),
                          )).toList(),
                      ),
                      const SizedBox(height: 16),

                      // لقطات الكاميرا
                      _card(title: 'لقطات من الكاميرا', children: [
                        GridView.count(
                          crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10,
                          shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                          children: const [
                            _CameraThumb(time: '18:13:35'), _CameraThumb(time: '18:14:40'),
                            _CameraThumb(time: '18:15:45'), _CameraThumb(time: '18:16:50'),
                          ],
                        ),
                      ]),
                      const SizedBox(height: 16),

                      // التحكم بالمهمة
                      _card(title: 'التحكم بالمهمة', children: [
                        SizedBox(
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: () => _showCompleteMissionDialog(context),
                            icon: const Icon(Icons.play_arrow, color: Colors.white),
                            label: const Text('بدء', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00D995), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 24),
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

  Widget _buildStatusCard(MissionData data) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: _navy, borderRadius: BorderRadius.circular(16)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [
          Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF00D995), shape: BoxShape.circle)),
          const SizedBox(width: 6),
          const Text('نشطة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
        ]),
        const Text('حالة المهمة', style: TextStyle(color: Colors.white70, fontSize: 13)),
      ]),
      const SizedBox(height: 14),
      Row(children: [
        _StatItem(label: 'المدة', value: data.missionDuration),
        const SizedBox(width: 32),
        _StatItem(label: 'وقت البدء', value: data.startTime),
      ]),
      const SizedBox(height: 10),
      Row(children: [
        _StatItem(label: 'نقاط الاشتباه', value: data.suspiciousPoints.toString()),
        const SizedBox(width: 32),
        _StatItem(label: 'المنطقة المسموحة', value: '${data.scannedArea.toInt()}%'),
      ]),
    ]),
  );

  Widget _card({required String title, required List<Widget> children}) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
      Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
      const SizedBox(height: 14),
      ...children,
    ]),
  );

  void _showCompleteMissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('إتمام المهمة'),
          content: const Text('هل أنت متأكد من إتمام هذه المهمة؟'),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () { Navigator.of(ctx).pop(); Navigator.of(context).pop(); },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00D995)),
              child: const Text('تأكيد', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});
  final String label, value;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
      Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
    ],
  );
}

// الأيقونة مع الكلام في نفس الاتجاه (RTL)
class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, this.label, required this.value, this.bold = false});
  final IconData icon;
  final String? label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // النص على اليمين
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (label != null) ...[
                Text(label!, textAlign: TextAlign.right, style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
                const SizedBox(height: 2),
              ],
              Text(value, textAlign: TextAlign.right,
                style: TextStyle(fontSize: 14, fontWeight: bold ? FontWeight.w800 : FontWeight.w600)),
            ],
          ),
        ),
        const SizedBox(width: 10),
        // الأيقونة بجانب النص على اليمين
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: 20, color: const Color(0xFF9E9E9E)),
        ),
      ],
    );
  }
}

// كارد نقطة الاشتباه — زي الفيقما
class _SuspiciousPointCard extends StatelessWidget {
  const _SuspiciousPointCard({required this.point, required this.onTap});
  final SuspiciousPoint point;
  final VoidCallback onTap;

  Color get _bg    => point.status == 'غير مطابق' ? const Color(0xFFFFEBEB) : const Color(0xFFFFFDE7);
  Color get _border => point.status == 'غير مطابق' ? const Color(0xFFEF5350) : const Color(0xFFFFEB3B);
  Color get _badgeBg => point.status == 'غير مطابق' ? const Color(0xFFEF5350)
                      : point.status == 'مطابق'     ? const Color(0xFF00D995)
                      : const Color(0xFFFFB300);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // الرقم + الحالة
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(color: _badgeBg, borderRadius: BorderRadius.circular(20)),
                child: Text(point.status, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
              Text('نقطة اشتباه #${point.number}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 6),
          // الوقت
          Text(point.time, style: const TextStyle(fontSize: 12, color: Color(0xFF757575)), textAlign: TextAlign.right),
          const SizedBox(height: 4),
          // الموقع
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(point.location, style: const TextStyle(fontSize: 12, color: Color(0xFF757575))),
              const SizedBox(width: 4),
              const Icon(Icons.location_on, size: 12, color: Color(0xFFEF5350)),
            ],
          ),
          const SizedBox(height: 10),
          // زر عرض والتحقق
          GestureDetector(
            onTap: onTap,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                Text('عرض والتحقق', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF3D5A6C))),
                SizedBox(width: 4),
                Icon(Icons.arrow_back_ios, size: 13, color: Color(0xFF3D5A6C)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CameraThumb extends StatelessWidget {
  const _CameraThumb({required this.time});
  final String time;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFFE0E0E0), borderRadius: BorderRadius.circular(10)),
      child: Stack(children: [
        Center(child: Icon(Icons.camera_alt, size: 32, color: Colors.grey.shade500)),
        Positioned(
          bottom: 6, left: 6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(6)),
            child: Text(time, style: const TextStyle(color: Colors.white, fontSize: 10)),
          ),
        ),
      ]),
    );
  }
}

import 'package:flutter/material.dart';
import 'verification_screen.dart';

// ── بيانات كل طفل ──
class _MissionData {
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
  final List<_SuspiciousPoint> points;

  const _MissionData({
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

class _SuspiciousPoint {
  final int number;
  final String location;
  final String time;
  final String status; // 'قيد المراجعة' | 'غير مطابق' | 'مطابق'

  const _SuspiciousPoint({
    required this.number,
    required this.location,
    required this.time,
    required this.status,
  });
}

// بيانات وهمية لكل طفل
final _missionsMap = <String, _MissionData>{
  '#1234': _MissionData(
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
      _SuspiciousPoint(
        number: 2,
        location: 'قرب الموقع المحدد - 200 متر',
        time: 'منذ 15 دقيقة',
        status: 'قيد المراجعة',
      ),
      _SuspiciousPoint(
        number: 1,
        location: 'حي النزهة - 500 متر',
        time: 'منذ 30 دقيقة',
        status: 'غير مطابق',
      ),
    ],
  ),
  '#1235': _MissionData(
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
      _SuspiciousPoint(
        number: 1,
        location: 'قرب الموقع المحدد - 200 متر شمالاً',
        time: 'منذ 15 دقيقة',
        status: 'قيد المراجعة',
      ),
    ],
  ),
  '#1232': _MissionData(
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
  static const Color _bg = Color(0xFFF4EFEB);

  @override
  Widget build(BuildContext context) {
    final data = _missionsMap[reportId] ?? _missionsMap['#1234']!;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _bg,
        body: SafeArea(
          child: Column(
            children: [
              // ── HEADER ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                color: _navy,
                child: Row(
                  children: [
                    const Spacer(),
                    Text(
                      'تفاصيل البلاغ ${data.reportId}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── حالة المهمة ──
                      _buildMissionStatusCard(data),
                      const SizedBox(height: 16),

                      // ── بيانات الطفل ──
                      _buildInfoCard(
                        title: 'بيانات الطفل',
                        children: [
                          _InfoRow(icon: Icons.person_outline, value: data.childName),
                          const SizedBox(height: 4),
                          _InfoRow(
                            icon: Icons.info_outline,
                            label: 'الوصف:',
                            value: data.childDescription,
                          ),
                          const SizedBox(height: 12),
                          _InfoRow(
                            icon: Icons.location_on_outlined,
                            label: 'آخر موقع',
                            value: data.lastLocation,
                          ),
                          const SizedBox(height: 12),
                          _InfoRow(
                            icon: Icons.access_time,
                            label: 'وقت الاختفاء',
                            value: data.disappearTime,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // ── بيانات ولي الأمر ──
                      _buildInfoCard(
                        title: 'بيانات ولي الأمر',
                        children: [
                          _InfoRow(icon: Icons.person_outline, label: 'الاسم', value: data.guardianName),
                          const SizedBox(height: 12),
                          _InfoRow(icon: Icons.phone_outlined, label: 'رقم الجوال', value: data.guardianPhone),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // ── زر الاتصال بولي الأمر ──
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.phone, color: Colors.white, size: 20),
                          label: const Text(
                            'الاتصال بولي الأمر',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _navy,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── الخريطة الحية ──
                      _buildInfoCard(
                        title: 'الخريطة الحية',
                        children: [
                          Container(
                            height: 160,
                            decoration: BoxDecoration(
                              color: const Color(0xFFCFDAE0),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Stack(
                              children: [
                                Center(
                                  child: Icon(Icons.map, size: 60, color: _navy.withOpacity(0.3)),
                                ),
                                Positioned(
                                  top: 10,
                                  right: 10,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: _navy,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      'في المنطقة • DR-01',
                                      style: const TextStyle(color: Colors.white, fontSize: 11),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 10,
                                  left: 10,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${data.scannedArea.toInt()}% ممسوحة',
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 14, color: Color(0xFFEF5350)),
                              const SizedBox(width: 4),
                              Text(
                                data.lastLocation,
                                style: const TextStyle(fontSize: 12, color: Color(0xFF757575)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.location_on, color: Colors.white, size: 18),
                              label: const Text(
                                'عرض الخريطة بملء الشاشة',
                                style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _navy,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // ── نقاط الاشتباه ──
                      _buildInfoCard(
                        title: 'نقاط الاشتباه',
                        trailing: '${data.points.length} نقطة',
                        children: data.points.isEmpty
                            ? [
                                const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(12),
                                    child: Text(
                                      'لا توجد نقاط اشتباه حتى الآن',
                                      style: TextStyle(color: Color(0xFF9E9E9E)),
                                    ),
                                  ),
                                )
                              ]
                            : data.points
                                .map(
                                  (p) => Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: _SuspiciousPointCard(
                                      point: p,
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => VerificationScreen(
                                            reportId: data.reportId,
                                            pointNumber: p.number,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                      const SizedBox(height: 16),

                      // ── لقطات من الكاميرا ──
                      _buildInfoCard(
                        title: 'لقطات من الكاميرا',
                        children: [
                          GridView.count(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              _CameraThumb(time: '18:14:40'),
                              _CameraThumb(time: '18:13:35'),
                              _CameraThumb(time: '18:16:50'),
                              _CameraThumb(time: '18:15:45'),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // ── التحكم بالمهمة ──
                      _buildInfoCard(
                        title: 'التحكم بالمهمة',
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton.icon(
                              onPressed: () => _showCompleteMissionDialog(context),
                              icon: const Icon(Icons.play_arrow, color: Colors.white),
                              label: const Text(
                                'بدء',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00D995),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildMissionStatusCard(_MissionData data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF3D5A6C),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF00D995),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'نشطة',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
              ),
              const Spacer(),
              const Text(
                'حالة المهمة',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _StatItem(label: 'المدة', value: data.missionDuration),
              const SizedBox(width: 24),
              _StatItem(label: 'وقت البدء', value: data.startTime),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _StatItem(label: 'نقاط الاشتباه', value: data.suspiciousPoints.toString()),
              const SizedBox(width: 24),
              _StatItem(label: 'المنطقة المسموحة', value: '${data.scannedArea.toInt()}%'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    String? trailing,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (trailing != null)
                Text(trailing, style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
              Text(
                title,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  void _showCompleteMissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('إتمام المهمة'),
          content: const Text('هل أنت متأكد من إتمام هذه المهمة؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00D995)),
              child: const Text('تأكيد', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── ويدجت إحصائية ──
class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});
  final String label, value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            )),
        Text(label,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 11,
            )),
      ],
    );
  }
}

// ── صف معلومة ──
class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, this.label, required this.value});
  final IconData icon;
  final String? label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (label != null)
                Text(label!,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
              if (label != null) const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Icon(icon, size: 20, color: const Color(0xFF9E9E9E)),
      ],
    );
  }
}

// ── كارد نقطة الاشتباه ──
class _SuspiciousPointCard extends StatelessWidget {
  const _SuspiciousPointCard({required this.point, required this.onTap});
  final _SuspiciousPoint point;
  final VoidCallback onTap;

  Color get _statusColor {
    switch (point.status) {
      case 'مطابق':
        return const Color(0xFF00D995);
      case 'غير مطابق':
        return const Color(0xFFEF5350);
      default:
        return const Color(0xFFFFEB3B);
    }
  }

  Color get _statusTextColor {
    switch (point.status) {
      case 'مطابق':
        return Colors.white;
      case 'غير مطابق':
        return Colors.white;
      default:
        return const Color(0xFFF57F17);
    }
  }

  Color get _borderColor {
    switch (point.status) {
      case 'مطابق':
        return const Color(0xFF00D995);
      case 'غير مطابق':
        return const Color(0xFFEF5350);
      default:
        return const Color(0xFFFFEB3B);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _borderColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor, width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'نقطة اشتباه #${point.number}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(point.location,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF757575))),
                    const SizedBox(width: 4),
                    const Icon(Icons.location_on, size: 12, color: Color(0xFFEF5350)),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(point.time,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
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
                  color: _statusColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  point.status,
                  style: TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w700, color: _statusTextColor),
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: onTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3D5A6C),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('عرض',
                      style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── لقطة كاميرا ──
class _CameraThumb extends StatelessWidget {
  const _CameraThumb({required this.time});
  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(Icons.camera_alt, size: 32, color: Colors.grey.shade500),
          ),
          Positioned(
            bottom: 6,
            right: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                time,
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

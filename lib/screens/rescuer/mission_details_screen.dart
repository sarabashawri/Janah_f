import 'package:flutter/material.dart';
import 'mission_control_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'Verification_screen.dart';

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
      SuspiciousPoint(
        number: 2,
        location: 'قرب الموقع المحدد - 200 متر',
        time: 'منذ 15 دقيقة',
        status: 'قيد المراجعة',
      ),
      SuspiciousPoint(
        number: 1,
        location: 'حي النزهة - 500 متر',
        time: 'منذ 30 دقيقة',
        status: 'غير مطابق',
      ),
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
      SuspiciousPoint(
        number: 1,
        location: 'قرب الموقع المحدد - 200 متر شمالاً',
        time: 'منذ 15 دقيقة',
        status: 'قيد المراجعة',
      ),
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
    points: const [],
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
    points: const [],
  ),
};

class MissionDetailsScreen extends StatelessWidget {
  final String reportId;
  const MissionDetailsScreen({super.key, this.reportId = '#1234'});

  static const Color _bg = Color(0xFFF4EFEB);
  static const Color _navy = Color(0xFF3D5A6C);
  static const Color _navy2 = Color(0xFF2E4A5A);
  static const Color _green = Color(0xFF16C47F);

  @override
  Widget build(BuildContext context) {
    final data = missionsMap[reportId] ?? missionsMap['#1234']!;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _bg,
        body: Column(
          children: [
            _Header(
              title: 'تفاصيل البلاغ ${data.reportId}',
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _StatusCard(data: data),
                    const SizedBox(height: 14),

                    _SectionCard(
                      title: 'بيانات الطفل',
                      child: Column(
                        children: [
                          _InfoRow(
                            leadingIcon: Icons.person_outline,
                            title: data.childName,
                            isBold: true,
                          ),
                          const SizedBox(height: 10),
                          _InfoRow(
                            leadingIcon: Icons.info_outline,
                            label: 'الوصف',
                            title: data.childDescription,
                          ),
                          const SizedBox(height: 12),
                          _InfoRow(
                            leadingIcon: Icons.location_on_outlined,
                            label: 'آخر موقع',
                            title: data.lastLocation,
                          ),
                          const SizedBox(height: 12),
                          _InfoRow(
                            leadingIcon: Icons.access_time,
                            label: 'وقت الاختفاء',
                            title: data.disappearTime,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    _SectionCard(
                      title: 'بيانات ولي الأمر',
                      child: Column(
                        children: [
                          _InfoRow(
                            leadingIcon: Icons.person_outline,
                            label: 'الاسم',
                            title: data.guardianName,
                          ),
                          const SizedBox(height: 12),
                          _InfoRow(
                            leadingIcon: Icons.phone_outlined,
                            label: 'رقم الجوال',
                            title: data.guardianPhone,
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.phone, color: Colors.white, size: 20),
                              label: const Text('الاتصال بولي الأمر',
                                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _navy,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    _SectionCard(
                      title: 'الخريطة الحية',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _MapPreview(scannedArea: data.scannedArea, location: const LatLng(24.7136, 46.6753)),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 14, color: Color(0xFFEF5350)),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  data.lastLocation,
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF757575)),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // ✅ (تعديل 2) زر الخريطة صار مريح
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton.icon(
                              onPressed: () => _openFullMap(context, data),
                              icon: const Icon(Icons.location_on, color: Colors.white, size: 18),
                              label: const Text(
                                'عرض الخريطة بملء الشاشة',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  height: 1.2,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _navy,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),




                    const SizedBox(height: 14),

                    _SectionCard(
                      title: 'التحكم بالمهمة',
                      child: SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MissionControlScreen(reportId: data.reportId, startActive: true))),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.play_arrow, color: Colors.white, size: 24),
                              SizedBox(width: 8),
                              Text(
                                'بدء',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
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
    );
  }

  void _openFullMap(BuildContext context, MissionData data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FullMapSheet(
        location: LatLng(24.7136, 46.6753),
        childName: data.childName,
      ),
    );
  }

  void _showCompleteMissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Text('إتمام المهمة'),
          content: const Text('هل أنت متأكد من إتمام هذه المهمة؟'),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('تأكيد', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.onBack});
  final String title;
  final VoidCallback onBack;

  static const Color _navy = Color(0xFF3D5A6C);
  static const Color _navy2 = Color(0xFF2E4A5A);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_navy2, _navy],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              // ✅ (تعديل 1) السهم صار forward في RTL
              IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 28),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.data});
  final MissionData data;

  static const Color _navy = Color(0xFF3D5A6C);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _navy,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text('حالة المهمة', style: TextStyle(color: Colors.white70, fontSize: 12)),
              const Spacer(),
              const Text(
                'نشطة',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
              ),
              const SizedBox(width: 8),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(color: Color(0xFF16C47F), shape: BoxShape.circle),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _MiniStat(label: 'وقت البدء', value: data.startTime)),
              Expanded(child: _MiniStat(label: 'المدة', value: data.missionDuration, alignEnd: true)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _MiniStat(label: 'المنطقة الممسوحة', value: '${data.scannedArea.toInt()}%')),
              Expanded(child: _MiniStat(label: 'نقاط الاشتباه', value: data.suspiciousPoints.toString(), alignEnd: true)),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value, this.alignEnd = false});
  final String label;
  final String value;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.leadingIcon,
    this.label,
    required this.title,
    this.isBold = false,
  });

  final IconData leadingIcon;
  final String? label;
  final String title;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(leadingIcon, size: 20, color: const Color(0xFF9E9E9E)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (label != null) ...[
                Text(label!, style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
                const SizedBox(height: 3),
              ],
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
                  color: const Color(0xFF222222),
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.text,
    required this.icon,
    required this.background,
    required this.onTap,
    this.height = 54,
    this.radius = 18,
  });

  final String text;
  final IconData icon;
  final Color background;
  final VoidCallback onTap;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white, size: 20),
        label: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800),
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: background,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
          elevation: 0,
        ),
      ),
    );
  }
}

class _MapPreview extends StatelessWidget {
  const _MapPreview({required this.scannedArea, this.location = const LatLng(24.7136, 46.6753)});
  final double scannedArea;
  final LatLng location;

  static const Color _navy = Color(0xFF3D5A6C);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        height: 170,
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(target: location, zoom: 15),
              markers: {
                Marker(
                  markerId: const MarkerId('child'),
                  position: location,
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                ),
              },
              zoomControlsEnabled: false,
              scrollGesturesEnabled: false,
              rotateGesturesEnabled: false,
              tiltGesturesEnabled: false,
              zoomGesturesEnabled: false,
              myLocationButtonEnabled: false,
              liteModeEnabled: true,
            ),
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: _navy, borderRadius: BorderRadius.circular(20)),
                child: const Text(
                  'في المنطقة • DR-01',
                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                child: Text(
                  '${scannedArea.toInt()}% ممسوحة',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuspiciousPointCard extends StatelessWidget {
  const _SuspiciousPointCard({required this.point, required this.onTap});
  final SuspiciousPoint point;
  final VoidCallback onTap;

  bool get isBad => point.status.trim() == 'غير مطابق';

  Color get bg => isBad ? const Color(0xFFFFEBEE) : const Color(0xFFFFF8E1);
  Color get border => isBad ? const Color(0xFFEF5350) : const Color(0xFFFFD54F);
  Color get badge => isBad ? const Color(0xFFEF5350) : const Color(0xFFFFB300);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border, width: 1.6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان يمين + (يسار: بادج فوق + عرض والتحقق تحتها)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'نقطة اشتباه #${point.number}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: badge, borderRadius: BorderRadius.circular(18)),
                    child: Text(
                      point.status,
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
                    ),
                  ),

                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(point.time, style: const TextStyle(fontSize: 12, color: Color(0xFF757575))),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_on, size: 14, color: Color(0xFFEF5350)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  point.location,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF757575)),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(12),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('عرض والتحقق',
                        style: TextStyle(color: Color(0xFF3D5A6C), fontWeight: FontWeight.w900, fontSize: 12)),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios, size: 12, color: Color(0xFF3D5A6C)),
                  ],
                ),
              ),
            ],
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        color: const Color(0xFFE0E0E0),
        child: Stack(
          children: [
            Center(
              child: Icon(Icons.camera_alt_outlined, size: 34, color: Colors.grey.shade600),
            ),
            Positioned(
              bottom: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.camera_alt, size: 12, color: Colors.white),
                    const SizedBox(width: 6),
                    Text(
                      time,
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── شيت الخريطة الكاملة ──
class _FullMapSheet extends StatefulWidget {
  final LatLng location;
  final String childName;
  const _FullMapSheet({required this.location, required this.childName});

  @override
  State<_FullMapSheet> createState() => _FullMapSheetState();
}

class _FullMapSheetState extends State<_FullMapSheet> {
  GoogleMapController? _mapController;
  LatLng? _myLocation;
  bool _loading = false;

  Future<void> _goToMyLocation() async {
    setState(() => _loading = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) { setState(() => _loading = false); return; }
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.deniedForever) { setState(() => _loading = false); return; }
      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.medium);
      final myPos = LatLng(pos.latitude, pos.longitude);
      setState(() { _myLocation = myPos; _loading = false; });
      _mapController?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: myPos, zoom: 16)));
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('child'),
        position: widget.location,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(title: 'آخر موقع - ${widget.childName}'),
      ),
      if (_myLocation != null)
        Marker(
          markerId: const MarkerId('me'),
          position: _myLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(title: 'موقعي'),
        ),
    };

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // هاندل
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40, height: 4,
              decoration: BoxDecoration(color: const Color(0xFFE0E0E0), borderRadius: BorderRadius.circular(2)),
            ),
            // هيدر
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('الخريطة الحية', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                ],
              ),
            ),
            // الخريطة
            Expanded(
              child: Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(target: widget.location, zoom: 15),
                    onMapCreated: (c) => _mapController = c,
                    markers: markers,
                    myLocationEnabled: false,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: true,
                  ),

                ],
              ),
            ),
            // زر إغلاق
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3D5A6C),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('إغلاق', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

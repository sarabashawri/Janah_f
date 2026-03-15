import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'mission_control_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'Verification_screen.dart';

class MissionDetailsScreen extends StatelessWidget {
  final String reportId;
  const MissionDetailsScreen({super.key, this.reportId = ''});

  static const Color _bg    = Color(0xFFF4EFEB);
  static const Color _navy  = Color(0xFF3D5A6C);
  static const Color _navy2 = Color(0xFF2E4A5A);
  static const Color _green = Color(0xFF16C47F);

  @override
  Widget build(BuildContext context) {
    if (reportId.isEmpty) {
      return const Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(body: Center(child: Text('لا توجد بيانات'))),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _bg,
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('reports').doc(reportId).snapshots(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF3D5A6C)));
            }
            if (!snap.hasData || !snap.data!.exists) {
              return const Center(child: Text('البلاغ غير موجود'));
            }

            final data = snap.data!.data() as Map<String, dynamic>;
            final childName       = data['childName']       ?? 'غير محدد';
            final description     = data['description']     ?? '';
            final location        = data['location']        ?? '';
            final clothingColor   = data['clothingColor']   ?? '';
            final guardianName    = data['guardianName']    ?? '';
            final guardianPhone   = data['guardianPhone']   ?? '';
            final status          = data['status']          ?? 'pending';
            final guardianId      = data['guardianId']      ?? '';
            final lat             = (data['latitude']  as num?)?.toDouble() ?? 24.7136;
            final lng             = (data['longitude'] as num?)?.toDouble() ?? 46.6753;
            final childPos        = LatLng(lat, lng);

            // وقت الاختفاء
            String disappearTime = '';
            if (data['createdAt'] != null) {
              final ts = data['createdAt'] as Timestamp;
              final dt = ts.toDate();
              disappearTime = '${dt.year}/${dt.month}/${dt.day}  ${dt.hour}:${dt.minute.toString().padLeft(2,'0')}';
            }

            return Column(
              children: [
                _Header(
                  title: 'تفاصيل البلاغ',
                  onBack: () => Navigator.of(context).pop(),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [

                        // بيانات الطفل
                        _SectionCard(
                          title: 'بيانات الطفل',
                          child: Column(
                            children: [
                              _InfoRow(leadingIcon: Icons.person_outline, title: childName, isBold: true),
                              if (clothingColor.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                _InfoRow(leadingIcon: Icons.checkroom_outlined, label: 'لون الملابس العلوية', title: clothingColor),
                              ],
                              if (description.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                _InfoRow(leadingIcon: Icons.description_outlined, label: 'وصف إضافي', title: description),
                              ],
                              if (disappearTime.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                _InfoRow(leadingIcon: Icons.access_time, label: 'وقت الإبلاغ', title: disappearTime),
                              ],
                              const SizedBox(height: 12),
                              // حالة البلاغ
                              _StatusBadge(status: status),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        // بيانات ولي الأمر
                        _SectionCard(
                          title: 'بيانات ولي الأمر',
                          child: Column(
                            children: [
                              if (guardianName.isNotEmpty)
                                _InfoRow(leadingIcon: Icons.person_outline, label: 'الاسم', title: guardianName),
                              if (guardianPhone.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                _InfoRow(leadingIcon: Icons.phone_outlined, label: 'رقم الجوال', title: guardianPhone),
                              ],
                              const SizedBox(height: 14),
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton.icon(
                                  onPressed: guardianPhone.isNotEmpty ? () {} : null,
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

                        // الخريطة
                        _SectionCard(
                          title: 'الخريطة الحية',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _MapPreview(location: childPos),
                              const SizedBox(height: 10),
                              if (location.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF9F9F9),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: const Color(0xFFE0E0E0)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.location_on, size: 16, color: Color(0xFFEF5350)),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('آخر موقع للطفل',
                                                style: TextStyle(fontSize: 10, color: Color(0xFF9E9E9E))),
                                            const SizedBox(height: 2),
                                            Text(location,
                                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                                overflow: TextOverflow.ellipsis),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton.icon(
                                  onPressed: () => _openFullMap(context, childPos, childName),
                                  icon: const Icon(Icons.location_on, color: Colors.white, size: 18),
                                  label: const Text('عرض الخريطة بملء الشاشة',
                                      style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800)),
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

                        // التحكم بالمهمة
                        _SectionCard(
                          title: 'التحكم بالمهمة',
                          child: SizedBox(
                            height: 56,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _green,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                elevation: 0,
                              ),
                              onPressed: () => Navigator.push(context,
                                  MaterialPageRoute(builder: (_) => MissionControlScreen(reportId: reportId, startActive: true))),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.play_arrow, color: Colors.white, size: 24),
                                  SizedBox(width: 8),
                                  Text('بدء التحكم', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
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
            );
          },
        ),
      ),
    );
  }

  void _openFullMap(BuildContext context, LatLng pos, String childName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FullMapSheet(location: pos, childName: childName),
    );
  }
}

// ── Header ──
class _Header extends StatelessWidget {
  const _Header({required this.title, required this.onBack});
  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2E4A5A), Color(0xFF3D5A6C)],
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
              IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title, textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
              ),
              const SizedBox(width: 28),
            ],
          ),
        ),
      ),
    );
  }
}

// ── SectionCard ──
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 6))],
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

// ── InfoRow ──
class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.leadingIcon, this.label, required this.title, this.isBold = false});
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
              Text(title, style: TextStyle(
                fontSize: 14,
                fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
                color: const Color(0xFF222222),
              )),
            ],
          ),
        ),
      ],
    );
  }
}

// ── StatusBadge ──
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final String status;

  String get label {
    switch (status) {
      case 'pending':    return 'قيد الانتظار';
      case 'accepted':   return 'تم القبول';
      case 'searching':  return 'جاري البحث';
      case 'matchFound': return 'تم العثور';
      case 'resolved':   return 'تم الإغلاق';
      default:           return 'قيد الانتظار';
    }
  }

  Color get color {
    switch (status) {
      case 'pending':    return const Color(0xFFFF9800);
      case 'accepted':   return const Color(0xFF2196F3);
      case 'searching':  return const Color(0xFF2196F3);
      case 'matchFound': return const Color(0xFF00D995);
      case 'resolved':   return const Color(0xFF9E9E9E);
      default:           return const Color(0xFFFF9800);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.4))),
        child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
      ),
    );
  }
}

// ── MapPreview ──
class _MapPreview extends StatelessWidget {
  const _MapPreview({required this.location});
  final LatLng location;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        height: 170,
        child: GoogleMap(
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
      ),
    );
  }
}

// ── FullMapSheet ──
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

  Future<void> _goToMyLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.deniedForever) return;
      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.medium);
      final myPos = LatLng(pos.latitude, pos.longitude);
      setState(() => _myLocation = myPos);
      _mapController?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: myPos, zoom: 16)));
    } catch (_) {}
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
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40, height: 4,
              decoration: BoxDecoration(color: const Color(0xFFE0E0E0), borderRadius: BorderRadius.circular(2)),
            ),
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
                  Positioned(
                    bottom: 16, left: 16,
                    child: FloatingActionButton.small(
                      onPressed: _goToMyLocation,
                      backgroundColor: const Color(0xFF3D5A6C),
                      child: const Icon(Icons.my_location, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity, height: 52,
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

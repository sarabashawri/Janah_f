import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RescuerMapScreen extends StatefulWidget {
  const RescuerMapScreen({super.key});

  @override
  State<RescuerMapScreen> createState() => _RescuerMapScreenState();
}

class _RescuerMapScreenState extends State<RescuerMapScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  bool _isLoading = true;
  int _activeCount = 0;

  // مركز افتراضي - الرياض
  static const LatLng _defaultCenter = LatLng(24.7136, 46.6753);

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    final snap = await FirebaseFirestore.instance
        .collection('reports')
        .where('status', isEqualTo: 'active')
        .get();

    final markers = <Marker>{};
    int activeCount = 0;

    for (final doc in snap.docs) {
      final data = doc.data();
      final lat = data['latitude'] as double?;
      final lng = data['longitude'] as double?;
      if (lat == null || lng == null) continue;

      activeCount++;
      markers.add(
        Marker(
          markerId: MarkerId(doc.id),
          position: LatLng(lat, lng),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: data['childName'] ?? 'طفل مفقود',
            snippet: data['location'] ?? '',
            onTap: () {
              Navigator.of(context).pushNamed(
                '/rescuer/mission-details',
                arguments: doc.id,
              );
            },
          ),
        ),
      );
    }

    if (mounted) {
      setState(() {
        _markers.clear();
        _markers.addAll(markers);
        _activeCount = activeCount;
        _isLoading = false;
      });

      // إذا في بلاغات، انتقل لأول موقع
      if (markers.isNotEmpty) {
        final first = markers.first.position;
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(first, 13),
        );
      }
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                color: const Color(0xFF3D5A6C),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'خريطة البلاغات',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.circle, color: Color(0xFF00D995), size: 10),
                          const SizedBox(width: 6),
                          Text(
                            '$_activeCount بلاغ نشط',
                            style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // الخريطة
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF3D5A6C)))
                    : Stack(
                        children: [
                          GoogleMap(
                            initialCameraPosition: const CameraPosition(
                              target: _defaultCenter,
                              zoom: 11,
                            ),
                            onMapCreated: (controller) {
                              _mapController = controller;
                            },
                            markers: _markers,
                            myLocationEnabled: true,
                            myLocationButtonEnabled: false,
                            zoomControlsEnabled: false,
                            mapToolbarEnabled: false,
                          ),

                          // زر تحديث
                          Positioned(
                            bottom: 24,
                            left: 16,
                            child: FloatingActionButton.small(
                              onPressed: _loadReports,
                              backgroundColor: const Color(0xFF3D5A6C),
                              child: const Icon(Icons.refresh, color: Colors.white),
                            ),
                          ),

                          // زر موقعي
                          Positioned(
                            bottom: 24,
                            right: 16,
                            child: FloatingActionButton.small(
                              onPressed: () {
                                _mapController?.animateCamera(
                                  CameraUpdate.newLatLngZoom(_defaultCenter, 11),
                                );
                              },
                              backgroundColor: Colors.white,
                              child: const Icon(Icons.my_location, color: Color(0xFF3D5A6C)),
                            ),
                          ),

                          // إذا ما في بلاغات
                          if (_markers.isEmpty)
                            Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
                                  ],
                                ),
                                child: const Text(
                                  'لا توجد بلاغات نشطة حالياً',
                                  style: TextStyle(fontSize: 14, color: Color(0xFF757575)),
                                ),
                              ),
                            ),
                        ],
                      ),
              ),

              // مفتاح الألوان
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                color: Colors.white,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_on, color: Color(0xFFEF5350), size: 18),
                    SizedBox(width: 6),
                    Text('بلاغ نشط', style: TextStyle(fontSize: 13, color: Color(0xFF757575))),
                    SizedBox(width: 24),
                    Icon(Icons.location_on, color: Color(0xFF2196F3), size: 18),
                    SizedBox(width: 6),
                    Text('قيد المتابعة', style: TextStyle(fontSize: 13, color: Color(0xFF757575))),
                    SizedBox(width: 24),
                    Icon(Icons.location_on, color: Color(0xFF00D995), size: 18),
                    SizedBox(width: 6),
                    Text('تم العثور', style: TextStyle(fontSize: 13, color: Color(0xFF757575))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

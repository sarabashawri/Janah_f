import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'mission_details_screen.dart';

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
  String _selectedFilter = 'الكل';

  static const LatLng _defaultCenter = LatLng(24.7136, 46.6753);

  final List<String> _filters = ['الكل', 'قيد الانتظار', 'جاري البحث', 'تم العثور'];

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() => _isLoading = true);

    Query query = FirebaseFirestore.instance.collection('reports');
    if (_selectedFilter != 'الكل') {
      final statusMap = {
        'قيد الانتظار': 'pending',
        'جاري البحث': 'searching',
        'تم العثور': 'matchFound',
      };
      query = query.where('status', isEqualTo: statusMap[_selectedFilter]);
    }

    final snap = await query.get();
    final markers = <Marker>{};
    int activeCount = 0;

    for (final doc in snap.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final lat = data['latitude'] as double?;
      final lng = data['longitude'] as double?;
      if (lat == null || lng == null) continue;

      activeCount++;
      final status = data['status'] ?? 'pending';
      final hue = status == 'matchFound'
          ? BitmapDescriptor.hueGreen
          : status == 'searching'
              ? BitmapDescriptor.hueAzure
              : BitmapDescriptor.hueRed;

      markers.add(
        Marker(
          markerId: MarkerId(doc.id),
          position: LatLng(lat, lng),
          icon: BitmapDescriptor.defaultMarkerWithHue(hue),
          infoWindow: InfoWindow(
            title: data['childName'] ?? 'طفل مفقود',
            snippet: '📍 ${data['location'] ?? ''}',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MissionDetailsScreen(reportId: doc.id))),
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
      if (markers.isNotEmpty) {
        _mapController?.animateCamera(CameraUpdate.newLatLngZoom(markers.first.position, 13));
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
              // HEADER
              Container(
                width: double.infinity,
                color: const Color(0xFF3D5A6C),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('خريطة البلاغات',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(children: [
                            const Icon(Icons.circle, color: Color(0xFF00D995), size: 10),
                            const SizedBox(width: 6),
                            Text('$_activeCount بلاغ نشط',
                                style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600)),
                          ]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // فلاتر
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _filters.map((f) {
                          final selected = f == _selectedFilter;
                          return Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: GestureDetector(
                              onTap: () {
                                setState(() => _selectedFilter = f);
                                _loadReports();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                decoration: BoxDecoration(
                                  color: selected ? Colors.white : Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(f,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: selected ? const Color(0xFF3D5A6C) : Colors.white,
                                    )),
                              ),
                            ),
                          );
                        }).toList(),
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
                            initialCameraPosition: const CameraPosition(target: _defaultCenter, zoom: 11),
                            onMapCreated: (c) => _mapController = c,
                            markers: _markers,
                            myLocationEnabled: true,
                            myLocationButtonEnabled: false,
                            zoomControlsEnabled: false,
                            mapToolbarEnabled: false,
                          ),
                          Positioned(
                            bottom: 24, left: 16,
                            child: FloatingActionButton.small(
                              onPressed: _loadReports,
                              backgroundColor: const Color(0xFF3D5A6C),
                              child: const Icon(Icons.refresh, color: Colors.white),
                            ),
                          ),
                          Positioned(
                            bottom: 24, right: 16,
                            child: FloatingActionButton.small(
                              onPressed: () => _mapController?.animateCamera(
                                  CameraUpdate.newLatLngZoom(_defaultCenter, 11)),
                              backgroundColor: Colors.white,
                              child: const Icon(Icons.my_location, color: Color(0xFF3D5A6C)),
                            ),
                          ),
                          if (_markers.isEmpty && !_isLoading)
                            Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
                                ),
                                child: const Text('لا توجد بلاغات في هذا التصنيف',
                                    style: TextStyle(fontSize: 14, color: Color(0xFF757575))),
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
                    SizedBox(width: 4),
                    Text('نشط', style: TextStyle(fontSize: 12, color: Color(0xFF757575))),
                    SizedBox(width: 20),
                    Icon(Icons.location_on, color: Color(0xFF2196F3), size: 18),
                    SizedBox(width: 4),
                    Text('قيد المتابعة', style: TextStyle(fontSize: 12, color: Color(0xFF757575))),
                    SizedBox(width: 20),
                    Icon(Icons.location_on, color: Color(0xFF00D995), size: 18),
                    SizedBox(width: 4),
                    Text('تم العثور', style: TextStyle(fontSize: 12, color: Color(0xFF757575))),
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

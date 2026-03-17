import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'missions_list_screen.dart';
import 'rescuer_profile_screen.dart';
import 'rescuer_notifications_screen.dart';
import 'rescuer_map_screen.dart';
import 'mission_details_screen.dart';
import 'rescuer_create_report_screen.dart';

class RescuerHomeScreen extends StatefulWidget {
  const RescuerHomeScreen({super.key});
  @override
  State<RescuerHomeScreen> createState() => _RescuerHomeScreenState();
}

class _RescuerHomeScreenState extends State<RescuerHomeScreen> {
  int _selectedIndex = 0;
  final List<Widget> _screens = const [
    HomeDashboard(),
    MissionsListScreen(),
    RescuerMapScreen(),
    RescuerProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: _screens[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (i) => setState(() => _selectedIndex = i),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF3D5A6C),
          unselectedItemColor: const Color(0xFF9E9E9E),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'الرئيسية'),
            BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), activeIcon: Icon(Icons.assignment), label: 'البلاغات'),
            BottomNavigationBarItem(icon: Icon(Icons.map_outlined), activeIcon: Icon(Icons.map), label: 'الخريطة'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'الملف'),
          ],
        ),
      ),
    );
  }
}

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});
  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  final _db = FirebaseFirestore.instance;
  String _rescuerName = '';
  String _teamNumber = '';

  @override
  void initState() {
    super.initState();
    _loadRescuerData();
  }

  Future<void> _loadRescuerData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final doc = await _db.collection('users').doc(uid).get();
    if (mounted && doc.exists) {
      setState(() {
        _rescuerName = doc.data()?['name'] ?? 'المنقذ';
        _teamNumber = doc.data()?['teamNumber'] ?? '';
      });
    }
  }

  String _timeAgo(Timestamp? ts) {
    if (ts == null) return '';
    final diff = DateTime.now().difference(ts.toDate());
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    return 'منذ ${diff.inDays} يوم';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: const Color(0xFFF4EFEB),
        child: CustomScrollView(
          slivers: [

            // HEADER
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(24),
                color: const Color(0xFF3D5A6C),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(radius: 28, backgroundColor: Colors.white24, child: Icon(Icons.person, color: Colors.white, size: 32)),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('مرحباً بك', style: TextStyle(fontSize: 12, color: Colors.white70)),
                            const SizedBox(height: 2),
                            Text(_rescuerName.isEmpty ? '...' : _rescuerName,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                            const SizedBox(height: 4),
                            Text(_teamNumber.isNotEmpty ? 'فريق الإنقاذ - $_teamNumber' : 'فريق الإنقاذ',
                                style: const TextStyle(fontSize: 12, color: Colors.white60)),
                          ],
                        ),
                      ],
                    ),
                    StreamBuilder<QuerySnapshot>(
                      stream: _db.collection('notifications').where('isRead', isEqualTo: false).snapshots(),
                      builder: (context, snap) {
                        final unread = snap.data?.docs.length ?? 0;
                        return Stack(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RescuerNotificationsScreen())),
                              icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 28),
                            ),
                            if (unread > 0)
                              Positioned(
                                right: 8, top: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(color: Color(0xFFEF5350), shape: BoxShape.circle),
                                  constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                                  child: Text('$unread',
                                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                                      textAlign: TextAlign.center),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // ── بلّغ عن الطفل المفقود ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3D5A6C),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('بلّغ عن الطفل المفقود',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                            SizedBox(height: 4),
                            Text('قم بتقديم بلاغ جديد للبحث عن طفل مفقود',
                                style: TextStyle(fontSize: 12, color: Colors.white70)),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const RescuerCreateReportScreen())),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00D995),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('بلّغ الآن', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // إحصائيات من Firestore
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: StreamBuilder<QuerySnapshot>(
                  stream: _db.collection('reports').snapshots(),
                  builder: (context, snap) {
                    final docs = snap.data?.docs ?? [];
                    final newReports = docs.where((d) {
                      final s = (d.data() as Map)['status'];
                      return s == 'pending' || s == 'active';
                    }).length;
                    final inProgress = docs.where((d) {
                      final s = (d.data() as Map)['status'];
                      return s == 'accepted' || s == 'searching' || s == 'inProgress';
                    }).length;
                    final found = docs.where((d) {
                      final s = (d.data() as Map)['status'];
                      return s == 'matchFound' || s == 'resolved' || s == 'found' || s == 'closed';
                    }).length;
                    final total = docs.length;
                    final rate = total == 0 ? '0%' : '${((found / total) * 100).toInt()}%';
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white, borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(children: [
                            Icon(Icons.bar_chart_rounded, color: Color(0xFF3D5A6C), size: 18),
                            SizedBox(width: 6),
                            Text('إحصائيات', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                          ]),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(child: _StatCard(title: 'بلاغات جديدة', count: '$newReports', icon: Icons.flag_rounded, color: const Color(0xFFEF5350))),
                              const SizedBox(width: 10),
                              Expanded(child: _StatCard(title: 'قيد المتابعة', count: '$inProgress', icon: Icons.pending_actions, color: const Color(0xFF2196F3))),
                              const SizedBox(width: 10),
                              Expanded(child: _StatCard(title: 'تم العثور', count: '$found', icon: Icons.check_circle, color: const Color(0xFF00D995))),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(child: _StatCard(title: 'معدل النجاح', count: rate, icon: Icons.trending_up, color: const Color(0xFF00D995))),
                              const SizedBox(width: 10),
                              Expanded(child: _StatCard(title: 'إجمالي البلاغات', count: '$total', icon: Icons.assignment, color: const Color(0xFF9C27B0))),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

            // البلاغات النشطة
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('البلاغات النشطة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                          TextButton(
                            onPressed: () => setState(() => _selectedIndex = 1),
                            child: const Text('عرض الكل', style: TextStyle(fontSize: 13, color: Color(0xFF3D5A6C))),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      StreamBuilder<QuerySnapshot>(
                        stream: _db.collection('reports').where('status', whereIn: ['pending', 'accepted', 'searching', 'active', 'inProgress']).orderBy('createdAt', descending: true).limit(3).snapshots(),
                        builder: (context, snap) {
                          if (snap.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator(color: Color(0xFF3D5A6C)));
                          }
                          final docs = snap.data?.docs ?? [];
                          if (docs.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.all(20),
                              child: Text('لا توجد بلاغات نشطة حالياً', style: TextStyle(color: Color(0xFF9E9E9E))),
                            );
                          }
                          return Column(
                            children: docs.map((doc) {
                              final data = doc.data() as Map<String, dynamic>;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _ActiveMissionCard(
                                  childName: data['childName'] ?? '',
                                  location: data['location'] ?? '',
                                  timeAgo: _timeAgo(data['createdAt'] as Timestamp?),
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MissionDetailsScreen(reportId: doc.id))),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // الخريطة
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('الخريطة العامة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: const SizedBox(
                          height: 200, width: double.infinity,
                          child: GoogleMap(
                            initialCameraPosition: CameraPosition(target: LatLng(24.7136, 46.6753), zoom: 12),
                            zoomControlsEnabled: false,
                            myLocationButtonEnabled: false,
                            liteModeEnabled: true,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RescuerMapScreen())),
                          icon: const Icon(Icons.location_on, size: 18, color: Colors.white),
                          label: const Text('عرض الخريطة الكاملة', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3D5A6C),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.title, required this.count, required this.icon, required this.color});
  final String title, count;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle), child: Icon(icon, color: color, size: 20)),
          const SizedBox(height: 8),
          Text(count, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 11, color: Color(0xFF757575)), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _ActiveMissionCard extends StatelessWidget {
  const _ActiveMissionCard({required this.childName, required this.location, required this.timeAgo, required this.onTap});
  final String childName, location, timeAgo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEF5350).withOpacity(0.4), width: 1.5),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(childName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFEF5350), borderRadius: BorderRadius.circular(20)),
                  child: const Text('نشط', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(children: [const Icon(Icons.location_on, size: 13, color: Color(0xFFEF5350)), const SizedBox(width: 4), Flexible(child: Text(location, style: const TextStyle(fontSize: 12, color: Color(0xFF757575)), overflow: TextOverflow.ellipsis))]),
            const SizedBox(height: 4),
            Row(children: [const Icon(Icons.access_time, size: 13, color: Color(0xFF9E9E9E)), const SizedBox(width: 4), Text(timeAgo, style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)))]),
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 8),
            const Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              Text('عرض التفاصيل', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF3D5A6C))),
              SizedBox(width: 4),
              Icon(Icons.arrow_forward, size: 15, color: Color(0xFF3D5A6C)),
            ]),
          ],
        ),
      ),
    );
  }
}

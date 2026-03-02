import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'missions_list_screen.dart';
import 'rescuer_profile_screen.dart';
import 'rescuer_notifications_screen.dart';
import 'rescuer_create_report_screen.dart';
import 'rescuer_map_screen.dart';

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
    Center(child: Text('الخريطة')),
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
          onTap: (index) => setState(() => _selectedIndex = index),
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
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: const Color(0xFFF4EFEB),
        child: CustomScrollView(
          slivers: [

            // ── HEADER ──
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(24),
                color: const Color(0xFF3D5A6C),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // أيقونة + اسم يمين
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.white24,
                          child: Icon(Icons.person, color: Colors.white, size: 32),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('مرحباً بك', style: TextStyle(fontSize: 12, color: Colors.white70)),
                            SizedBox(height: 2),
                            Text('خالد الشهري', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                            SizedBox(height: 4),
                            Text('فريق الإنقاذ - جناح', style: TextStyle(fontSize: 12, color: Colors.white60)),
                          ],
                        ),
                      ],
                    ),
                    // إشعارات يسار
                    Stack(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RescuerNotificationsScreen())),
                          icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 28),
                        ),
                        Positioned(
                          right: 8, top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(color: Color(0xFFEF5350), shape: BoxShape.circle),
                            constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                            child: const Text('2', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── كارد بلّغ عن طفل مفقود ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('بلّغ عن الطفل المفقود', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                            SizedBox(height: 4),
                            Text('قم بتقديم بلاغ جديد للبحث عن طفل مفقود', style: TextStyle(fontSize: 12, color: Color(0xFF757575))),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pushNamed('/rescuer/mission-details'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3D5A6C),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('بلّغ الآن', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── إحصائيات اليوم ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: const [
                        Icon(Icons.bar_chart_rounded, color: Color(0xFF3D5A6C), size: 18),
                        SizedBox(width: 6),
                        Text('إحصائيات اليوم', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      ]),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _StatCard(title: 'مراقبة جارية', count: '1', icon: Icons.remove_red_eye, color: const Color(0xFFFFEB3B))),
                          const SizedBox(width: 10),
                          Expanded(child: _StatCard(title: 'بلاغات جديدة', count: '1', icon: Icons.flag_rounded, color: const Color(0xFFEF5350))),
                          const SizedBox(width: 10),
                          Expanded(child: _StatCard(title: 'قيد المتابعة', count: '1', icon: Icons.pending_actions, color: const Color(0xFF2196F3))),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: _StatCard(title: 'معدل النجاح', count: '94%', icon: Icons.trending_up, color: const Color(0xFF00D995))),
                          const SizedBox(width: 10),
                          Expanded(child: _StatCard(title: 'متوسط الوقت', count: '12 د', icon: Icons.timer_outlined, color: const Color(0xFF9C27B0))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── البلاغات النشطة ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('البلاغات النشطة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                          TextButton(
                            onPressed: () => Navigator.of(context).pushNamed('/rescuer/missions'),
                            child: const Text('عرض الكل', style: TextStyle(fontSize: 13, color: Color(0xFF3D5A6C))),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _ActiveMissionCard(
                        reportId: '#1234', childName: 'محمد أحمد', droneId: 'DR-01',
                        battery: 85, location: 'حي النزهة، شارع الملك فهد',
                        status: '🚨 عاجل', isUrgent: true,
                        onTap: () => Navigator.of(context).pushNamed('/rescuer/mission-details'),
                      ),
                      const SizedBox(height: 10),
                      _ActiveMissionCard(
                        reportId: '#1235', childName: 'عبدالله محمد', droneId: 'DR-02',
                        battery: 62, location: 'حي الربوة، شارع العليا',
                        status: 'نشطة', isUrgent: false,
                        onTap: () => Navigator.of(context).pushNamed('/rescuer/mission-details'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── الخريطة العامة ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('الخريطة العامة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                    // الخريطة
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(
                        height: 200,
                        width: double.infinity,
                        child: Stack(
                          children: [
                            GoogleMap(
                              initialCameraPosition: const CameraPosition(target: LatLng(24.7136, 46.6753), zoom: 13),
                              markers: {
                                const Marker(markerId: MarkerId('m1'), position: LatLng(24.7180, 46.6800), infoWindow: InfoWindow(title: 'بلاغ #1234')),
                                const Marker(markerId: MarkerId('m2'), position: LatLng(24.7090, 46.6700), infoWindow: InfoWindow(title: 'بلاغ #1235')),
                              },
                              zoomControlsEnabled: false,
                              myLocationButtonEnabled: false,
                              liteModeEnabled: true,
                            ),
                            Positioned(
                              top: 10, right: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
                                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)]),
                                child: const Text('2 مواقع نشطة', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF3D5A6C))),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // زر عرض الخريطة تحت الخريطة
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

            // ── حالة الطائرات ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('حالة الطائرات', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    _DroneCard(
                      droneId: 'DR-01', isOnline: true, battery: 85,
                      timeAgo: 'منذ 2 دقيقة', location: 'حي النزهة - بلاغ #1234',
                      onTap: () => Navigator.of(context).pushNamed('/rescuer/mission-details'),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),
          ],
        ),
      ),
    );
  }
}

// ─── WIDGETS ───

class _StatCard extends StatelessWidget {
  const _StatCard({required this.title, required this.count, required this.icon, required this.color});
  final String title;
  final String count;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
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
  const _ActiveMissionCard({
    required this.reportId, required this.childName, required this.droneId,
    required this.battery, required this.location, required this.status,
    required this.isUrgent, required this.onTap,
  });
  final String reportId, childName, droneId, location, status;
  final int battery;
  final bool isUrgent;
  final VoidCallback onTap;

  Color get _batteryColor => battery >= 60 ? const Color(0xFF00D995) : battery >= 30 ? const Color(0xFFFFEB3B) : const Color(0xFFEF5350);
  Color get _borderColor => isUrgent ? const Color(0xFFEF5350) : const Color(0xFFFFEB3B);
  Color get _statusBg => isUrgent ? const Color(0xFFEF5350) : const Color(0xFFFFEB3B);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _borderColor, width: 1.5),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // صف 1: رقم البلاغ + اسم يسار | الحالة يمين
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // يسار: رقم البلاغ + اسم تحته
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('بلاغ رقم $reportId', style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
                    const SizedBox(height: 4),
                    Text(childName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  ],
                ),
                const Spacer(),
                // يمين: الحالة
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: _statusBg, borderRadius: BorderRadius.circular(20)),
                  child: Text(status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: isUrgent ? Colors.white : Colors.black87)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // موقع — يسار
            Row(
              children: [
                const Icon(Icons.location_on, size: 13, color: Color(0xFFEF5350)),
                const SizedBox(width: 4),
                Flexible(child: Text(location, style: const TextStyle(fontSize: 12, color: Color(0xFF757575)), overflow: TextOverflow.ellipsis)),
              ],
            ),
            const SizedBox(height: 8),
            // الدرون — يسار
            Row(
              children: [
                const Icon(Icons.flight, color: Color(0xFF3D5A6C), size: 14),
                const SizedBox(width: 4),
                Text(droneId, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF3D5A6C))),
                const Text(' • ', style: TextStyle(color: Color(0xFF9E9E9E))),
                Text('البطارية: $battery%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _batteryColor)),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),
            // منذ X يسار | عرض التفاصيل يمين
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('منذ 3 ساعات', style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
                const Row(
                  children: [
                    Text('عرض التفاصيل', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF3D5A6C))),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward, size: 15, color: Color(0xFF3D5A6C)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DroneCard extends StatelessWidget {
  const _DroneCard({required this.droneId, required this.isOnline, required this.battery, required this.timeAgo, required this.location, required this.onTap});
  final String droneId, timeAgo, location;
  final bool isOnline;
  final int battery;
  final VoidCallback onTap;

  Color get _batteryColor => battery >= 60 ? const Color(0xFF00D995) : battery >= 30 ? const Color(0xFFFFEB3B) : const Color(0xFFEF5350);

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
        children: [
          // صف 1: أيقونة + ID يسار | "في مهمة" يمين
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: const Color(0xFF3D5A6C), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.flight, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(droneId, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                      const Text('88 ساعة طيران', style: TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(color: const Color(0xFF3D5A6C), borderRadius: BorderRadius.circular(20)),
                child: const Text('في مهمة', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // صف 2: مربع البطارية يسار | مربع الاتصال يمين (نفس الحجم)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // البطارية يسار
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFFF4EFEB), borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: const [
                          Icon(Icons.battery_charging_full, size: 14, color: Color(0xFF757575)),
                          SizedBox(width: 4),
                          Text('البطارية', style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
                        ]),
                        const SizedBox(height: 6),
                        Text('$battery%', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _batteryColor)),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(value: battery / 100, backgroundColor: const Color(0xFFE0E0E0), color: _batteryColor, minHeight: 6),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // الاتصال يمين
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFFF4EFEB), borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: const [
                          Icon(Icons.signal_cellular_alt, size: 14, color: Color(0xFF757575)),
                          SizedBox(width: 4),
                          Text('الاتصال', style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
                        ]),
                        const SizedBox(height: 6),
                        const Text('جيد', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF3D5A6C))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // الموقع + آخر مهمة يسار
          Row(children: [
            const Icon(Icons.location_on, size: 14, color: Color(0xFFEF5350)),
            const SizedBox(width: 4),
            Text(location.split(' - ').first, style: const TextStyle(fontSize: 13, color: Color(0xFF757575))),
          ]),
          const SizedBox(height: 4),
          Row(children: [
            const Icon(Icons.access_time, size: 13, color: Color(0xFF9E9E9E)),
            const SizedBox(width: 4),
            Text('آخر مهمة: ${location.contains('#') ? location.split('- ').last : '#1234'}', style: const TextStyle(fontSize: 13, color: Color(0xFF757575))),
          ]),
          const SizedBox(height: 2),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('نشط الآن', style: TextStyle(fontSize: 13, color: Color(0xFF00D995), fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          // زر عرض المهمة الحالية
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3D5A6C),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('عرض المهمة الحالية', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

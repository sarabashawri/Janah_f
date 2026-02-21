import 'package:flutter/material.dart';
import 'missions_list_screen.dart';

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
    Center(child: Text('الملف الشخصي')),
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
            BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), activeIcon: Icon(Icons.assignment), label: 'المهمات'),
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
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: const [
                            Text('مرحباً بك', style: TextStyle(fontSize: 12, color: Colors.white70)),
                            SizedBox(height: 2),
                            Text('خالد الشهري', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                            SizedBox(height: 4),
                            Text('فريق الإنقاذ - جناح', style: TextStyle(fontSize: 12, color: Colors.white60)),
                          ],
                        ),
                        const SizedBox(width: 12),
                        const CircleAvatar(radius: 28, backgroundColor: Colors.white24, child: Icon(Icons.person, color: Colors.white, size: 32)),
                      ],
                    ),
                    Stack(
                      children: [
                        IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 28)),
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

            // ── تنبيه مهمة عاجلة ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF5350),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(color: const Color(0xFFEF5350).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                        child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('🚨 مهمة عاجلة نشطة', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
                            SizedBox(height: 2),
                            Text('بلاغ #1234 - يحتاج تدخل فوري', style: TextStyle(fontSize: 12, color: Colors.white70)),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                    ],
                  ),
                ),
              ),
            ),

            // ── إحصائيات اليوم ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
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

            // ── البلاغات النشطة ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('البلاغات النشطة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    TextButton(
                      onPressed: () => Navigator.of(context).pushNamed('/rescuer/missions'),
                      child: const Text('عرض الكل', style: TextStyle(fontSize: 13, color: Color(0xFF3D5A6C))),
                    ),
                  ],
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _ActiveMissionCard(
                    reportId: '#1234', childName: 'محمد أحمد', droneId: 'DR-01',
                    battery: 85, location: 'حي النزهة، شارع الملك فهد',
                    status: 'جاري البحث', isUrgent: true,
                    onTap: () => Navigator.of(context).pushNamed('/rescuer/mission-details'),
                  ),
                  const SizedBox(height: 10),
                  _ActiveMissionCard(
                    reportId: '#1235', childName: 'عبدالله محمد', droneId: 'DR-02',
                    battery: 62, location: 'حي الربوة، شارع العليا',
                    status: 'نشطة', isUrgent: false,
                    onTap: () => Navigator.of(context).pushNamed('/rescuer/mission-details'),
                  ),
                ]),
              ),
            ),

            // ── الخريطة العامة ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('الخريطة العامة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        Text('2 مواقع نشطة', style: TextStyle(fontSize: 13, color: Color(0xFF3D5A6C))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 160,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD0E8F0),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFB0D4E0)),
                      ),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: CustomPaint(size: const Size(double.infinity, 160), painter: _MapPlaceholderPainter()),
                          ),
                          const Positioned(top: 50, left: 80, child: _MapDot(color: Color(0xFFEF5350))),
                          const Positioned(top: 80, right: 100, child: _MapDot(color: Color(0xFF00D995))),
                          Positioned(
                            top: 10, right: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(20)),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.refresh, size: 12, color: Color(0xFF3D5A6C)),
                                  SizedBox(width: 4),
                                  Text('آخر تحديث: منذ 2 دقيقة', style: TextStyle(fontSize: 10, color: Color(0xFF3D5A6C), fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 12, left: 0, right: 0,
                            child: Center(
                              child: ElevatedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.map, size: 16, color: Colors.white),
                                label: const Text('عرض الخريطة الكاملة', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF3D5A6C),
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  elevation: 4,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
                    _DroneCard(droneId: 'DR-01', isOnline: true, battery: 85, timeAgo: 'منذ 2 دقيقة', location: 'حي النزهة - بلاغ #1234', onTap: () => Navigator.of(context).pushNamed('/rescuer/mission-details')),
                    const SizedBox(height: 10),
                    _DroneCard(droneId: 'DR-02', isOnline: true, battery: 62, timeAgo: 'منذ 5 دقائق', location: 'حي الربوة - بلاغ #1235', onTap: () => Navigator.of(context).pushNamed('/rescuer/mission-details')),
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
          border: Border.all(color: isUrgent ? const Color(0xFFEF5350).withOpacity(0.4) : const Color(0xFFFFEB3B).withOpacity(0.5), width: 1.5),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isUrgent ? const Color(0xFFEF5350) : const Color(0xFFFFEB3B),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isUrgent ? '🚨 عاجل' : status,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: isUrgent ? Colors.white : Colors.black87),
                  ),
                ),
                const Spacer(),
                Text('بلاغ رقم $reportId', style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const CircleAvatar(radius: 22, backgroundColor: Color(0xFFE0E0E0), child: Icon(Icons.person, color: Color(0xFF757575), size: 22)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(childName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 13, color: Color(0xFFEF5350)),
                          const SizedBox(width: 3),
                          Expanded(child: Text(location, style: const TextStyle(fontSize: 12, color: Color(0xFF757575)), overflow: TextOverflow.ellipsis)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFFF4EFEB), borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  const Icon(Icons.flight, color: Color(0xFF3D5A6C), size: 16),
                  const SizedBox(width: 6),
                  Text(droneId, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF3D5A6C))),
                  const SizedBox(width: 8),
                  Container(width: 1, height: 14, color: const Color(0xFFD0D0D0)),
                  const SizedBox(width: 8),
                  Icon(Icons.battery_charging_full, color: _batteryColor, size: 16),
                  const SizedBox(width: 4),
                  Text('$battery%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _batteryColor)),
                  const Spacer(),
                  SizedBox(
                    width: 60,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(value: battery / 100, backgroundColor: const Color(0xFFE0E0E0), color: _batteryColor, minHeight: 6),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('عرض التفاصيل', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF3D5A6C))),
                SizedBox(width: 4),
                Icon(Icons.arrow_back, size: 15, color: Color(0xFF3D5A6C)),
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
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFF3D5A6C).withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.flight, color: Color(0xFF3D5A6C), size: 28),
              ),
              Positioned(
                bottom: 2, right: 2,
                child: Container(
                  width: 12, height: 12,
                  decoration: BoxDecoration(
                    color: isOnline ? const Color(0xFF00D995) : const Color(0xFFEF5350),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(droneId, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isOnline ? const Color(0xFF00D995).withOpacity(0.12) : const Color(0xFFEF5350).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(isOnline ? 'متصل' : 'غير متصل', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isOnline ? const Color(0xFF00D995) : const Color(0xFFEF5350))),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 12, color: Color(0xFF757575)),
                    const SizedBox(width: 3),
                    Expanded(child: Text(location, style: const TextStyle(fontSize: 12, color: Color(0xFF757575)), overflow: TextOverflow.ellipsis)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.battery_charging_full, color: _batteryColor, size: 14),
                    const SizedBox(width: 4),
                    Text('$battery%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _batteryColor)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(value: battery / 100, backgroundColor: const Color(0xFFE0E0E0), color: _batteryColor, minHeight: 5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 11, color: Color(0xFF9E9E9E)),
                    const SizedBox(width: 3),
                    Text('آخر تحديث: $timeAgo', style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3D5A6C),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('عرض\nالمهمة', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white), textAlign: TextAlign.center),
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

class _MapPlaceholderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = const Color(0xFFB8DDE8));
    final gridPaint = Paint()..color = const Color(0xFF9ECFDB)..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 40) canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    for (double y = 0; y < size.height; y += 40) canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    final roadPaint = Paint()..color = Colors.white.withOpacity(0.6)..strokeWidth = 6..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(0, size.height * 0.4), Offset(size.width, size.height * 0.4), roadPaint);
    canvas.drawLine(Offset(size.width * 0.35, 0), Offset(size.width * 0.35, size.height), roadPaint);
    canvas.drawLine(Offset(size.width * 0.7, 0), Offset(size.width * 0.7, size.height), roadPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

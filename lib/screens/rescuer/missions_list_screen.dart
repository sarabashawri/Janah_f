import 'package:flutter/material.dart';

// موديل البلاغ
class _Mission {
  final String id;
  final String childName;
  final String location;
  final String time;
  final String description;
  final String status; // 'نشط' | 'مغلق'
  final String? droneId;
  final int? droneProgress;

  const _Mission({
    required this.id,
    required this.childName,
    required this.location,
    required this.time,
    required this.description,
    required this.status,
    this.droneId,
    this.droneProgress,
  });
}

// بيانات وهمية
const List<_Mission> _allMissions = [
  _Mission(
    id: '#1235',
    childName: 'سارة أحمد',
    location: 'حي النزهة، شارع الملك فهد',
    time: 'منذ 15 دقيقة',
    description: 'طفلة ترتدي فستان وردي',
    status: 'مغلق',
  ),
  _Mission(
    id: '#1234',
    childName: 'محمد أحمد',
    location: 'حي الملز، قرب الحديقة',
    time: 'منذ 45 دقيقة',
    description: 'يرتدي قميص أزرق',
    status: 'نشط',
    droneId: 'DR-01',
    droneProgress: 65,
  ),
  _Mission(
    id: '#1233',
    childName: 'عمر خالد',
    location: 'حي الروضة، شارع العليا',
    time: 'منذ ساعتين',
    description: 'يرتدي قميص أحمر',
    status: 'مغلق',
  ),
];

class MissionsListScreen extends StatefulWidget {
  const MissionsListScreen({super.key});

  @override
  State<MissionsListScreen> createState() => _MissionsListScreenState();
}

class _MissionsListScreenState extends State<MissionsListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // ألوان الواجهة (قريبة من الفيقما)
  static const Color _navy = Color(0xFF3D5A6C);
  static const Color _bg = Color(0xFFF4EFEB);
  static const Color _activeYellow = Color(0xFFFFEB3B);
  static const Color _danger = Color(0xFFEF5350);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  int get _activeCount => _allMissions.where((m) => m.status == 'نشط').length;
  int get _closedCount => _allMissions.where((m) => m.status == 'مغلق').length;

  List<_Mission> _filtered(String type) {
    List<_Mission> list;
    if (type == 'نشط') {
      list = _allMissions.where((m) => m.status == 'نشط').toList();
    } else if (type == 'مغلق') {
      list = _allMissions.where((m) => m.status == 'مغلق').toList();
    } else {
      list = _allMissions;
    }

    if (_searchQuery.isNotEmpty) {
      list = list
          .where((m) =>
              m.childName.contains(_searchQuery) ||
              m.id.contains(_searchQuery) ||
              m.location.contains(_searchQuery))
          .toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _bg,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),

              // المحتوى
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildList('نشط'),
                    _buildList('مغلق'),
                    _buildList('الكل'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
      color: _navy,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان + فلتر
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'قائمة البلاغات',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.filter_list, color: Colors.white),
                splashRadius: 22,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // البحث (مثل الفيقما)
          Container(
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
            ),
            child: TextField(
              controller: _searchController,
              textDirection: TextDirection.rtl,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: const InputDecoration(
                hintText: 'بحث عن بلاغ...',
                hintStyle: TextStyle(color: Colors.white60, fontSize: 14),
                prefixIcon: Icon(Icons.search, color: Colors.white60, size: 20),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // بدل الأرقام: سويتش/تبويبات داخل الهيدر الكحلي
          _buildNavyTabs(),
        ],
      ),
    );
  }

  Widget _buildNavyTabs() {
    // حاوية كحلية (بدون شريط أبيض منفصل تحت)
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
        unselectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        tabs: [
          _tabChip(title: 'نشط', count: _activeCount, highlight: true),
          _tabChip(title: 'جديد', count: _closedCount, highlight: false),
          _tabChip(title: 'الكل', count: _allMissions.length, highlight: false),
        ],
      ),
    );
  }

  Widget _tabChip({
    required String title,
    required int count,
    required bool highlight,
  }) {
    // الرقم صار صغير كـ badge داخل السويتش (بدون أرقام كبيرة فوق)
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: highlight ? _activeYellow : Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: highlight ? Colors.black87 : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(String type) {
    final missions = _filtered(type);

    if (missions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 60, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text('لا توجد بلاغات',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: missions.length,
      itemBuilder: (context, index) => _MissionCard(
        mission: missions[index],
        onTap: () => Navigator.of(context).pushNamed('/rescuer/mission-details'),
      ),
    );
  }
}

class _MissionCard extends StatelessWidget {
  const _MissionCard({required this.mission, required this.onTap});

  final _Mission mission;
  final VoidCallback onTap;

  static const Color _navy = Color(0xFF3D5A6C);
  static const Color _bg = Color(0xFFF4EFEB);
  static const Color _activeYellow = Color(0xFFFFEB3B);
  static const Color _danger = Color(0xFFEF5350);

  @override
  Widget build(BuildContext context) {
    final isActive = mission.status == 'نشط';
    final statusColor =
        isActive ? _activeYellow : _danger.withOpacity(0.15);
    final statusTextColor = isActive ? Colors.black87 : _danger;
    final statusLabel = isActive ? 'نشط' : 'مغلقة';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive
                ? _activeYellow.withOpacity(0.55)
                : _danger.withOpacity(0.18),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // الاسم + الحالة
            Row(
              children: [
                const CircleAvatar(
                  radius: 22,
                  backgroundColor: Color(0xFFE0E0E0),
                  child: Icon(Icons.person,
                      color: Color(0xFF757575), size: 22),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(mission.childName,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w800)),
                      Text(mission.id,
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF9E9E9E))),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: statusTextColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // الموقع
            Row(
              children: [
                const Icon(Icons.location_on, size: 14, color: _danger),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    mission.location,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF757575)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // الوقت
            Row(
              children: [
                const Icon(Icons.access_time,
                    size: 14, color: Color(0xFF9E9E9E)),
                const SizedBox(width: 4),
                Text(
                  mission.time,
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF9E9E9E)),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // الوصف
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _bg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                mission.description,
                style: const TextStyle(fontSize: 12, color: Color(0xFF555555)),
              ),
            ),

            // معلومات الدرون (للبلاغات النشطة فقط)
            if (mission.droneId != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _navy.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.flight, size: 14, color: _navy),
                        const SizedBox(width: 4),
                        Text(
                          'الدرون: ${mission.droneId}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: _navy,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('جار البحث - ',
                            style:
                                TextStyle(fontSize: 11, color: Color(0xFF757575))),
                        Text('${mission.droneProgress}% من المنطقة',
                            style:
                                const TextStyle(fontSize: 11, color: Color(0xFF757575))),
                        const Spacer(),
                        SizedBox(
                          width: 90,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: (mission.droneProgress ?? 0) / 100,
                              backgroundColor: const Color(0xFFE0E0E0),
                              color: const Color(0xFF00D995),
                              minHeight: 6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 8),

            // ✅ عرض التفاصيل باليسار لحاله
            Row(
              children: [
                TextButton.icon(
                  onPressed: onTap,
                  style: TextButton.styleFrom(
                    foregroundColor: _navy,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                  ),
                  icon: const Icon(Icons.arrow_back, size: 16, color: _navy),
                  label: const Text(
                    'عرض التفاصيل',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

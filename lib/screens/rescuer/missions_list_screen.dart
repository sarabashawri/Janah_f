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
              _buildHeader(),
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

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
      color: _navy,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'قائمة البلاغات',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              Icon(Icons.filter_list, color: Colors.white),
            ],
          ),
          const SizedBox(height: 12),

          // ✅ البحث (يظهر الخط + الكتابة كحلي/أسود)
          Container(
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(
                color: _navy,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              cursorColor: _navy,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: const InputDecoration(
                hintText: 'بحث عن بلاغ...',
                hintStyle: TextStyle(color: Colors.grey),
                prefixIcon: Icon(Icons.search, color: _navy),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // ✅ السويتش (نفس القديم كـ Tabs لكن داخل الهيدر)
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.10),
              borderRadius: BorderRadius.circular(14),
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
              tabs: const [
                Tab(text: 'نشط'),
                Tab(text: 'جديد'),
                Tab(text: 'الكل'),
              ],
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
        child: Text(
          'لا توجد بلاغات',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: missions.length,
      itemBuilder: (context, index) => _MissionCard(
        mission: missions[index],
        onTap: () {
          // Navigator.of(context).pushNamed('/guardian/report-details');
        },
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

  @override
  Widget build(BuildContext context) {
    final isActive = mission.status == 'نشط';
    final statusColor =
        isActive ? const Color(0xFFFFEB3B) : const Color(0xFFEF5350).withOpacity(0.15);
    final statusTextColor =
        isActive ? Colors.black87 : const Color(0xFFEF5350);
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
                ? const Color(0xFFFFEB3B).withOpacity(0.6)
                : const Color(0xFFEF5350).withOpacity(0.2),
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
            // الاسم والحالة
            Row(
              children: [
                const CircleAvatar(
                  radius: 22,
                  backgroundColor: Color(0xFFE0E0E0),
                  child: Icon(Icons.person, color: Color(0xFF757575), size: 22),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(mission.childName,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700)),
                      Text(mission.id,
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF9E9E9E))),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
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
                const Icon(Icons.location_on, size: 14, color: Color(0xFFEF5350)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(mission.location,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF757575))),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // الوقت
            Row(
              children: [
                const Icon(Icons.access_time, size: 14, color: Color(0xFF9E9E9E)),
                const SizedBox(width: 4),
                Text(mission.time,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
              ],
            ),

            const SizedBox(height: 10),

            // الوصف
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _bg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                mission.description,
                style: const TextStyle(fontSize: 12, color: Color(0xFF555555)),
              ),
            ),

            // معلومات الدرون (بدون شريط أخضر)
            if (mission.droneId != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _navy.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.flight, size: 14, color: _navy),
                    const SizedBox(width: 6),
                    Text(
                      'الدرون: ${mission.droneId}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _navy,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'جار البحث - ${mission.droneProgress ?? 0}% من المنطقة',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF757575)),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // ✅ عرض التفاصيل (مثل ما كان) + السهم معكوس
            Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'عرض التفاصيل',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _navy,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: _navy,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'mission_details_screen.dart';

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
  static const Color _bg   = Color(0xFFF4EFEB);

  // بيانات البلاغات مأخوذة من missionsMap
  List<MissionData> get _allMissions => missionsMap.values.toList();

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

  List<MissionData> _filtered(String type) {
    List<MissionData> list;
    if (type == 'نشط') {
      list = _allMissions.where((m) => m.scannedArea < 100).toList();
    } else if (type == 'مغلق') {
      list = _allMissions.where((m) => m.scannedArea >= 100).toList();
    } else {
      list = _allMissions;
    }
    if (_searchQuery.isNotEmpty) {
      list = list.where((m) =>
        m.childName.contains(_searchQuery) ||
        m.reportId.contains(_searchQuery) ||
        m.lastLocation.contains(_searchQuery)
      ).toList();
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
              Text('قائمة البلاغات',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
              Icon(Icons.filter_list, color: Colors.white),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 46,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: _navy, fontSize: 14, fontWeight: FontWeight.w600),
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
                Tab(text: 'مغلق'),
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
      return Center(child: Text('لا توجد بلاغات', style: TextStyle(color: Colors.grey.shade600)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: missions.length,
      itemBuilder: (context, index) {
        final m = missions[index];
        return _MissionCard(
          mission: m,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => MissionDetailsScreen(reportId: m.reportId)),
          ),
        );
      },
    );
  }
}

class _MissionCard extends StatelessWidget {
  const _MissionCard({required this.mission, required this.onTap});
  final MissionData mission;
  final VoidCallback onTap;

  static const Color _navy = Color(0xFF3D5A6C);
  static const Color _bg   = Color(0xFFF4EFEB);

  @override
  Widget build(BuildContext context) {
    final isActive = mission.scannedArea < 100;
    final statusColor = isActive
        ? const Color(0xFFFFEB3B)
        : const Color(0xFFEF5350).withOpacity(0.15);
    final statusTextColor = isActive ? Colors.black87 : const Color(0xFFEF5350);
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
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
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
                      Text(mission.childName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      Text(mission.reportId, style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(20)),
                  child: Text(statusLabel, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: statusTextColor)),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // الموقع
            Row(
              children: [
                const Icon(Icons.location_on, size: 14, color: Color(0xFFEF5350)),
                const SizedBox(width: 4),
                Expanded(child: Text(mission.lastLocation, style: const TextStyle(fontSize: 12, color: Color(0xFF757575)))),
              ],
            ),
            const SizedBox(height: 4),

            // الوقت
            Row(
              children: [
                const Icon(Icons.access_time, size: 14, color: Color(0xFF9E9E9E)),
                const SizedBox(width: 4),
                Text(mission.disappearTime, style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
              ],
            ),
            const SizedBox(height: 10),

            // الوصف
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(8)),
              child: Text(mission.childDescription, style: const TextStyle(fontSize: 12, color: Color(0xFF555555))),
            ),

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // عرض التفاصيل
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
                      Text('عرض التفاصيل', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _navy)),
                      SizedBox(width: 6),
                      Icon(Icons.arrow_forward_ios, size: 14, color: _navy),
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

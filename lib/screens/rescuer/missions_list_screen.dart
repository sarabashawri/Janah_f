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

          Container(
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: const InputDecoration(
                hintText: 'بحث عن بلاغ...',
                hintStyle: TextStyle(color: Colors.white60),
                prefixIcon:
                    Icon(Icons.search, color: Colors.white60, size: 20),
                border: InputBorder.none,
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

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: missions.length,
      itemBuilder: (context, index) {
        final mission = missions[index];
        final isActive = mission.status == 'نشط';

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive
                  ? _activeYellow.withOpacity(0.6)
                  : _danger.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // الاسم والحالة
              Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Color(0xFFE0E0E0),
                    child: Icon(Icons.person, color: Colors.grey),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(mission.childName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold)),
                        Text(mission.id,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isActive
                          ? _activeYellow
                          : _danger.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isActive ? 'نشط' : 'مغلقة',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color:
                            isActive ? Colors.black : _danger,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Text(mission.location,
                  style:
                      const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 4),
              Text(mission.time,
                  style:
                      const TextStyle(fontSize: 12, color: Colors.grey)),

              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _bg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(mission.description),
              ),

              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),

              // عرض التفاصيل ←
              Align(
                alignment: Alignment.centerLeft,
                child: InkWell(
                  onTap: () {},
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'عرض التفاصيل',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF3D5A6C),
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(
                        Icons.arrow_back_ios_new,
                        size: 14,
                        color: Color(0xFF3D5A6C),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

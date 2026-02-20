import 'package:flutter/material.dart';

class MissionsListScreen extends StatefulWidget {
  const MissionsListScreen({super.key});

  @override
  State<MissionsListScreen> createState() => _MissionsListScreenState();
}

class _MissionsListScreenState extends State<MissionsListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Color(0xFF3D5A6C),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'قائمة البلاغات',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.filter_list, color: Colors.white),
                    ),
                  ],
                ),
              ),

              // Tabs
              Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  labelColor: const Color(0xFF3D5A6C),
                  unselectedLabelColor: const Color(0xFF9E9E9E),
                  indicatorColor: const Color(0xFF3D5A6C),
                  tabs: const [
                    Tab(text: 'نشطة'),
                    Tab(text: 'مكتملة'),
                    Tab(text: 'الكل'),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildMissionsList('نشطة'),
                    _buildMissionsList('مكتملة'),
                    _buildMissionsList('الكل'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMissionsList(String type) {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: type == 'نشطة' ? 1 : 2,
      itemBuilder: (context, index) {
        return _buildMissionCard(
          status: type == 'نشطة' ? 'نشطة' : 'مكتملة',
          statusColor: type == 'نشطة' ? const Color(0xFFFFEB3B) : const Color(0xFF00D995),
        );
      },
    );
  }

  Widget _buildMissionCard({
    required String status,
    required Color statusColor,
  }) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed('/rescuer/mission-details');
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: status == 'نشطة' ? Colors.black87 : Colors.white,
                    ),
                  ),
                ),
                const Spacer(),
                const Text(
                  'منذ ساعتين',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9E9E9E),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const CircleAvatar(
                  radius: 24,
                  backgroundColor: Color(0xFFE0E0E0),
                  child: Icon(Icons.person, color: Color(0xFF757575)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'عبدالله محمد',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 14,
                            color: Color(0xFFEF5350),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'بلاغ رقم #12345',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF757575),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.pin_drop,
                  size: 16,
                  color: Color(0xFF757575),
                ),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    'حي الربوة، شارع العليا',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF757575),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'عرض التفاصيل',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3D5A6C),
                  ),
                ),
                SizedBox(width: 4),
                Icon(
                  Icons.arrow_back,
                  size: 16,
                  color: Color(0xFF3D5A6C),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

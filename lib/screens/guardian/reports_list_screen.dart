import 'package:flutter/material.dart';

class ReportsListScreen extends StatefulWidget {
  const ReportsListScreen({super.key});

  @override
  State<ReportsListScreen> createState() => _ReportsListScreenState();
}

class _ReportsListScreenState extends State<ReportsListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
        backgroundColor: const Color(0xFFF4EFEB), // ✅ اللون الموحد
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF3D5A6C), Color(0xFF4A7B91)],
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'البلاغات',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.filter_list,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatChip('نشطة', '1', const Color(0xFFFFEB3B)),
                        _buildStatChip('منتهية', '2', const Color(0xFF00D995)),
                        _buildStatChip('الإجمالي', '3', Colors.white),
                      ],
                    ),
                  ],
                ),
              ),

              // Tabs
              Container(
                color: const Color(0xFFF4EFEB), // ✅ بدل الأبيض
                child: TabBar(
                  controller: _tabController,
                  labelColor: const Color(0xFF3D5A6C),
                  unselectedLabelColor: const Color(0xFF9E9E9E),
                  indicatorColor: const Color(0xFF3D5A6C),
                  tabs: const [
                    Tab(text: 'البلاغات النشطة'),
                    Tab(text: 'البلاغات المنتهية'),
                  ],
                ),
              ),

              // Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildActiveReports(),
                    _buildClosedReports(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(String label, String count, Color color) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveReports() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildReportCard(
          reportId: '#1234',
          childName: 'محمد أحمد',
          location: 'حي النزهة، شارع الملك فهد',
          time: 'منذ 3 ساعات',
          status: 'جاري البحث',
          statusColor: const Color(0xFF00D995),
        ),
      ],
    );
  }

  Widget _buildClosedReports() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildReportCard(
          reportId: '#1235',
          childName: 'سارة أحمد',
          location: 'حي الروضة',
          time: 'منذ 15 دقيقة',
          status: 'تم العثور',
          statusColor: const Color(0xFF00D995),
        ),
        const SizedBox(height: 12),
        _buildReportCard(
          reportId: '#1232',
          childName: 'فاطمة ماجد',
          location: 'حي العليا',
          time: 'منذ أسبوع',
          status: 'مغلق',
          statusColor: const Color(0xFFFF5252),
        ),
      ],
    );
  }

  Widget _buildReportCard({
    required String reportId,
    required String childName,
    required String location,
    required String time,
    required String status,
    required Color statusColor,
  }) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed('/guardian/report-details');
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: statusColor.withOpacity(0.3), width: 2),
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  time,
                  style: const TextStyle(
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
                      Text(
                        childName,
                        style: const TextStyle(
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
                          Text(
                            reportId,
                            style: const TextStyle(
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
                Expanded(
                  child: Text(
                    location,
                    style: const TextStyle(
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

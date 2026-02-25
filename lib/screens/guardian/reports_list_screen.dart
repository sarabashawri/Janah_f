import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportsListScreen extends StatefulWidget {
  const ReportsListScreen({super.key});

  @override
  State<ReportsListScreen> createState() => _ReportsListScreenState();
}

class _ReportsListScreenState extends State<ReportsListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final String _userId = FirebaseAuth.instance.currentUser?.uid ?? '';

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

  String _timeAgo(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final diff = DateTime.now().difference(timestamp.toDate());
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    return 'منذ ${diff.inDays} يوم';
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
              // Header مع الأرقام من Firebase
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('reports')
                    .where('guardianId', isEqualTo: _userId)
                    .snapshots(),
                builder: (context, snapshot) {
                  final docs = snapshot.data?.docs ?? [];
                  final total = docs.length;
                  final active = docs.where((d) => (d.data() as Map)['status'] == 'active').length;
                  final closed = docs.where((d) => (d.data() as Map)['status'] != 'active').length;

                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      color: Color(0xFF3D5A6C),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'البلاغات',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatChip('الإجمالي', '$total'),
                            _buildStatChip('منتهية', '$closed'),
                            _buildStatChip('البلاغات النشطة', '$active'),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Tabs
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
                    ],
                  ),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: Colors.white,
                    unselectedLabelColor: const Color(0xFF9E9E9E),
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                      color: const Color(0xFF3D5A6C),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    dividerColor: Colors.transparent,
                    tabs: const [
                      Tab(text: 'البلاغات النشطة'),
                      Tab(text: 'البلاغات المنتهية'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildReportsList('active'),
                    _buildReportsList('closed'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(String label, String count) {
    return Column(
      children: [
        Text(count, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.white70), textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildReportsList(String statusFilter) {
    Query query = FirebaseFirestore.instance
        .collection('reports')
        .where('guardianId', isEqualTo: _userId)
        .orderBy('createdAt', descending: true);

    if (statusFilter == 'active') {
      query = query.where('status', isEqualTo: 'active');
    } else {
      query = query.where('status', whereIn: ['closed', 'found', 'inProgress']);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.description_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  statusFilter == 'active' ? 'لا توجد بلاغات نشطة' : 'لا توجد بلاغات منتهية',
                  style: const TextStyle(fontSize: 16, color: Color(0xFF9E9E9E)),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final data = doc.data() as Map<String, dynamic>;
            final status = data['status'] ?? 'active';
            final statusColor = status == 'active'
                ? const Color(0xFF00D995)
                : status == 'found'
                    ? const Color(0xFF2196F3)
                    : const Color(0xFFFF5252);
            final statusText = status == 'active'
                ? 'جاري البحث'
                : status == 'found'
                    ? 'تم العثور'
                    : 'مغلق';

            return _buildReportCard(
              reportId: doc.id,
              childName: data['childName'] ?? '',
              location: data['location'] ?? '',
              time: _timeAgo(data['createdAt'] as Timestamp?),
              status: statusText,
              statusColor: statusColor,
            );
          },
        );
      },
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor, width: 2),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 22,
                backgroundColor: Color(0xFFB0BEC5),
                child: Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(childName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.pin_drop, size: 14, color: Color(0xFF757575)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(location, style: const TextStyle(fontSize: 12, color: Color(0xFF757575)), overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(20)),
                child: Text(status, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          InkWell(
            onTap: () {
              Navigator.of(context).pushNamed('/guardian/report-details', arguments: reportId);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(time, style: const TextStyle(fontSize: 12, color: Color(0xFF757575))),
                const Row(
                  children: [
                    Text('عرض التفاصيل', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF3D5A6C))),
                    SizedBox(width: 6),
                    Icon(Icons.arrow_forward, size: 16, color: Color(0xFF3D5A6C)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

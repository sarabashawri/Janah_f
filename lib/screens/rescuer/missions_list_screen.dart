import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/report.dart';
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

  Stream<QuerySnapshot> _stream(String type) {
    final col = FirebaseFirestore.instance.collection('reports');
    if (type == 'active') {
      // include legacy values (active, inProgress) for backward compatibility with old Firestore docs
      return col.where('status', whereIn: ['pending', 'accepted', 'searching', 'active', 'inProgress']).orderBy('createdAt', descending: true).snapshots();
    } else if (type == 'closed') {
      // include legacy values (found, closed) for backward compatibility
      return col.where('status', whereIn: ['matchFound', 'resolved', 'found', 'closed']).orderBy('createdAt', descending: true).snapshots();
    }
    return col.orderBy('createdAt', descending: true).snapshots();
  }

  String _timeAgo(Timestamp? ts) {
    if (ts == null) return '';
    final diff = DateTime.now().difference(ts.toDate());
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    return 'منذ ${diff.inDays} يوم';
  }

  List<QueryDocumentSnapshot> _applySearch(List<QueryDocumentSnapshot> docs) {
    if (_searchQuery.isEmpty) return docs;
    return docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final name = (data['childName'] ?? '').toString().toLowerCase();
      final loc  = (data['location'] ?? '').toString().toLowerCase();
      final q = _searchQuery.toLowerCase();
      return name.contains(q) || loc.contains(q) || doc.id.contains(q);
    }).toList();
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
                    _buildList('active'),
                    _buildList('closed'),
                    _buildList('all'),
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
              Text('قائمة البلاغات', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
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
    return StreamBuilder<QuerySnapshot>(
      stream: _stream(type),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: _navy));
        }
        final docs = _applySearch(snap.data?.docs ?? []);
        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.assignment_outlined, size: 56, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                Text('لا توجد بلاغات', style: TextStyle(color: Colors.grey.shade600, fontSize: 15)),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final status = data['status'] ?? 'pending';
            return _MissionCard(
              reportId: docs[index].id,
              childName: data['childName'] ?? 'غير محدد',
              location: data['location'] ?? '',
              description: data['description'] ?? '',
              timeAgo: _timeAgo(data['createdAt'] as Timestamp?),
              status: status,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => MissionDetailsScreen(reportId: docs[index].id)),
              ),
            );
          },
        );
      },
    );
  }
}

class _MissionCard extends StatelessWidget {
  const _MissionCard({
    required this.reportId,
    required this.childName,
    required this.location,
    required this.description,
    required this.timeAgo,
    required this.status,
    required this.onTap,
  });

  final String reportId, childName, location, description, timeAgo, status;
  final VoidCallback onTap;

  static const Color _navy = Color(0xFF3D5A6C);
  static const Color _bg   = Color(0xFFF4EFEB);

  ReportStatus get _statusEnum => ReportStatus.fromFirestore(status);

  String get _statusLabel {
    switch (_statusEnum) {
      case ReportStatus.pending:    return 'قيد الانتظار';
      case ReportStatus.accepted:   return 'تم القبول';
      case ReportStatus.searching:  return 'جاري البحث';
      case ReportStatus.matchFound: return 'تم العثور';
      case ReportStatus.resolved:   return 'تم الإغلاق';
    }
  }

  Color get _statusColor {
    switch (_statusEnum) {
      case ReportStatus.pending:    return const Color(0xFFFF9800);
      case ReportStatus.accepted:   return const Color(0xFF2196F3);
      case ReportStatus.searching:  return const Color(0xFF2196F3);
      case ReportStatus.matchFound: return const Color(0xFF00D995);
      case ReportStatus.resolved:   return const Color(0xFF9E9E9E);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _statusColor.withOpacity(0.3), width: 1.5),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                      Text(childName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      Text(timeAgo, style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: _statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                  child: Text(_statusLabel, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _statusColor)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(children: [
              const Icon(Icons.location_on, size: 14, color: Color(0xFFEF5350)),
              const SizedBox(width: 4),
              Expanded(child: Text(location, style: const TextStyle(fontSize: 12, color: Color(0xFF757575)))),
            ]),
            if (description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(8)),
                child: Text(description, style: const TextStyle(fontSize: 12, color: Color(0xFF555555)), maxLines: 2, overflow: TextOverflow.ellipsis),
              ),
            ],
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),
            const Align(
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('عرض التفاصيل', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _navy)),
                  SizedBox(width: 6),
                  Icon(Icons.arrow_forward_ios, size: 14, color: _navy),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'reports_list_screen.dart';
import 'profile_screen.dart';

class GuardianHomeScreen extends StatefulWidget {
  const GuardianHomeScreen({super.key});

  @override
  State<GuardianHomeScreen> createState() => _GuardianHomeScreenState();
}

class _GuardianHomeScreenState extends State<GuardianHomeScreen> {
  int _selectedIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is int) {
      _selectedIndex = args;
    }
  }

  void _goToReports() {
    setState(() => _selectedIndex = 1);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeDashboard(onViewAllReports: _goToReports),
      const ReportsListScreen(),
      const ProfileScreen(),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: screens[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF3D5A6C),
          unselectedItemColor: const Color(0xFF9E9E9E),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'الرئيسية',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.description_outlined),
              activeIcon: Icon(Icons.description),
              label: 'البلاغات',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'الملف',
            ),
          ],
        ),
      ),
    );
  }
}

class HomeDashboard extends StatefulWidget {
  final VoidCallback? onViewAllReports;
  const HomeDashboard({super.key, this.onViewAllReports});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  String _userName = 'جاري التحميل...';
  String _userId = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() => _userId = user.uid);
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists && mounted) {
        setState(() {
          _userName = doc.data()?['name'] ?? user.email ?? 'مستخدم';
        });
      }
    }
  }

  String _statusLabel(String? s) {
    switch (s) {
      case 'pending':    return 'قيد الانتظار';
      case 'accepted':   return 'تم القبول';
      case 'searching':  return 'جاري البحث';
      case 'matchFound': return 'تم العثور';
      case 'resolved':   return 'تم الإغلاق';
      // legacy Firestore values
      case 'active':     return 'قيد الانتظار';
      case 'inProgress': return 'جاري البحث';
      case 'found':      return 'تم العثور';
      case 'closed':     return 'تم الإغلاق';
      default:           return 'نشط';
    }
  }

  Color _statusColor(String? s) {
    switch (s) {
      case 'pending':    return const Color(0xFFFF9800);
      case 'accepted':   return const Color(0xFF2196F3);
      case 'searching':  return const Color(0xFF2196F3);
      case 'matchFound': return const Color(0xFF00D995);
      case 'resolved':   return const Color(0xFF9E9E9E);
      case 'active':     return const Color(0xFFFF9800);
      case 'inProgress': return const Color(0xFF2196F3);
      case 'found':      return const Color(0xFF00D995);
      case 'closed':     return const Color(0xFF9E9E9E);
      default:           return const Color(0xFF00D995);
    }
  }

  Widget _buildActiveReportCard(DocumentSnapshot report) {
    final data = report.data() as Map<String, dynamic>;
    final statusStr = data['status'] as String? ?? '';
    final sColor = _statusColor(statusStr);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: sColor, width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 22,
                backgroundColor: Color(0xFFB0BEC5),
                child: Icon(Icons.person, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['childName'] ?? '',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 14, color: Color(0xFFEF5350)),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            data['location'] ?? '',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF757575)),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: sColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _statusLabel(statusStr),
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => Navigator.of(context).pushNamed(
              '/guardian/report-details',
              arguments: report.id,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('عرض التفاصيل',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3D5A6C))),
                Icon(Icons.arrow_forward, size: 16, color: Color(0xFF3D5A6C)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: const Color(0xFFF4EFEB),
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Color(0xFF3D5A6C),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
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
                          children: [
                            const Text(
                              'مرحباً بك',
                              style: TextStyle(fontSize: 12, color: Colors.white70),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _userName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'جناح - نظام البحث والإنقاذ',
                              style: TextStyle(fontSize: 12, color: Colors.white60),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // الإشعارات
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('notifications')
                          .where('guardianId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                          .where('isRead', isEqualTo: false)
                          .snapshots(),
                      builder: (context, snap) {
                        final unread = snap.data?.docs.length ?? 0;
                        return Stack(
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.of(context).pushNamed('/guardian/notifications');
                              },
                              icon: const Icon(
                                Icons.notifications_outlined,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            if (unread > 0)
                              Positioned(
                                right: 8,
                                top: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFEF5350),
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                                  child: Text(
                                    '$unread',
                                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // بلّغ عن طفل مفقود
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'بلّغ عن الطفل المفقود',
                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'قم بتقديم بلاغ جديد للبحث عن طفل مفقود',
                              style: TextStyle(fontSize: 13, color: Color(0xFF757575), height: 1.4),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 90,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed('/guardian/create-report');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3D5A6C),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: EdgeInsets.zero,
                          ),
                          child: const Text(
                            'بلّغ الآن',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // البلاغات النشطة من Firebase
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'البلاغات النشطة',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                          ),
                          TextButton(
                            onPressed: () => widget.onViewAllReports?.call(),
                            child: const Text(
                              'عرض الكل',
                              style: TextStyle(fontSize: 13, color: Color(0xFF3D5A6C)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // بيانات حقيقية من Firestore
                      _userId.isEmpty
                          ? const CircularProgressIndicator()
                          : StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('reports')
                                  .where('guardianId', isEqualTo: _userId)
                                  .where('status', whereIn: [
                                    'pending', 'accepted', 'searching',
                                    'active', 'inProgress',
                                  ])
                                  .limit(3)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                }
                                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                  return const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Text(
                                      'لا توجد بلاغات نشطة',
                                      style: TextStyle(color: Color(0xFF757575)),
                                    ),
                                  );
                                }
                                final docs = snapshot.data!.docs;
                                return Column(
                                  children: [
                                    for (int i = 0; i < docs.length; i++) ...[
                                      if (i > 0) const SizedBox(height: 10),
                                      _buildActiveReportCard(docs[i]),
                                    ],
                                  ],
                                );
                              },
                            ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // زر الطوارئ
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GestureDetector(
                  onTap: () => launchUrl(Uri(scheme: 'tel', path: '911')),
                  child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF5350),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.phone, color: Colors.white, size: 26),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('الاتصال بالطوارئ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                            SizedBox(height: 4),
                            Text('911 - اتصال مباشر', style: TextStyle(fontSize: 13, color: Colors.white70)),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward, color: Colors.white, size: 24),
                    ],
                  ),
                ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4EFEB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE0D8D0)),
                  ),
                  child: const Text(
                    'طفلكم تحت جناحنا\nولن يرتاح الجناح حتى تتحقق لحظة العودة',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.6, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 30)),
          ],
        ),
      ),
    );
  }
}

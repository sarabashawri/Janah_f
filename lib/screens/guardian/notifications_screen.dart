import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int _selectedIndex = 0;

  // ✅ ألوان مشروعك
  static const Color kBg = Color(0xFFF4EFEB);
  static const Color kPrimary = Color(0xFF3D5A6C);
  static const Color kPrimary2 = Color(0xFF4A7B91);
  static const Color kText = Color(0xFF2D2D2D);
  static const Color kSubText = Color(0xFF757575);
  static const Color kMuted = Color(0xFF9E9E9E);
  static const Color kBorder = Color(0xFFE7E0DA);
  static const Color kDot = Color(0xFFEF5350);

  void _onTapNav(int index) {
    if (index == _selectedIndex) return;

    if (index == 0) {
      Navigator.of(context).pushReplacementNamed('/guardian/home');
    } else if (index == 1) {
      // روح للرئيسية مع argument يحدد tab البلاغات
      Navigator.of(context).pushReplacementNamed('/guardian/home', arguments: 1);
    } else if (index == 2) {
      Navigator.of(context).pushReplacementNamed('/guardian/home', arguments: 2);
    }
  }

  final _db = FirebaseFirestore.instance;
  final _uid = FirebaseAuth.instance.currentUser?.uid;

  Stream<QuerySnapshot> get _notificationsStream => _db
      .collection('notifications')
      .where('guardianId', isEqualTo: _uid)
      .orderBy('createdAt', descending: true)
      .snapshots();

  Future<void> _markAllAsRead() async {
    final snap = await _db
        .collection('notifications')
        .where('guardianId', isEqualTo: _uid)
        .where('isRead', isEqualTo: false)
        .get();
    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  Future<void> _markAsRead(String docId) async {
    await _db.collection('notifications').doc(docId).update({'isRead': true});
  }

  IconData _iconFromType(String type) {
    switch (type) {
      case 'missionStarted':  return Icons.flight_takeoff;
      case 'childFound':      return Icons.check_circle;
      case 'locationUpdated': return Icons.location_on;
      default:                return Icons.notifications;
    }
  }

  Color _tintFromType(String type) {
    switch (type) {
      case 'missionStarted':  return const Color(0xFF00D995);
      case 'childFound':      return const Color(0xFF00D995);
      case 'locationUpdated': return const Color(0xFF2196F3);
      default:                return const Color(0xFF9E9E9E);
    }
  }

  String _timeAgo(Timestamp? ts) {
    if (ts == null) return '';
    final diff = DateTime.now().difference(ts.toDate());
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24)   return 'منذ ${diff.inHours} ساعة';
    return 'منذ ${diff.inDays} يوم';
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: kBg,

        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onTapNav,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: kPrimary,
          unselectedItemColor: kMuted,
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

        body: SafeArea(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: 80,
                decoration: const BoxDecoration(
                  color: kPrimary,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Stack(
                  children: [
                    // السهم على اليمين
                    Positioned(
                      right: 4,
                      top: 0,
                      bottom: 0,
                      child: IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 26),
                      ),
                    ),
                    // العنوان في الوسط
                    const Center(
                      child: Text(
                        'التنبيهات',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ),
                    // قراءة الكل على اليسار
                    Positioned(
                      left: 4,
                      top: 0,
                      bottom: 0,
                      child: StreamBuilder<QuerySnapshot>(
                        stream: _notificationsStream,
                        builder: (context, snap) {
                          final unread = snap.data?.docs
                              .where((d) => (d.data() as Map)['isRead'] == false)
                              .length ?? 0;
                          return TextButton(
                            onPressed: unread == 0 ? null : _markAllAsRead,
                            child: Text(
                              'قراءة الكل',
                              style: TextStyle(
                                fontSize: 14,
                                color: unread == 0 ? Colors.white38 : Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _notificationsStream,
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final docs = snap.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return const Center(
                        child: Text('لا توجد إشعارات حتى الآن',
                            style: TextStyle(color: Color(0xFF9E9E9E))),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: docs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final data = docs[i].data() as Map<String, dynamic>;
                        final type = data['type'] as String? ?? 'general';
                        final isRead = data['isRead'] as bool? ?? false;
                        return _NotificationCardWhite(
                          title: data['title'] ?? '',
                          description: data['description'] ?? '',
                          time: _timeAgo(data['createdAt'] as Timestamp?),
                          icon: _iconFromType(type),
                          tint: _tintFromType(type),
                          isRead: isRead,
                          onTap: () => _markAsRead(docs[i].id),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _NotificationCardWhite extends StatelessWidget {
  const _NotificationCardWhite({
    required this.title,
    required this.description,
    required this.time,
    required this.icon,
    required this.tint,
    required this.isRead,
    required this.onTap,
  });

  final String title;
  final String description;
  final String time;
  final IconData icon;
  final Color tint;
  final bool isRead;
  final VoidCallback onTap;

  static const Color kText = Color(0xFF2D2D2D);
  static const Color kSubText = Color(0xFF757575);
  static const Color kMuted = Color(0xFF9E9E9E);
  static const Color kBorder = Color(0xFFE7E0DA);
  static const Color kDot = Color(0xFFEF5350);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white, // ✅ دائمًا أبيض
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isRead ? kBorder : tint.withOpacity(0.35), // ✅ فرق بسيط
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // أيقونة يمين (خلفية خفيفة جدًا فقط للأيقونة)
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: tint.withOpacity(0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: tint, size: 24),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (!isRead)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(left: 8, top: 2),
                          decoration: const BoxDecoration(
                            color: kDot,
                            shape: BoxShape.circle,
                          ),
                        ),
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight:
                                isRead ? FontWeight.w600 : FontWeight.w800,
                            color: kText,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: isRead ? kMuted : kSubText,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: kMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

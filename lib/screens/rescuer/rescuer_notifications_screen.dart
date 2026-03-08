import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RescuerNotificationsScreen extends StatefulWidget {
  const RescuerNotificationsScreen({super.key});

  @override
  State<RescuerNotificationsScreen> createState() => _RescuerNotificationsScreenState();
}

class _RescuerNotificationsScreenState extends State<RescuerNotificationsScreen> {
  final _db = FirebaseFirestore.instance;
  final _uid = FirebaseAuth.instance.currentUser?.uid;

  Stream<QuerySnapshot> get _stream => _db
      .collection('notifications')
      .orderBy('createdAt', descending: true)
      .snapshots();

  Future<void> _markAllRead() async {
    final snap = await _db.collection('notifications').where('isRead', isEqualTo: false).get();
    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  Future<void> _markRead(String docId) async {
    await _db.collection('notifications').doc(docId).update({'isRead': true});
  }

  IconData _icon(String type) {
    switch (type) {
      case 'newReport': return Icons.error_outline;
      case 'found':     return Icons.check_circle_outline;
      case 'location':  return Icons.location_on_outlined;
      default:          return Icons.notifications_outlined;
    }
  }

  Color _iconColor(String type) {
    switch (type) {
      case 'newReport': return const Color(0xFFEF5350);
      case 'found':     return const Color(0xFF00D995);
      case 'location':  return const Color(0xFF2196F3);
      default:          return const Color(0xFF9E9E9E);
    }
  }

  Color _iconBg(String type) {
    switch (type) {
      case 'newReport': return const Color(0xFFFFEBEE);
      case 'found':     return const Color(0xFFE8F5E9);
      case 'location':  return const Color(0xFFE3F2FD);
      default:          return const Color(0xFFF5F5F5);
    }
  }

  String _timeAgo(Timestamp? ts) {
    if (ts == null) return '';
    final diff = DateTime.now().difference(ts.toDate());
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
        body: Column(
          children: [
            // HEADER
            Container(
              width: double.infinity,
              color: const Color(0xFF3D5A6C),
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8,
                bottom: 12,
                right: 8,
                left: 16,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const Expanded(
                        child: Text('التنبيهات', textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                      ),
                      GestureDetector(
                        onTap: _markAllRead,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                          child: const Text('قراءة الكل', style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  StreamBuilder<QuerySnapshot>(
                    stream: _db.collection('notifications').where('isRead', isEqualTo: false).snapshots(),
                    builder: (context, snap) {
                      final unread = snap.data?.docs.length ?? 0;
                      if (unread == 0) return const SizedBox.shrink();
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(width: 7, height: 7, decoration: const BoxDecoration(color: Color(0xFFEF5350), shape: BoxShape.circle)),
                          const SizedBox(width: 4),
                          Text('$unread تنبيهات جديدة', style: const TextStyle(fontSize: 12, color: Colors.white70)),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),

            // القائمة
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _stream,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFF3D5A6C)));
                  }
                  final docs = snap.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          const Text('لا توجد تنبيهات', style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 16)),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: docs.length,
                    itemBuilder: (context, i) {
                      final data = docs[i].data() as Map<String, dynamic>;
                      final type = data['type'] as String? ?? 'general';
                      final isRead = data['isRead'] as bool? ?? false;
                      return GestureDetector(
                        onTap: () => _markRead(docs[i].id),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: isRead ? null : Border.all(color: const Color(0xFFEF5350).withOpacity(0.3), width: 1),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3))],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(color: _iconBg(type), shape: BoxShape.circle),
                                child: Icon(_icon(type), color: _iconColor(type), size: 22),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(data['title'] ?? '',
                                              style: TextStyle(fontSize: 14, fontWeight: isRead ? FontWeight.w600 : FontWeight.w800, color: const Color(0xFF2D2D2D))),
                                        ),
                                        if (!isRead)
                                          Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFFEF5350), shape: BoxShape.circle)),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(data['description'] ?? '', style: const TextStyle(fontSize: 12, color: Color(0xFF757575))),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.access_time, size: 12, color: Color(0xFF9E9E9E)),
                                        const SizedBox(width: 4),
                                        Text(_timeAgo(data['createdAt'] as Timestamp?), style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

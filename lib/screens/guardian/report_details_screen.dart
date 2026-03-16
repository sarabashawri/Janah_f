import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportDetailsScreen extends StatelessWidget {
  const ReportDetailsScreen({super.key});

  String _timeAgo(dynamic timestamp) {
    if (timestamp == null) return '';
    if (timestamp is! Timestamp) return '';
    final diff = DateTime.now().difference(timestamp.toDate());
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    return 'منذ ${diff.inDays} يوم';
  }

  @override
  Widget build(BuildContext context) {
    final String reportId =
        (ModalRoute.of(context)?.settings.arguments as String?) ?? '';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4EFEB),
        body: SafeArea(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFF3D5A6C),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: 16, top: 20,
                      child: IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                      ),
                    ),
                    const Center(
                      child: Text('متابعة حالة البلاغ',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('reports')
                      .doc(reportId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return const Center(child: Text('البلاغ غير موجود'));
                    }

                    final data = snapshot.data!.data() as Map<String, dynamic>;
                    final status = data['status'] ?? 'pending';
                    final statusColor = _statusColor(status);
                    final statusText = _statusLabel(status);

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          // ── Status Card ──
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('تفاصيل البلاغ',
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                                    const SizedBox(height: 4),
                                    Text('تم الإنشاء ${_timeAgo(data['createdAt'])}',
                                        style: const TextStyle(fontSize: 13, color: Color(0xFF757575))),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(20)),
                                  child: Text(statusText,
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // ── بيانات الطفل ──
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('بيانات الطفل',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 16),
                                _buildInfoRow(icon: Icons.person, label: 'اسم الطفل', value: data['childName'] ?? ''),
                                const SizedBox(height: 12),
                                _buildInfoRow(icon: Icons.checkroom_outlined, label: 'لون الملابس العلوية', value: data['clothingColor'] ?? ''),
                                const SizedBox(height: 12),
                                if ((data['description'] ?? '').toString().isNotEmpty) ...[
                                  _buildInfoRow(icon: Icons.description_outlined, label: 'وصف إضافي', value: data['description'] ?? ''),
                                  const SizedBox(height: 12),
                                ],
                                _buildInfoRow(icon: Icons.location_on, label: 'آخر موقع', value: data['location'] ?? ''),
                                const SizedBox(height: 12),
                                _buildInfoRow(
                                  icon: Icons.access_time,
                                  label: 'وقت الاختفاء',
                                  value: data['disappearanceTime'] ?? '',
                                  isLast: true,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // ── تحديثات البحث ──
                          const Text('تحديثات البحث',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
                            ),
                            child: Column(
                              children: [
                                _buildTimelineItem(
                                  title: 'تم استلام البلاغ',
                                  description: 'بانتظار الموافقة من قبل فريق الإنقاذ',
                                  time: _timeAgo(data['createdAt']),
                                  icon: Icons.receipt_long,
                                  color: const Color(0xFF9E9E9E),
                                  isLast: status == 'pending',
                                ),
                                if (status != 'pending' && status != 'active') ...[
                                  _buildTimelineItem(
                                    title: 'تم القبول',
                                    description: 'تم قبول البلاغ من قبل فريق الإنقاذ',
                                    time: '',
                                    icon: Icons.check_circle_outline,
                                    color: const Color(0xFF2196F3),
                                    isLast: status == 'accepted',
                                  ),
                                ],
                                if (status == 'searching' || status == 'inProgress' || status == 'matchFound' || status == 'found' || status == 'resolved' || status == 'closed') ...[
                                  _buildTimelineItem(
                                    title: 'بدأ فريق الإنقاذ البحث',
                                    description: 'تم الموافقة على عملية البحث',
                                    time: '',
                                    icon: Icons.people,
                                    color: const Color(0xFF2196F3),
                                    isLast: status == 'searching' || status == 'inProgress',
                                  ),
                                ],
                                if (status == 'matchFound' || status == 'found') ...[
                                  _buildTimelineItem(
                                    title: 'تم العثور على الطفل',
                                    description: 'تم التحقق من مطابقة الوجه',
                                    time: '',
                                    icon: Icons.check_circle,
                                    color: const Color(0xFF00D995),
                                    isLast: true,
                                  ),
                                ],
                                if (status == 'resolved' || status == 'closed') ...[
                                  _buildTimelineItem(
                                    title: 'تم إغلاق البلاغ',
                                    description: 'تم إغلاق البلاغ بعد التحقق',
                                    time: '',
                                    icon: Icons.cancel,
                                    color: const Color(0xFFFF5252),
                                    isLast: true,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // ── بطاقة المطابقة النهائية ──
                          if (status == 'matchFound' || status == 'found') ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFF00D995), width: 1.5),
                              ),
                              child: const Column(
                                children: [
                                  Icon(Icons.verified, color: Color(0xFF00D995), size: 40),
                                  SizedBox(height: 12),
                                  Text(
                                    'تم التحقق من مطابقة الوجه',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1B5E20),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'تواصل مع فريق الإنقاذ للتسليم',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF388E3C),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ],
                      ),
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

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':    return const Color(0xFFFF9800);
      case 'accepted':   return const Color(0xFF2196F3);
      case 'searching':  return const Color(0xFF2196F3);
      case 'matchFound': return const Color(0xFF00D995);
      case 'resolved':   return const Color(0xFF9E9E9E);
      // legacy values
      case 'active':     return const Color(0xFFFF9800);
      case 'inProgress': return const Color(0xFF2196F3);
      case 'found':      return const Color(0xFF00D995);
      case 'closed':     return const Color(0xFF9E9E9E);
      default:           return const Color(0xFFFF9800);
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'pending':    return 'قيد الانتظار';
      case 'accepted':   return 'تم القبول';
      case 'searching':  return 'جاري البحث';
      case 'matchFound': return 'تم العثور';
      case 'resolved':   return 'تم الإغلاق';
      // legacy values
      case 'active':     return 'قيد الانتظار';
      case 'inProgress': return 'جاري البحث';
      case 'found':      return 'تم العثور';
      case 'closed':     return 'تم الإغلاق';
      default:           return 'قيد الانتظار';
    }
  }

  Widget _buildInfoRow({required IconData icon, required String label, required String value, bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: const Color(0xFF757575)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineItem({required String title, required String description, required String time, required IconData icon, required Color color, required bool isLast}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 20),
            ),
            if (!isLast) Container(width: 2, height: 60, color: const Color(0xFFE0E0E0)),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(description, style: const TextStyle(fontSize: 12, color: Color(0xFF757575))),
              if (time.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(time, style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
              ],
              if (!isLast) const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }
}

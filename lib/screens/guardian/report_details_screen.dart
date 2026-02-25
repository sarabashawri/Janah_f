import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportDetailsScreen extends StatelessWidget {
  const ReportDetailsScreen({super.key});

  String _timeAgo(dynamic timestamp) {
    if (timestamp == null) return '';
    DateTime date;
    if (timestamp is Timestamp) {
      date = timestamp.toDate();
    } else {
      return '';
    }
    final diff = DateTime.now().difference(date);
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
                      right: 16,
                      top: 20,
                      child: IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                      ),
                    ),
                    const Center(
                      child: Text(
                        'متابعة حالة البلاغ',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
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

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Status Card
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
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(_timeAgo(data['createdAt']),
                                        style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(20)),
                                      child: Text(statusText,
                                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                const Text('تفاصيل البلاغ',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 4),
                                Text('تم الإنشاء ${_timeAgo(data['createdAt'])}',
                                    style: const TextStyle(fontSize: 13, color: Color(0xFF757575))),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Child Info Card
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
                                _buildInfoRow(icon: Icons.description, label: 'الوصف', value: data['description'] ?? ''),
                                const SizedBox(height: 12),
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

                          // Guardian Info Card
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
                                const Text('بيانات ولي الأمر',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 16),
                                _buildInfoRow(icon: Icons.person_outline, label: 'الاسم', value: data['guardianName'] ?? ''),
                                const SizedBox(height: 12),
                                _buildInfoRow(icon: Icons.phone, label: 'رقم الجوال', value: data['guardianPhone'] ?? '', isLast: true),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Timeline
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
                                  isLast: status == 'active',
                                ),
                                if (status != 'active') ...[
                                  _buildTimelineItem(
                                    title: 'بدأ فريق الإنقاذ البحث',
                                    description: 'تم الموافقة على عملية البحث',
                                    time: '',
                                    icon: Icons.people,
                                    color: const Color(0xFF2196F3),
                                    isLast: status == 'inProgress',
                                  ),
                                ],
                                if (status == 'found') ...[
                                  _buildTimelineItem(
                                    title: 'تم العثور على الطفل',
                                    description: 'الطفل بحالة جيدة',
                                    time: '',
                                    icon: Icons.check_circle,
                                    color: const Color(0xFF00D995),
                                    isLast: true,
                                  ),
                                ],
                                if (status == 'closed') ...[
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

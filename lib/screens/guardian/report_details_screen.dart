import 'package:flutter/material.dart';

class ReportData {
  final String reportId;
  final String childName;
  final String location;
  final String disappearTime;
  final String createdAgo;
  final String status;
  final Color statusColor;
  final List<TimelineEvent> timeline;

  const ReportData({
    required this.reportId,
    required this.childName,
    required this.location,
    required this.disappearTime,
    required this.createdAgo,
    required this.status,
    required this.statusColor,
    required this.timeline,
  });
}

class TimelineEvent {
  final String title;
  final String description;
  final String time;
  final IconData icon;
  final Color color;

  const TimelineEvent({
    required this.title,
    required this.description,
    required this.time,
    required this.icon,
    required this.color,
  });
}

final Map<String, ReportData> allReports = {
  '#1234': const ReportData(
    reportId: '#1234',
    childName: 'محمد أحمد',
    location: 'حي النزهة، شارع الملك فهد',
    disappearTime: 'اليوم 14:30',
    createdAgo: 'منذ 3 ساعات',
    status: 'جاري البحث',
    statusColor: Color(0xFF00D995),
    timeline: [
      TimelineEvent(title: 'تم العثور على الطفل', description: 'الطفل بحالة جيدة - يتم نقله للموقع الآمن', time: 'منذ ساعة', icon: Icons.check_circle, color: Color(0xFF00D995)),
      TimelineEvent(title: 'بدأ فريق الإنقاذ البحث', description: 'تم الموافقة على عملية البحث', time: 'منذ ساعتين', icon: Icons.people, color: Color(0xFF2196F3)),
      TimelineEvent(title: 'تم استلام البلاغ', description: 'بانتظار الموافقة من قبل فريق الإنقاذ', time: 'منذ 3 ساعات', icon: Icons.receipt_long, color: Color(0xFF9E9E9E)),
    ],
  ),
  '#1235': const ReportData(
    reportId: '#1235',
    childName: 'سارة أحمد',
    location: 'حي الروضة',
    disappearTime: 'اليوم 10:00',
    createdAgo: 'منذ 15 دقيقة',
    status: 'تم العثور',
    statusColor: Color(0xFF00D995),
    timeline: [
      TimelineEvent(title: 'تم العثور على الطفلة', description: 'الطفلة بحالة جيدة وبأمان', time: 'منذ 5 دقائق', icon: Icons.check_circle, color: Color(0xFF00D995)),
      TimelineEvent(title: 'بدأ فريق الإنقاذ البحث', description: 'الفريق في المنطقة يبحث', time: 'منذ 10 دقائق', icon: Icons.people, color: Color(0xFF2196F3)),
      TimelineEvent(title: 'تم استلام البلاغ', description: 'بانتظار الموافقة من قبل فريق الإنقاذ', time: 'منذ 15 دقيقة', icon: Icons.receipt_long, color: Color(0xFF9E9E9E)),
    ],
  ),
  '#1232': const ReportData(
    reportId: '#1232',
    childName: 'فاطمة ماجد',
    location: 'حي العليا',
    disappearTime: 'منذ أسبوع 09:15',
    createdAgo: 'منذ أسبوع',
    status: 'مغلق',
    statusColor: Color(0xFFFF5252),
    timeline: [
      TimelineEvent(title: 'تم إغلاق البلاغ', description: 'تم إغلاق البلاغ بعد التحقق', time: 'منذ يومين', icon: Icons.cancel, color: Color(0xFFFF5252)),
      TimelineEvent(title: 'بدأ فريق الإنقاذ البحث', description: 'تم الموافقة على عملية البحث', time: 'منذ 5 أيام', icon: Icons.people, color: Color(0xFF2196F3)),
      TimelineEvent(title: 'تم استلام البلاغ', description: 'بانتظار الموافقة من قبل فريق الإنقاذ', time: 'منذ أسبوع', icon: Icons.receipt_long, color: Color(0xFF9E9E9E)),
    ],
  ),
};

class ReportDetailsScreen extends StatelessWidget {
  const ReportDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String reportId =
        (ModalRoute.of(context)?.settings.arguments as String?) ?? '#1234';
    final ReportData report = allReports[reportId] ?? allReports['#1234']!;

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
                child: SingleChildScrollView(
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
                                Text(report.createdAgo, style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(color: report.statusColor, borderRadius: BorderRadius.circular(20)),
                                  child: Text(report.status, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text('بلاغ رقم ${report.reportId}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Text('تم الإنشاء ${report.createdAgo}', style: const TextStyle(fontSize: 13, color: Color(0xFF757575))),
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
                            const Text('بيانات الطفل', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 16),
                            _buildInfoRow(icon: Icons.person, label: 'اسم الطفل', value: report.childName),
                            const SizedBox(height: 12),
                            _buildInfoRow(icon: Icons.location_on, label: 'آخر موقع', value: report.location),
                            const SizedBox(height: 12),
                            _buildInfoRow(icon: Icons.access_time, label: 'وقت الاختفاء', value: report.disappearTime, isLast: true),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text('تحديثات البحث', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
                        ),
                        child: Column(
                          children: report.timeline.asMap().entries.map((entry) =>
                            _buildTimelineItem(
                              title: entry.value.title,
                              description: entry.value.description,
                              time: entry.value.time,
                              icon: entry.value.icon,
                              color: entry.value.color,
                              isLast: entry.key == report.timeline.length - 1,
                            )
                          ).toList(),
                        ),
                      ),
                    ],
                  ),
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
              const SizedBox(height: 4),
              Text(time, style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
              if (!isLast) const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }
}

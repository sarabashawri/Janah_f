import 'package:flutter/material.dart';

class RescuerNotificationsScreen extends StatefulWidget {
  const RescuerNotificationsScreen({super.key});

  @override
  State<RescuerNotificationsScreen> createState() => _RescuerNotificationsScreenState();
}

class _RescuerNotificationsScreenState extends State<RescuerNotificationsScreen> {
  final List<_NotificationItem> _notifications = [
    _NotificationItem(
      title: 'بلاغ جديد',
      subtitle: 'تم تسجيل بلاغ عن طفل مفقود في حي النزهة',
      time: 'منذ 5 دقائق',
      type: _NotifType.newReport,
      isRead: false,
    ),
    _NotificationItem(
      title: 'تم إغلاق البلاغ #1230',
      subtitle: 'تم العثور على الطفل بنجاح في حي الروضة',
      time: 'منذ ساعة',
      type: _NotifType.closed,
      isRead: false,
    ),
    _NotificationItem(
      title: 'تحديث موقع البحث',
      subtitle: 'تم توسيع نطاق البحث للبلاغ #1234',
      time: 'منذ ساعتين',
      type: _NotifType.location,
      isRead: false,
    ),
    _NotificationItem(
      title: 'تعيين مهمة جديدة',
      subtitle: 'تم تعيينك في بلاغ #1235 - حي الملقا',
      time: 'منذ 3 ساعات',
      type: _NotifType.newReport,
      isRead: true,
    ),
    _NotificationItem(
      title: 'تحديث حالة الدرون',
      subtitle: 'الدرون DR-01 يحتاج إلى شحن - البطارية 15%',
      time: 'منذ 5 ساعات',
      type: _NotifType.location,
      isRead: true,
    ),
  ];

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  void _markAllRead() {
    setState(() {
      for (var n in _notifications) {
        n.isRead = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4EFEB),
        body: Column(
          children: [
            // ── HEADER ──
            Container(
              width: double.infinity,
              color: const Color(0xFF3D5A6C),
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 12,
                bottom: 16,
                right: 20,
                left: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // صف 1: يسار فاضي | التنبيهات وسط | سهم يمين
                  Row(
                    children: [
                      // يمين: سهم رجوع
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_forward, color: Colors.white, size: 22),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      // وسط: العنوان
                      const Expanded(
                        child: Text(
                          'التنبيهات',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                      ),
                      // يسار: مساحة موازية لحجم السهم
                      const SizedBox(width: 32),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // صف 2: تعليم الكل + عدد التنبيهات - يسار
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      TextButton(
                        onPressed: _markAllRead,
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        child: const Text(
                          'تعليم الكل كمقروء',
                          style: TextStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w500),
                        ),
                      ),
                      if (_unreadCount > 0) ...[
                        const SizedBox(width: 10),
                        const Icon(Icons.circle, size: 8, color: Color(0xFFEF5350)),
                        const SizedBox(width: 4),
                        Text(
                          '$_unreadCount تنبيهات جديدة',
                          style: const TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // ── القائمة ──
            Expanded(
              child: _notifications.isEmpty
                  ? const Center(
                      child: Text('لا توجد تنبيهات', style: TextStyle(color: Colors.grey)),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _notifications.length,
                      itemBuilder: (context, index) {
                        return _NotifCard(
                          item: _notifications[index],
                          onTap: () {
                            setState(() => _notifications[index].isRead = true);
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

// ── نوع التنبيه ──
enum _NotifType { newReport, closed, location }

// ── بيانات التنبيه ──
class _NotificationItem {
  _NotificationItem({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.type,
    required this.isRead,
  });
  final String title, subtitle, time;
  final _NotifType type;
  bool isRead;
}

// ── كارد التنبيه ──
class _NotifCard extends StatelessWidget {
  const _NotifCard({required this.item, required this.onTap});
  final _NotificationItem item;
  final VoidCallback onTap;

  Color get _iconBg {
    switch (item.type) {
      case _NotifType.newReport: return const Color(0xFFFFEBEE);
      case _NotifType.closed:    return const Color(0xFFE8F5E9);
      case _NotifType.location:  return const Color(0xFFE3F2FD);
    }
  }

  Color get _iconColor {
    switch (item.type) {
      case _NotifType.newReport: return const Color(0xFFEF5350);
      case _NotifType.closed:    return const Color(0xFF00D995);
      case _NotifType.location:  return const Color(0xFF2196F3);
    }
  }

  IconData get _icon {
    switch (item.type) {
      case _NotifType.newReport: return Icons.error_outline;
      case _NotifType.closed:    return Icons.check_circle_outline;
      case _NotifType.location:  return Icons.location_on_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: item.isRead
              ? null
              : Border.all(color: const Color(0xFFEF5350).withOpacity(0.2), width: 1),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // المحتوى - يمين
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (!item.isRead)
                        Container(
                          width: 8, height: 8,
                          margin: const EdgeInsets.only(left: 6),
                          decoration: const BoxDecoration(
                            color: Color(0xFFEF5350),
                            shape: BoxShape.circle,
                          ),
                        ),
                      Text(item.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: item.isRead ? FontWeight.w600 : FontWeight.w700,
                            color: const Color(0xFF2D2D2D),
                          )),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(item.subtitle,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF757575)),
                      textAlign: TextAlign.right),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(item.time,
                          style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
                      const SizedBox(width: 4),
                      const Icon(Icons.access_time, size: 12, color: Color(0xFF9E9E9E)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // الأيقونة - يسار
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: _iconBg, shape: BoxShape.circle),
              child: Icon(_icon, color: _iconColor, size: 22),
            ),
          ],
        ),
      ),
    );
  }
}

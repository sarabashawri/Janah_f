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
      isRead: true,
    ),
    _NotificationItem(
      title: 'تحديث موقع البحث',
      subtitle: 'تم توسيع نطاق البحث للبلاغ #1234',
      time: 'منذ ساعتين',
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
                top: MediaQuery.of(context).padding.top + 8,
                bottom: 12,
                right: 8,
                left: 16,
              ),
              child: Column(
                children: [
                  // صف 1: تعليم الكل يمين | العنوان وسط | سهم يسار
                  Row(
                    children: [
                      // سهم رجوع - يسار
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      // العنوان وسط
                      const Expanded(
                        child: Text(
                          'التنبيهات',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                      ),
                      // تعليم الكل - يمين
                      GestureDetector(
                        onTap: _markAllRead,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'تعليم الكل كمقروء',
                            style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // صف 2: عدد التنبيهات - يمين
                  if (_unreadCount > 0)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 7, height: 7,
                          decoration: const BoxDecoration(color: Color(0xFFEF5350), shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$_unreadCount تنبيهات جديدة',
                          style: const TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            // ── القائمة ──
            Expanded(
              child: ListView.builder(
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
        // ── بوتم نافيقيشن ──
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 0,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF3D5A6C),
          unselectedItemColor: const Color(0xFF9E9E9E),
          onTap: (index) {
            if (index == 0) Navigator.pop(context); // الرئيسية
            if (index == 1) Navigator.pop(context); // البلاغات
            if (index == 2) Navigator.pop(context); // الخريطة
            if (index == 3) Navigator.pop(context); // الملف
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'الرئيسية'),
            BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), activeIcon: Icon(Icons.assignment), label: 'البلاغات'),
            BottomNavigationBarItem(icon: Icon(Icons.map_outlined), activeIcon: Icon(Icons.map), label: 'الخريطة'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'الملف'),
          ],
        ),
      ),
    );
  }
}

enum _NotifType { newReport, closed, location }

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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: item.isRead
              ? null
              : Border.all(color: const Color(0xFFEF5350).withOpacity(0.3), width: 1),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // الأيقونة يمين
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: _iconBg, shape: BoxShape.circle),
                child: Icon(_icon, color: _iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              // المحتوى
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(item.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: item.isRead ? FontWeight.w600 : FontWeight.w800,
                              color: const Color(0xFF2D2D2D),
                            )),
                        if (!item.isRead) ...[
                          const SizedBox(width: 6),
                          Container(
                            width: 8, height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFFEF5350),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(item.subtitle,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF757575))),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 12, color: Color(0xFF9E9E9E)),
                        const SizedBox(width: 4),
                        Text(item.time, style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

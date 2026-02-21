import 'package:flutter/material.dart';

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

  // ✅ موديل بسيط للتنبيه
  final List<_NotificationItem> _items = [
    _NotificationItem(
      title: 'بدأت مهمة البحث',
      description: 'تم إطلاق الدرون وبدأ البحث في المنطقة المحددة',
      time: 'منذ 15 دقيقة',
      icon: Icons.flight_takeoff,
      tint: Color(0xFF00D995),
      isRead: false,
    ),
    _NotificationItem(
      title: 'تم العثور على البلاغ #3230',
      description: 'تم العثور على الطفل بحالة جيدة في حي الروضة',
      time: 'منذ ساعة',
      icon: Icons.check_circle,
      tint: Color(0xFF00D995),
      isRead: false,
    ),
    _NotificationItem(
      title: 'تحديث موقع البلاغ #1234',
      description: 'تم تحديث موقع البحث، الدرون في طريقها للمكان',
      time: 'منذ 3 ساعات',
      icon: Icons.location_on,
      tint: Color(0xFF2196F3),
      isRead: false,
    ),
    _NotificationItem(
      title: 'تم استلام البلاغ',
      description: 'تم استلام بلاغكم بنجاح وسيتم التواصل معكم قريباً',
      time: 'منذ 3 ساعات',
      icon: Icons.notifications,
      tint: Color(0xFF9E9E9E),
      isRead: true,
    ),
  ];

  int get _unreadCount => _items.where((e) => !e.isRead).length;

  void _markAllAsRead() {
    setState(() {
      for (final n in _items) {
        n.isRead = true;
      }
    });
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
                      child: TextButton(
                        onPressed: _unreadCount == 0 ? null : _markAllAsRead,
                        child: Text(
                          'قراءة الكل',
                          style: TextStyle(
                            fontSize: 14,
                            color: _unreadCount == 0 ? Colors.white38 : Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: _items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final n = _items[i];
                    return _NotificationCardWhite(
                      title: n.title,
                      description: n.description,
                      time: n.time,
                      icon: n.icon,
                      tint: n.tint,
                      isRead: n.isRead,
                      onTap: () {
                        setState(() => n.isRead = true);
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

class _NotificationItem {
  _NotificationItem({
    required this.title,
    required this.description,
    required this.time,
    required this.icon,
    required this.tint,
    required this.isRead,
  });

  final String title;
  final String description;
  final String time;
  final IconData icon;
  final Color tint;
  bool isRead;
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

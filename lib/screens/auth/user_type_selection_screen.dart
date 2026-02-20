import 'package:flutter/material.dart';

class UserTypeSelectionScreen extends StatelessWidget {
  const UserTypeSelectionScreen({super.key});

  static const Color _bg = Color(0xFFF4EFEB);
  static const Color _primary = Color(0xFF3D5A6C);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _bg,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;
              final horizontalPadding = isWide ? 80.0 : 24.0;

              return SingleChildScrollView(
                child: Column(
                  children: [

                    // ===== HEADER FULL WIDTH =====
                    const _HeaderBar(),

                    // ===== CONTENT WITH PADDING =====
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                      child: Column(
                        children: [

                          const SizedBox(height: 30),

                          const Text(
                            'نظام متطور باستخدام الدرون',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 10),

                          const Text(
                            'تقنية الذكاء الاصطناعي والطائرات بدون طيار لتسريع عمليات البحث والإنقاذ',
                            style: TextStyle(
                              fontSize: 15,
                              color: Color(0xFF757575),
                              height: 1.6,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 30),

                          _UserTypeCard(
                            icon: Icons.person_outline,
                            title: 'ولي أمر',
                            description: 'للإبلاغ عن حالات فقدان وتتبع البلاغات',
                            onTap: () =>
                                Navigator.pushNamed(context, '/guardian/login'),
                          ),

                          const SizedBox(height: 18),

                          _UserTypeCard(
                            icon: Icons.groups_outlined,
                            title: 'فريق الإنقاذ',
                            description: 'إدارة المهمات والتحكم بالمركبات',
                            onTap: () =>
                                Navigator.pushNamed(context, '/rescuer/login'),
                          ),

                          const SizedBox(height: 20),

                          _BottomAction(
                            title: 'التواصل مع الدعم',
                            icon: Icons.support_agent,
                            onTap: () =>
                                Navigator.pushNamed(context, '/guardian/support'),
                          ),

                          const SizedBox(height: 12),

                          _BottomAction(
                            title: 'عن جناح',
                            icon: Icons.info_outline,
                            onTap: () =>
                                Navigator.pushNamed(context, '/guardian/about'),
                          ),

                          const SizedBox(height: 18),

                          const Text(
                            'معاً لحماية أطفالنا وإنقاذهم بأمان',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF9E9E9E),
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
// HEADER
//////////////////////////////////////////////////////////////

class _HeaderBar extends StatelessWidget {
  const _HeaderBar();

  static const Color _primary = Color(0xFF3D5A6C);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      color: _primary,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          // اللوقو
          Image.asset(
            'assets/images/logo.png',
            height: 52,
            fit: BoxFit.contain,
          ),

          const SizedBox(width: 14),

          // النص بجانبه بنفس السطر
          const Expanded(
            child: Text(
              'نظام البحث والإنقاذ للأطفال المفقودين',
              style: TextStyle(
                fontSize: 14, // ✅ مثل ما طلبتي
                color: Colors.white70,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
// USER TYPE CARD
//////////////////////////////////////////////////////////////

class _UserTypeCard extends StatelessWidget {
  const _UserTypeCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  static const Color _primary = Color(0xFF3D5A6C);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [

            // أيقونة يسار
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: _primary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),

            const SizedBox(width: 16),

            // النص
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF757575),
                    ),
                  ),
                ],
              ),
            ),

            const Icon(Icons.chevron_left,
                color: _primary, size: 30),
          ],
        ),
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
// BOTTOM ACTION
//////////////////////////////////////////////////////////////

class _BottomAction extends StatelessWidget {
  const _BottomAction({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  static const Color _primary = Color(0xFF3D5A6C);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEAEAEA)),
        ),
        child: Row(
          children: [
            Icon(icon, color: _primary, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Icon(Icons.chevron_left, color: _primary),
          ],
        ),
      ),
    );
  }
}
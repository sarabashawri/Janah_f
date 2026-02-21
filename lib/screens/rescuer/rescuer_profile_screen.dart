import 'package:flutter/material.dart';

class RescuerProfileScreen extends StatefulWidget {
  const RescuerProfileScreen({super.key});

  @override
  State<RescuerProfileScreen> createState() => _RescuerProfileScreenState();
}

class _RescuerProfileScreenState extends State<RescuerProfileScreen> {
  bool _isAvailable = true;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4EFEB),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [

                // ── HEADER ──
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  color: const Color(0xFFF4EFEB),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('الملف الشخصي', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.settings_outlined, color: Color(0xFF3D5A6C)),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [

                      // ── بطاقة المستخدم ──
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF3D5A6C),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(Icons.security, color: Colors.white, size: 32),
                                ),
                                const SizedBox(width: 14),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('خالد السالم', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                                      SizedBox(height: 4),
                                      Text('فريق الإنقاذ #3', style: TextStyle(fontSize: 13, color: Color(0xFF757575))),
                                      SizedBox(height: 2),
                                      Text('قسم العمليات', style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Divider(height: 1),
                            const SizedBox(height: 14),
                            // مفتاح المتاحية
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 10, height: 10,
                                      decoration: BoxDecoration(
                                        color: _isAvailable ? const Color(0xFF00D995) : const Color(0xFF9E9E9E),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _isAvailable ? 'متاح للمهام' : 'غير متاح',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: _isAvailable ? const Color(0xFF00D995) : const Color(0xFF9E9E9E),
                                      ),
                                    ),
                                  ],
                                ),
                                Switch(
                                  value: _isAvailable,
                                  onChanged: (v) => setState(() => _isAvailable = v),
                                  activeColor: const Color(0xFF00D995),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── الإحصائيات الشخصية ──
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.bar_chart_rounded, color: Color(0xFF3D5A6C), size: 18),
                                SizedBox(width: 6),
                                Text('الإحصائيات الشخصية', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                _StatBox(value: '94%', label: 'نسبة النجاح', color: const Color(0xFF2196F3), icon: Icons.person),
                                const SizedBox(width: 10),
                                _StatBox(value: '47', label: 'مهام مكتملة', color: const Color(0xFF00D995), icon: Icons.check_circle_outline),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                _StatBox(value: '2', label: 'مهام نشطة', color: const Color(0xFF9C27B0), icon: Icons.pending_actions),
                                const SizedBox(width: 10),
                                _StatBox(value: '12', label: 'دقيقة متوسط', color: const Color(0xFFFF9800), icon: Icons.timer_outlined),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── الأداء ──
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // مميز
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text('مميز', style: TextStyle(fontSize: 13, color: Color(0xFF9E9E9E))),
                                Text('وقت الاستجابة', style: TextStyle(fontSize: 13, color: Color(0xFF9E9E9E))),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: 0.88,
                                backgroundColor: const Color(0xFFE0E0E0),
                                color: const Color(0xFF00D995),
                                minHeight: 8,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // ساعات العمل
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text('ساعات العمل', style: TextStyle(fontSize: 13, color: Color(0xFF9E9E9E))),
                                Text('142 ساعة', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF2D2D2D))),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: 0.71,
                                backgroundColor: const Color(0xFFE0E0E0),
                                color: const Color(0xFFFF9800),
                                minHeight: 8,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── الإعدادات والأمان ──
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                              child: Text('الإعدادات والأمان', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                            ),
                            _SettingItem(icon: Icons.lock_outline, title: 'تغيير كلمة المرور', onTap: () {}),
                            _SettingItem(icon: Icons.notifications_outlined, title: 'إعدادات التنبيهات', onTap: () {}),
                            _SettingItem(icon: Icons.person_outline, title: 'تعديل المعلومات الشخصية', onTap: () {}, isLast: true),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── زر تسجيل الخروج ──
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton.icon(
                          onPressed: () => _showLogoutDialog(context),
                          icon: const Icon(Icons.logout, color: Color(0xFFEF5350)),
                          label: const Text('تسجيل الخروج', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFFEF5350))),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFEF5350)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      const Text('نسخة التطبيق 1.0.0 | غرفة العمليات', style: TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تسجيل الخروج'),
          content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamedAndRemoveUntil(context, '/rescuer/login', (route) => false);
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF5350)),
              child: const Text('تأكيد'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── WIDGETS ───

class _StatBox extends StatelessWidget {
  const _StatBox({required this.value, required this.label, required this.color, required this.icon});
  final String value, label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF757575)), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _SettingItem extends StatelessWidget {
  const _SettingItem({required this.icon, required this.title, required this.onTap, this.isLast = false});
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: isLast ? null : const Border(bottom: BorderSide(color: Color(0xFFF0F0F0))),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF3D5A6C), size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
            const Icon(Icons.arrow_back, size: 18, color: Color(0xFF9E9E9E)),
          ],
        ),
      ),
    );
  }
}

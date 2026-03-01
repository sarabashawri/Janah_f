import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ═══════════════════════════════════════════════
// الملف الشخصي الرئيسي
// ═══════════════════════════════════════════════
class RescuerProfileScreen extends StatefulWidget {
  const RescuerProfileScreen({super.key});
  @override
  State<RescuerProfileScreen> createState() => _RescuerProfileScreenState();
}

class _RescuerProfileScreenState extends State<RescuerProfileScreen> {
  bool _isAvailable = true;
  static const Color kPrimary = Color(0xFF3D5A6C);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4EFEB),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              color: kPrimary,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 12,
                bottom: 16, right: 20, left: 20,
              ),
              child: const Text('الملف الشخصي',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      // بطاقة المستخدم
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                        ),
                        child: Column(children: [
                          Row(children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(color: kPrimary, borderRadius: BorderRadius.circular(16)),
                              child: const Icon(Icons.security, color: Colors.white, size: 32),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('خالد السالم', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                                SizedBox(height: 4),
                                Text('فريق الإنقاذ #3', style: TextStyle(fontSize: 13, color: Color(0xFF757575))),
                                SizedBox(height: 2),
                                Text('قسم العمليات', style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
                              ],
                            )),
                          ]),
                          const SizedBox(height: 16),
                          const Divider(height: 1),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(children: [
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
                                    fontSize: 14, fontWeight: FontWeight.w600,
                                    color: _isAvailable ? const Color(0xFF00D995) : const Color(0xFF9E9E9E),
                                  ),
                                ),
                              ]),
                              Switch(
                                value: _isAvailable,
                                onChanged: (v) => setState(() => _isAvailable = v),
                                activeColor: const Color(0xFF00D995),
                              ),
                            ],
                          ),
                        ]),
                      ),
                      const SizedBox(height: 16),
                      // الإحصائيات
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
                            const Row(children: [
                              Icon(Icons.bar_chart_rounded, color: kPrimary, size: 18),
                              SizedBox(width: 6),
                              Text('الإحصائيات الشخصية', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                            ]),
                            const SizedBox(height: 14),
                            Row(children: [
                              _StatBox(value: '94%', label: 'نسبة النجاح', color: const Color(0xFF2196F3), icon: Icons.person),
                              const SizedBox(width: 10),
                              _StatBox(value: '47', label: 'مهام مكتملة', color: const Color(0xFF00D995), icon: Icons.check_circle_outline),
                            ]),
                            const SizedBox(height: 10),
                            Row(children: [
                              _StatBox(value: '2', label: 'مهام نشطة', color: const Color(0xFF9C27B0), icon: Icons.pending_actions),
                              const SizedBox(width: 10),
                              _StatBox(value: '12', label: 'دقيقة متوسط', color: const Color(0xFFFF9800), icon: Icons.timer_outlined),
                            ]),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // أداء الشهر
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
                            const Text('أداء الشهر الحالي', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 14),
                            _progressRow('المهام المكتملة', '12/15', 0.80, const Color(0xFF00D995)),
                            const SizedBox(height: 14),
                            _progressRow('وقت الاستجابة', 'ممتاز', 0.88, const Color(0xFF2196F3)),
                            const SizedBox(height: 14),
                            _progressRow('ساعات العمل', '142 ساعة', 0.71, const Color(0xFFFF9800)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // الإعدادات والأمان
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
                            _SettingItem(
                              icon: Icons.lock_outline,
                              title: 'تغيير كلمة المرور',
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordScreen())),
                            ),
                            _SettingItem(
                              icon: Icons.notifications_outlined,
                              title: 'إعدادات التنبيهات',
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsSettingsScreen())),
                            ),
                            _SettingItem(
                              icon: Icons.person_outline,
                              title: 'تعديل المعلومات الشخصية',
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())),
                              isLast: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity, height: 52,
                        child: OutlinedButton.icon(
                          onPressed: () => _showLogoutDialog(context),
                          icon: const Icon(Icons.logout, color: Color(0xFFEF5350)),
                          label: const Text('تسجيل الخروج',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFFEF5350))),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFEF5350)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text('نسخة التطبيق 1.0.0 | غرفة العمليات',
                          style: TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _progressRow(String label, String value, double progress, Color color) {
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF2D2D2D))),
        Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF9E9E9E))),
      ]),
      const SizedBox(height: 6),
      ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: LinearProgressIndicator(value: progress, backgroundColor: const Color(0xFFE0E0E0), color: color, minHeight: 8),
      ),
    ]);
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
              child: const Text('تأكيد', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// تغيير كلمة المرور
// ═══════════════════════════════════════════════
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});
  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();
  bool _loading = false;
  bool _showCurrent = false, _showNew = false, _showConfirm = false;

  static const Color kPrimary = Color(0xFF3D5A6C);

  @override
  void dispose() {
    _currentPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('غير مسجل الدخول');
      final cred = EmailAuthProvider.credential(email: user.email!, password: _currentPassController.text);
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(_newPassController.text);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تغيير كلمة المرور بنجاح'), backgroundColor: Color(0xFF00D995)),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('كلمة المرور الحالية غير صحيحة'), backgroundColor: Colors.red),
        );
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4EFEB),
        body: Column(
          children: [
            _buildHeader(context, 'تغيير كلمة المرور'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(children: [
                    const SizedBox(height: 8),
                    _buildCard(children: [
                      const Row(children: [
                        Icon(Icons.lock_outline, color: kPrimary, size: 18),
                        SizedBox(width: 8),
                        Text('تغيير كلمة المرور', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      ]),
                      const SizedBox(height: 6),
                      const Text('يرجى إدخال كلمة المرور الحالية ثم كلمة المرور الجديدة',
                          style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
                      const SizedBox(height: 20),
                      _passField(_currentPassController, 'كلمة المرور الحالية', _showCurrent,
                          () => setState(() => _showCurrent = !_showCurrent),
                          (v) => (v == null || v.isEmpty) ? 'هذا الحقل مطلوب' : null),
                      const SizedBox(height: 16),
                      _passField(_newPassController, 'كلمة المرور الجديدة', _showNew,
                          () => setState(() => _showNew = !_showNew),
                          (v) {
                            if (v == null || v.isEmpty) return 'هذا الحقل مطلوب';
                            if (v.length < 6) return 'يجب أن تكون 6 أحرف على الأقل';
                            return null;
                          }),
                      const SizedBox(height: 16),
                      _passField(_confirmPassController, 'تأكيد كلمة المرور الجديدة', _showConfirm,
                          () => setState(() => _showConfirm = !_showConfirm),
                          (v) {
                            if (v == null || v.isEmpty) return 'هذا الحقل مطلوب';
                            if (v != _newPassController.text) return 'كلمة المرور غير متطابقة';
                            return null;
                          }),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity, height: 52,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _changePassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _loading
                              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('حفظ كلمة المرور',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                        ),
                      ),
                    ]),
                  ]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _passField(TextEditingController ctrl, String label, bool show, VoidCallback toggle, String? Function(String?) validator) {
    return TextFormField(
      controller: ctrl,
      obscureText: !show,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: IconButton(
          icon: Icon(show ? Icons.visibility_off : Icons.visibility, color: const Color(0xFF9E9E9E)),
          onPressed: toggle,
        ),
        suffixIcon: const Icon(Icons.lock_outline, color: Color(0xFF9E9E9E)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kPrimary, width: 2)),
        filled: true, fillColor: const Color(0xFFF9F9F9),
      ),
      validator: validator,
    );
  }
}

// ═══════════════════════════════════════════════
// تعديل المعلومات الشخصية
// ═══════════════════════════════════════════════
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'خالد السالم');
  final _phoneController = TextEditingController(text: '+966 50 123 4567');
  final _teamController = TextEditingController(text: 'فريق الإنقاذ #3');
  final _deptController = TextEditingController(text: 'قسم العمليات');
  bool _loading = false;
  static const Color kPrimary = Color(0xFF3D5A6C);

  @override
  void dispose() {
    _nameController.dispose(); _phoneController.dispose();
    _teamController.dispose(); _deptController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('rescuers').doc(user.uid).update({
          'name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'team': _teamController.text.trim(),
          'department': _deptController.text.trim(),
        });
      }
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حفظ المعلومات بنجاح'), backgroundColor: Color(0xFF00D995)),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red));
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4EFEB),
        body: Column(
          children: [
            _buildHeader(context, 'تعديل المعلومات الشخصية'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(children: [
                    const SizedBox(height: 8),
                    _buildCard(children: [
                      const Row(children: [
                        Icon(Icons.person_outline, color: kPrimary, size: 18),
                        SizedBox(width: 8),
                        Text('المعلومات الشخصية', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      ]),
                      const SizedBox(height: 20),
                      _field(_nameController, 'الاسم الكامل', Icons.person_outline),
                      const SizedBox(height: 14),
                      _field(_phoneController, 'رقم الجوال', Icons.phone_outlined, isPhone: true),
                      const SizedBox(height: 14),
                      _field(_teamController, 'الفريق', Icons.group_outlined),
                      const SizedBox(height: 14),
                      _field(_deptController, 'القسم', Icons.business_outlined),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity, height: 52,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _loading
                              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('حفظ المعلومات',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                        ),
                      ),
                    ]),
                  ]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon, {bool isPhone = false}) {
    return TextFormField(
      controller: ctrl,
      textAlign: TextAlign.right,
      keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
      textDirection: isPhone ? TextDirection.ltr : TextDirection.rtl,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF9E9E9E)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF3D5A6C), width: 2)),
        filled: true, fillColor: const Color(0xFFF9F9F9),
      ),
      validator: (v) => (v == null || v.isEmpty) ? 'هذا الحقل مطلوب' : null,
    );
  }
}

// ═══════════════════════════════════════════════
// إعدادات التنبيهات
// ═══════════════════════════════════════════════
class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});
  @override
  State<NotificationsSettingsScreen> createState() => _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState extends State<NotificationsSettingsScreen> {
  bool _newMissions = true;
  bool _suspiciousPoints = true;
  bool _missionUpdates = true;
  bool _systemAlerts = false;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  static const Color kPrimary = Color(0xFF3D5A6C);
  static const Color kGreen   = Color(0xFF00D995);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4EFEB),
        body: Column(
          children: [
            _buildHeader(context, 'إعدادات التنبيهات'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  const SizedBox(height: 8),
                  _buildCard(children: [
                    const Row(children: [
                      Icon(Icons.notifications_outlined, color: kPrimary, size: 18),
                      SizedBox(width: 8),
                      Text('أنواع التنبيهات', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    ]),
                    const SizedBox(height: 14),
                    _toggle('مهام جديدة', 'إشعار عند تعيين مهمة جديدة', _newMissions, (v) => setState(() => _newMissions = v)),
                    const Divider(height: 20),
                    _toggle('نقاط الاشتباه', 'إشعار عند اكتشاف نقطة اشتباه', _suspiciousPoints, (v) => setState(() => _suspiciousPoints = v)),
                    const Divider(height: 20),
                    _toggle('تحديثات المهمة', 'إشعار عند تحديث حالة المهمة', _missionUpdates, (v) => setState(() => _missionUpdates = v)),
                    const Divider(height: 20),
                    _toggle('تنبيهات النظام', 'إشعارات تقنية وتحديثات التطبيق', _systemAlerts, (v) => setState(() => _systemAlerts = v)),
                  ]),
                  const SizedBox(height: 16),
                  _buildCard(children: [
                    const Row(children: [
                      Icon(Icons.volume_up_outlined, color: kPrimary, size: 18),
                      SizedBox(width: 8),
                      Text('الصوت والاهتزاز', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    ]),
                    const SizedBox(height: 14),
                    _toggle('الصوت', 'تشغيل صوت التنبيهات', _soundEnabled, (v) => setState(() => _soundEnabled = v)),
                    const Divider(height: 20),
                    _toggle('الاهتزاز', 'تفعيل الاهتزاز عند التنبيه', _vibrationEnabled, (v) => setState(() => _vibrationEnabled = v)),
                  ]),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity, height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('تم حفظ إعدادات التنبيهات'), backgroundColor: kGreen),
                        );
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('حفظ الإعدادات',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toggle(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
          ],
        )),
        Switch(value: value, onChanged: onChanged, activeColor: kGreen),
      ],
    );
  }
}

// ═══════════════════════════════════════════════
// Helpers مشتركة
// ═══════════════════════════════════════════════
Widget _buildHeader(BuildContext context, String title) {
  return Container(
    width: double.infinity,
    color: const Color(0xFF3D5A6C),
    padding: EdgeInsets.only(
      top: MediaQuery.of(context).padding.top + 8,
      bottom: 16, right: 8, left: 16,
    ),
    child: Row(children: [
      IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
      Expanded(
        child: Text(title, textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
      ),
      const SizedBox(width: 32),
    ]),
  );
}

Widget _buildCard({required List<Widget> children}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
  );
}

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
        decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(14)),
        child: Column(children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF757575)), textAlign: TextAlign.center),
        ]),
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
        child: Row(children: [
          Icon(icon, color: const Color(0xFF3D5A6C), size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF9E9E9E)),
        ]),
      ),
    );
  }
}

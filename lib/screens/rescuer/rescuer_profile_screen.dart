import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RescuerProfileScreen extends StatefulWidget {
  const RescuerProfileScreen({super.key});
  @override
  State<RescuerProfileScreen> createState() => _RescuerProfileScreenState();
}

class _RescuerProfileScreenState extends State<RescuerProfileScreen> {
  bool _isAvailable = true;
  String _name = '';
  String _dept = '';
  bool _loadingProfile = true;
  static const Color kPrimary = Color(0xFF3D5A6C);

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (mounted && doc.exists) {
      final data = doc.data()!;
      setState(() {
        _name = data['name'] ?? '';
        _dept = data['department'] ?? 'قسم العمليات';
        _isAvailable = data['isAvailable'] ?? true;
        _loadingProfile = false;
      });
    } else {
      setState(() => _loadingProfile = false);
    }
  }

  Future<void> _toggleAvailability(bool val) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    setState(() => _isAvailable = val);
    await FirebaseFirestore.instance.collection('users').doc(uid).update({'isAvailable': val});
  }

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
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 12, bottom: 16, right: 20, left: 20),
              child: const Text('الملف الشخصي', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
            Expanded(
              child: _loadingProfile
                  ? const Center(child: CircularProgressIndicator(color: kPrimary))
                  : SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            const SizedBox(height: 16),

                            // بطاقة المستخدم
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: Colors.white, borderRadius: BorderRadius.circular(18),
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
                                  Expanded(child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(_name.isNotEmpty ? _name : 'المنقذ', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                                      const SizedBox(height: 4),
                                      const Text('فريق الإنقاذ', style: TextStyle(fontSize: 13, color: Color(0xFF757575))),
                                      const SizedBox(height: 2),
                                      Text(_dept, style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
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
                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _isAvailable ? const Color(0xFF00D995) : const Color(0xFF9E9E9E)),
                                      ),
                                    ]),
                                    Switch(value: _isAvailable, onChanged: _toggleAvailability, activeColor: const Color(0xFF00D995)),
                                  ],
                                ),
                              ]),
                            ),

                            const SizedBox(height: 16),

                            // إحصائيات من Firestore
                            StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance.collection('reports').snapshots(),
                              builder: (context, snap) {
                                final docs = snap.data?.docs ?? [];
                                final found = docs.where((d) => ['matchFound', 'found', 'resolved', 'closed'].contains((d.data() as Map)['status'])).length;
                                final active = docs.where((d) => ['searching', 'active', 'inProgress'].contains((d.data() as Map)['status'])).length;
                                final total = docs.length;
                                final rate = total == 0 ? 0 : ((found / total) * 100).toInt();

                                return Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white, borderRadius: BorderRadius.circular(18),
                                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Row(children: [
                                        Icon(Icons.bar_chart_rounded, color: kPrimary, size: 18),
                                        SizedBox(width: 6),
                                        Text('الإحصائيات', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                                      ]),
                                      const SizedBox(height: 14),
                                      Row(children: [
                                        _StatBox(value: '$rate%', label: 'نسبة النجاح', color: const Color(0xFF2196F3), icon: Icons.trending_up),
                                        const SizedBox(width: 10),
                                        _StatBox(value: '$found', label: 'مهام مكتملة', color: const Color(0xFF00D995), icon: Icons.check_circle_outline),
                                      ]),
                                      const SizedBox(height: 10),
                                      Row(children: [
                                        _StatBox(value: '$active', label: 'مهام نشطة', color: const Color(0xFF9C27B0), icon: Icons.pending_actions),
                                        const SizedBox(width: 10),
                                        _StatBox(value: '$total', label: 'إجمالي البلاغات', color: const Color(0xFFFF9800), icon: Icons.assignment),
                                      ]),
                                    ],
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 16),

                            // الإعدادات والأمان
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white, borderRadius: BorderRadius.circular(18),
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
                                    icon: Icons.lock_outline, title: 'تغيير كلمة المرور',
                                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordScreen())),
                                  ),
                                  _SettingItem(
                                    icon: Icons.notifications_outlined, title: 'إعدادات التنبيهات',
                                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsSettingsScreen())),
                                  ),
                                  _SettingItem(
                                    icon: Icons.person_outline, title: 'تعديل المعلومات الشخصية',
                                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())).then((_) => _loadProfile()),
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
                                label: const Text('تسجيل الخروج', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFFEF5350))),
                                style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFEF5350)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text('نسخة التطبيق 1.0.0 | جناح', style: TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
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
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) Navigator.pushNamedAndRemoveUntil(context, '/rescuer/login', (route) => false);
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

// تغيير كلمة المرور
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});
  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading = false;
  bool _showCurrent = false, _showNew = false, _showConfirm = false;
  static const Color kPrimary = Color(0xFF3D5A6C);

  @override
  void dispose() { _currentCtrl.dispose(); _newCtrl.dispose(); _confirmCtrl.dispose(); super.dispose(); }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final user = FirebaseAuth.instance.currentUser!;
      final cred = EmailAuthProvider.credential(email: user.email!, password: _currentCtrl.text);
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(_newCtrl.text);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تغيير كلمة المرور بنجاح'), backgroundColor: Color(0xFF00D995)));
      }
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('كلمة المرور الحالية غير صحيحة'), backgroundColor: Colors.red));
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
                  child: _buildCard(children: [
                    const Text('تغيير كلمة المرور', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 20),
                    _passField(_currentCtrl, 'كلمة المرور الحالية', _showCurrent, () => setState(() => _showCurrent = !_showCurrent), (v) => (v == null || v.isEmpty) ? 'هذا الحقل مطلوب' : null),
                    const SizedBox(height: 16),
                    _passField(_newCtrl, 'كلمة المرور الجديدة', _showNew, () => setState(() => _showNew = !_showNew), (v) { if (v == null || v.isEmpty) return 'هذا الحقل مطلوب'; if (v.length < 6) return 'يجب أن تكون 6 أحرف على الأقل'; return null; }),
                    const SizedBox(height: 16),
                    _passField(_confirmCtrl, 'تأكيد كلمة المرور', _showConfirm, () => setState(() => _showConfirm = !_showConfirm), (v) { if (v == null || v.isEmpty) return 'هذا الحقل مطلوب'; if (v != _newCtrl.text) return 'كلمة المرور غير متطابقة'; return null; }),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity, height: 52,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _changePassword,
                        style: ElevatedButton.styleFrom(backgroundColor: kPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        child: _loading ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('حفظ كلمة المرور', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                      ),
                    ),
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
      controller: ctrl, obscureText: !show, textAlign: TextAlign.right,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: IconButton(icon: Icon(show ? Icons.visibility_off : Icons.visibility, color: const Color(0xFF9E9E9E)), onPressed: toggle),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF3D5A6C), width: 2)),
        filled: true, fillColor: const Color(0xFFF9F9F9),
      ),
      validator: validator,
    );
  }
}

// تعديل المعلومات
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _loading = true;
  static const Color kPrimary = Color(0xFF3D5A6C);

  @override
  void initState() { super.initState(); _loadData(); }

  @override
  void dispose() { _nameCtrl.dispose(); _phoneCtrl.dispose(); super.dispose(); }

  Future<void> _loadData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) { setState(() => _loading = false); return; }
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (mounted && doc.exists) {
      final data = doc.data()!;
      _nameCtrl.text = data['name'] ?? '';
      _phoneCtrl.text = data['phone'] ?? '';
      setState(() => _loading = false);
    } else { setState(() => _loading = false); }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'name': _nameCtrl.text.trim(),
          'phone': _phoneCtrl.text.trim(),
        });
      }
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حفظ المعلومات بنجاح'), backgroundColor: Color(0xFF00D995)));
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
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: kPrimary))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: _buildCard(children: [
                          const Text('المعلومات الشخصية', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 20),
                          _field(_nameCtrl, 'الاسم الكامل', Icons.person_outline),
                          const SizedBox(height: 14),
                          _field(_phoneCtrl, 'رقم الجوال', Icons.phone_outlined, isPhone: true),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity, height: 52,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _save,
                              style: ElevatedButton.styleFrom(backgroundColor: kPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                              child: const Text('حفظ المعلومات', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                            ),
                          ),
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
      controller: ctrl, textAlign: TextAlign.right,
      keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
      textDirection: isPhone ? TextDirection.ltr : TextDirection.rtl,
      decoration: InputDecoration(
        labelText: label, prefixIcon: Icon(icon, color: const Color(0xFF9E9E9E)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF3D5A6C), width: 2)),
        filled: true, fillColor: const Color(0xFFF9F9F9),
      ),
      validator: (v) => (v == null || v.isEmpty) ? 'هذا الحقل مطلوب' : null,
    );
  }
}

// إعدادات التنبيهات
class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});
  @override
  State<NotificationsSettingsScreen> createState() => _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState extends State<NotificationsSettingsScreen> {
  bool _newMissions = true, _updates = true, _sound = true, _vibration = true;
  static const Color kPrimary = Color(0xFF3D5A6C);
  static const Color kGreen = Color(0xFF00D995);

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
                    const Text('أنواع التنبيهات', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 14),
                    _toggle('مهام جديدة', 'إشعار عند تعيين مهمة جديدة', _newMissions, (v) => setState(() => _newMissions = v)),
                    const Divider(height: 20),
                    _toggle('تحديثات المهمة', 'إشعار عند تحديث حالة المهمة', _updates, (v) => setState(() => _updates = v)),
                  ]),
                  const SizedBox(height: 16),
                  _buildCard(children: [
                    const Text('الصوت والاهتزاز', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 14),
                    _toggle('الصوت', 'تشغيل صوت التنبيهات', _sound, (v) => setState(() => _sound = v)),
                    const Divider(height: 20),
                    _toggle('الاهتزاز', 'تفعيل الاهتزاز عند التنبيه', _vibration, (v) => setState(() => _vibration = v)),
                  ]),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity, height: 52,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(backgroundColor: kPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: const Text('إغلاق', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
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

  Widget _toggle(String title, String sub, bool val, ValueChanged<bool> onChange) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(sub, style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
        ])),
        Switch(value: val, onChanged: onChange, activeColor: kGreen),
      ],
    );
  }
}

// Helpers
Widget _buildHeader(BuildContext context, String title) {
  return Container(
    width: double.infinity, color: const Color(0xFF3D5A6C),
    padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 8, bottom: 16, right: 8, left: 16),
    child: Row(children: [
      IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back, color: Colors.white, size: 22), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
      Expanded(child: Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white))),
      const SizedBox(width: 32),
    ]),
  );
}

Widget _buildCard({required List<Widget> children}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white, borderRadius: BorderRadius.circular(16),
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
        decoration: BoxDecoration(border: isLast ? null : const Border(bottom: BorderSide(color: Color(0xFFF0F0F0)))),
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

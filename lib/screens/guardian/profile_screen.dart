import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  String? _profileImagePath;

  final _nameController = TextEditingController(text: 'أحمد محمد');
  final _phoneController = TextEditingController(text: '0512345678');
  final _emailController = TextEditingController(text: 'ahmed@example.com');
  final _emergencyPhoneController = TextEditingController(text: '0509876543');

  // إعدادات التنبيهات
  bool _notifySearch = true;
  bool _notifyFound = true;
  bool _notifyUpdate = true;
  bool _notifyGeneral = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    setState(() => _isEditing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم حفظ التعديلات بنجاح'), backgroundColor: Color(0xFF00D995)),
    );
  }

  void _showChangePasswordDialog() {
    final _oldPassController = TextEditingController();
    final _newPassController = TextEditingController();
    final _confirmPassController = TextEditingController();
    bool _obscureOld = true;
    bool _obscureNew = true;
    bool _obscureConfirm = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('تغيير كلمة المرور', style: TextStyle(fontWeight: FontWeight.w700)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _oldPassController,
                  obscureText: _obscureOld,
                  decoration: InputDecoration(
                    labelText: 'كلمة المرور الحالية',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureOld ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setDialogState(() => _obscureOld = !_obscureOld),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _newPassController,
                  obscureText: _obscureNew,
                  decoration: InputDecoration(
                    labelText: 'كلمة المرور الجديدة',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureNew ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setDialogState(() => _obscureNew = !_obscureNew),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _confirmPassController,
                  obscureText: _obscureConfirm,
                  decoration: InputDecoration(
                    labelText: 'تأكيد كلمة المرور',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setDialogState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء', style: TextStyle(color: Color(0xFF757575))),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_newPassController.text != _confirmPassController.text) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('كلمة المرور غير متطابقة'), backgroundColor: Colors.red),
                    );
                    return;
                  }
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم تغيير كلمة المرور بنجاح'), backgroundColor: Color(0xFF00D995)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3D5A6C),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('حفظ', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotificationsDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('إعدادات التنبيهات', style: TextStyle(fontWeight: FontWeight.w700)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildNotifToggle(
                  'تنبيهات بدء البحث',
                  'عند إطلاق عملية البحث',
                  Icons.flight_takeoff,
                  _notifySearch,
                  (v) => setDialogState(() => _notifySearch = v),
                ),
                const Divider(),
                _buildNotifToggle(
                  'تنبيهات العثور على الطفل',
                  'عند العثور على الطفل',
                  Icons.check_circle_outline,
                  _notifyFound,
                  (v) => setDialogState(() => _notifyFound = v),
                ),
                const Divider(),
                _buildNotifToggle(
                  'تنبيهات تحديث الموقع',
                  'عند تحديث موقع البحث',
                  Icons.location_on_outlined,
                  _notifyUpdate,
                  (v) => setDialogState(() => _notifyUpdate = v),
                ),
                const Divider(),
                _buildNotifToggle(
                  'التنبيهات العامة',
                  'إشعارات عامة من التطبيق',
                  Icons.notifications_outlined,
                  _notifyGeneral,
                  (v) => setDialogState(() => _notifyGeneral = v),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  setState(() {});
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم حفظ إعدادات التنبيهات'), backgroundColor: Color(0xFF00D995)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3D5A6C),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('حفظ', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotifToggle(String title, String subtitle, IconData icon, bool value, Function(bool) onChanged) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF3D5A6C), size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF00D995),
        ),
      ],
    );
  }

  void _pickImage() {
    // في التطبيق الحقيقي استخدم image_picker
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('سيتم فتح معرض الصور'), backgroundColor: Color(0xFF3D5A6C)),
    );
  }

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
                // Header
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
                      if (!_isEditing)
                        Positioned(
                          right: 16,
                          top: 20,
                          child: TextButton(
                            onPressed: () => setState(() => _isEditing = true),
                            child: const Text('تعديل', style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      if (_isEditing)
                        Positioned(
                          right: 16,
                          top: 20,
                          child: TextButton(
                            onPressed: _saveChanges,
                            child: const Text('حفظ', style: TextStyle(fontSize: 14, color: Color(0xFF00D995), fontWeight: FontWeight.w600)),
                          ),
                        ),
                      const Center(
                        child: Text('الملف الشخصي', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // صورة الملف الشخصي
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
                    ),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: _isEditing ? _pickImage : null,
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: const Color(0xFFE0E0E0),
                                backgroundImage: _profileImagePath != null ? AssetImage(_profileImagePath!) : null,
                                child: _profileImagePath == null
                                    ? const Icon(Icons.person, size: 50, color: Color(0xFF757575))
                                    : null,
                              ),
                              if (_isEditing)
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: _pickImage,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: const BoxDecoration(color: Color(0xFF3D5A6C), shape: BoxShape.circle),
                                      child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (_isEditing) ...[
                          const SizedBox(height: 12),
                          TextButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.photo_library, color: Color(0xFF3D5A6C)),
                            label: const Text('تغيير الصورة', style: TextStyle(color: Color(0xFF3D5A6C), fontWeight: FontWeight.w600)),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Text(_nameController.text, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        const Text('ولي أمر', style: TextStyle(fontSize: 14, color: Color(0xFF757575))),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // المعلومات الشخصية
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('المعلومات الشخصية', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 16),
                        _buildInfoField(icon: Icons.person_outline, label: 'الاسم الكامل', controller: _nameController),
                        const SizedBox(height: 16),
                        _buildInfoField(icon: Icons.phone_outlined, label: 'رقم الجوال', controller: _phoneController),
                        const SizedBox(height: 16),
                        _buildInfoField(icon: Icons.email_outlined, label: 'البريد الإلكتروني', controller: _emailController),
                        const SizedBox(height: 16),
                        _buildInfoField(icon: Icons.phone_outlined, label: 'رقم جوال الطوارئ', controller: _emergencyPhoneController, isLast: true),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // الإعدادات
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
                    ),
                    child: Column(
                      children: [
                        _buildSettingItem(icon: Icons.lock_outline, title: 'تغيير كلمة المرور', onTap: _showChangePasswordDialog),
                        _buildSettingItem(icon: Icons.notifications_outlined, title: 'إعدادات التنبيهات', onTap: _showNotificationsDialog),
                        _buildSettingItem(icon: Icons.help_outline, title: 'الدعم', onTap: () => Navigator.of(context).pushNamed('/guardian/support')),
                        _buildSettingItem(icon: Icons.info_outline, title: 'عن جناح', onTap: () => Navigator.of(context).pushNamed('/guardian/about'), isLast: true),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // زر تسجيل الخروج
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton.icon(
                      onPressed: () => _showLogoutDialog(context),
                      icon: const Icon(Icons.logout, color: Color(0xFFEF5350)),
                      label: const Text('تسجيل الخروج', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFFEF5350))),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFEF5350)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                const Text('نسخة التطبيق 1.0.0', style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoField({required IconData icon, required String label, required TextEditingController controller, bool isLast = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E), fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: _isEditing,
          textAlign: TextAlign.right,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFF757575)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
            disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFF5F5F5))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF3D5A6C), width: 2)),
            filled: true,
            fillColor: _isEditing ? const Color(0xFFF9F9F9) : const Color(0xFFF5F5F5),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingItem({required IconData icon, required String title, required VoidCallback onTap, bool isLast = false}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: isLast ? null : const Border(bottom: BorderSide(color: Color(0xFFE0E0E0))),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF3D5A6C)),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
            const Icon(Icons.arrow_forward, size: 20, color: Color(0xFF9E9E9E)),
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
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamedAndRemoveUntil(context, '/guardian/login', (route) => false);
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

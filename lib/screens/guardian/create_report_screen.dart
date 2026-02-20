import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CreateReportScreen extends StatefulWidget {
  const CreateReportScreen({super.key});

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _childNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _guardianNameController = TextEditingController();
  final _guardianPhoneController = TextEditingController();

  String? _selectedImage;
  DateTime? _selectedDateTime;
  bool _isLoading = false;

  @override
  void dispose() {
    _childNameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _guardianNameController.dispose();
    _guardianPhoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _selectedImage = image.path);
    }
  }

  Future<void> _selectDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 7)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF3D5A6C),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xFF3D5A6C),
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _submitReport() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الرجاء إضافة صورة للطفل')),
        );
        return;
      }
      if (_selectedDateTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الرجاء تحديد وقت الاختفاء')),
        );
        return;
      }

      setState(() => _isLoading = true);
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إرسال البلاغ بنجاح'),
            backgroundColor: Color(0xFF00D995),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4EFEB), // ✅ اللون الجديد
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF3D5A6C), Color(0xFF4A7B91)],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'إنشاء بلاغ جديد',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon:
                          const Icon(Icons.arrow_forward, color: Colors.white),
                    ),
                  ],
                ),
              ),

              // Form
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('بيانات الطفل'),
                        const SizedBox(height: 16),

                        _buildLabel('اسم الطفل'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _childNameController,
                          hint: 'أدخل اسم الطفل الكامل',
                          icon: Icons.person_outline,
                        ),
                        const SizedBox(height: 16),

                        _buildLabel('الوصف'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _descriptionController,
                          hint: 'وصف الطفل، لون الملابس، العلامات المميزة',
                          icon: Icons.description_outlined,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 20),

                        _buildSectionTitle('صورة الطفل'),
                        const SizedBox(height: 16),
                        _buildImagePicker(),
                        const SizedBox(height: 20),

                        _buildSectionTitle('معلومات الاختفاء'),
                        const SizedBox(height: 16),

                        _buildLabel('آخر موقع شوهد فيه'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _locationController,
                          hint: 'أدخل الموقع أو اختر من الخريطة',
                          icon: Icons.location_on_outlined,
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.map),
                            onPressed: () {},
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE3F2FD),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 16,
                                color: Color(0xFF2196F3),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'تحديد الموقع من الخريطة',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF2196F3),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        _buildLabel('وقت الاختفاء'),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: _selectDateTime,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: const Color(0xFFE0E0E0)),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.access_time,
                                  color: Color(0xFF757575),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _selectedDateTime != null
                                        ? '${_selectedDateTime!.day}/${_selectedDateTime!.month}/${_selectedDateTime!.year} - ${_selectedDateTime!.hour}:${_selectedDateTime!.minute.toString().padLeft(2, '0')}'
                                        : 'اختر التاريخ والوقت',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: _selectedDateTime != null
                                          ? const Color(0xFF2D2D2D)
                                          : const Color(0xFF9E9E9E),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        _buildSectionTitle('بيانات ولي الأمر'),
                        const SizedBox(height: 16),

                        _buildLabel('اسم ولي الأمر'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _guardianNameController,
                          hint: 'الاسم الكامل',
                          icon: Icons.person_outline,
                        ),
                        const SizedBox(height: 16),

                        _buildLabel('رقم الجوال'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _guardianPhoneController,
                          hint: '+966 50 XXX XXXX',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 24),

                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF9E6),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: const Color(0xFFFFE082)),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: Color(0xFFF57C00),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  '⚠️ من صحة جميع المعلومات قبل إرسال البلاغ. سيتم إرسال إشعار لفريق البحث والإنقاذ فوراً',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFFF57C00),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submitReport,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3D5A6C),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : const Text(
                                    'إرسال البلاغ',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                  color: Color(0xFF3D5A6C)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'إلغاء',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF3D5A6C),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        textAlign: TextAlign.right,
        decoration: InputDecoration(
          hintText: hint,
          hintTextDirection: TextDirection.rtl,
          prefixIcon: Icon(icon),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'هذا الحقل مطلوب';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildImagePicker() {
    return InkWell(
      onTap: _pickImage,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE0E0E0),
            style: BorderStyle.solid,
            width: 2,
          ),
        ),
        child: _selectedImage != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: const Center(
                  child: Icon(
                    Icons.check_circle,
                    color: Color(0xFF00D995),
                    size: 48,
                  ),
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3D5A6C).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add_photo_alternate,
                      size: 40,
                      color: Color(0xFF3D5A6C),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'اضغط لرفع صورة حديثة للطفل',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF757575),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'مطلوب لتحليل التعرف على الوجه',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9E9E9E),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

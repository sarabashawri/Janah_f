import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'dart:convert';

class RescuerCreateReportScreen extends StatefulWidget {
  const RescuerCreateReportScreen({super.key});

  @override
  State<RescuerCreateReportScreen> createState() => _RescuerCreateReportScreenState();
}

class _RescuerCreateReportScreenState extends State<RescuerCreateReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _childNameController = TextEditingController();
  final _extraDescController = TextEditingController();
  final _locationController = TextEditingController();
  final _guardianNameController = TextEditingController();
  final _guardianPhoneController = TextEditingController();

  XFile? _selectedImage;
  DateTime? _selectedDateTime;
  LatLng? _selectedLocation;
  bool _isLoading = false;
  String? _selectedClothingColor;

  static const Color kPrimary = Color(0xFF3D5A6C);
  static const Color kGreen  = Color(0xFF00D995);

  static const List<Map<String, dynamic>> _clothingColors = [
    {'label': 'أبيض',    'color': Color(0xFFFFFFFF), 'border': true},
    {'label': 'أسود',    'color': Color(0xFF212121), 'border': false},
    {'label': 'أحمر',    'color': Color(0xFFEF5350), 'border': false},
    {'label': 'أزرق',    'color': Color(0xFF1E88E5), 'border': false},
    {'label': 'أخضر',    'color': Color(0xFF43A047), 'border': false},
    {'label': 'أصفر',    'color': Color(0xFFFFEB3B), 'border': true},
    {'label': 'برتقالي', 'color': Color(0xFFFF7043), 'border': false},
    {'label': 'بنفسجي', 'color': Color(0xFF8E24AA), 'border': false},
    {'label': 'بني',     'color': Color(0xFF6D4C41), 'border': false},
    {'label': 'رمادي',   'color': Color(0xFF9E9E9E), 'border': false},
    {'label': 'وردي',    'color': Color(0xFFE91E63), 'border': false},
    {'label': 'كحلي',    'color': Color(0xFF1A237E), 'border': false},
  ];

  @override
  void dispose() {
    _childNameController.dispose();
    _extraDescController.dispose();
    _locationController.dispose();
    _guardianNameController.dispose();
    _guardianPhoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (image != null) setState(() => _selectedImage = image);
  }

  Future<void> _selectDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 7)),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: kPrimary)),
        child: child!,
      ),
    );
    if (pickedDate != null && mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) => Theme(
          data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: kPrimary)),
          child: child!,
        ),
      );
      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(pickedDate.year, pickedDate.month, pickedDate.day, pickedTime.hour, pickedTime.minute);
        });
      }
    }
  }

  Future<void> _openMapPicker() async {
    LatLng initialPos = const LatLng(24.7136, 46.6753);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        LocationPermission perm = await Geolocator.checkPermission();
        if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
        if (perm == LocationPermission.whileInUse || perm == LocationPermission.always) {
          final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
          initialPos = LatLng(pos.latitude, pos.longitude);
        }
      }
    } catch (_) {}
    if (!mounted) return;
    final result = await showModalBottomSheet<LatLng>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _MapPickerSheet(initialPos: initialPos),
    );
    if (result != null) {
      setState(() {
        _selectedLocation = result;
        _locationController.text = '${result.latitude.toStringAsFixed(5)}, ${result.longitude.toStringAsFixed(5)}';
      });
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red : kGreen,
    ));
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImage == null) { _showSnack('الرجاء إضافة صورة للطفل', isError: true); return; }
    if (_selectedClothingColor == null) { _showSnack('الرجاء اختيار لون الملابس', isError: true); return; }
    if (_selectedDateTime == null) { _showSnack('الرجاء تحديد وقت الاختفاء', isError: true); return; }
    if (_selectedLocation == null) { _showSnack('الرجاء تحديد موقع آخر مشاهدة', isError: true); return; }

    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('غير مسجل الدخول');
      String? imageBase64;
      if (_selectedImage != null) {
        final bytes = await File(_selectedImage!.path).readAsBytes();
        imageBase64 = base64Encode(bytes);
      }
      await FirebaseFirestore.instance.collection('reports').add({
        'rescuerId': user.uid,
        'guardianName': _guardianNameController.text.trim(),
        'guardianPhone': _guardianPhoneController.text.trim(),
        'childName': _childNameController.text.trim(),
        'clothingColor': _selectedClothingColor,
        'extraDescription': _extraDescController.text.trim(),
        'location': _locationController.text.trim(),
        'latitude': _selectedLocation!.latitude,
        'longitude': _selectedLocation!.longitude,
        'disappearanceTime': _selectedDateTime!.toIso8601String(),
        'imageBase64': imageBase64,
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': 'rescuer',
      });
      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.of(context).pop();
        _showSnack('تم إرسال البلاغ بنجاح');
      }
    } catch (e) {
      if (mounted) { setState(() => _isLoading = false); _showSnack('خطأ: $e', isError: true); }
    }
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
              color: kPrimary,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8,
                bottom: 16, right: 8, left: 16,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const Expanded(
                    child: Text('رفع بلاغ جديد',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                  const SizedBox(width: 32),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // ── تنبيه ──
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF9E6),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFFE082)),
                        ),
                        child: const Row(children: [
                          Icon(Icons.info_outline, color: Color(0xFFF57C00), size: 20),
                          SizedBox(width: 10),
                          Expanded(child: Text(
                            'يرجى التأكد من صحة جميع البيانات قبل إرسال البلاغ. سيتم إشعار فريق الإنقاذ ونظام الدرون فوراً.',
                            style: TextStyle(fontSize: 12, color: Color(0xFFF57C00)),
                          )),
                        ]),
                      ),

                      const SizedBox(height: 16),

                      // ── كارد 1: معلومات أساسية مطلوبة ──
                      _buildCard(
                        icon: Icons.person_outline,
                        title: 'معلومات أساسية مطلوبة',
                        children: [
                          _buildLabel('اسم الطفل'),
                          const SizedBox(height: 8),
                          _buildTextField(controller: _childNameController, hint: 'أدخل الاسم الكامل', icon: Icons.person_outline),
                          const SizedBox(height: 16),
                          _buildLabel('صورة الطفل'),
                          const SizedBox(height: 8),
                          _buildImagePicker(),
                          const SizedBox(height: 16),
                          _buildLabel('لون الملابس العلوية'),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _clothingColors.map((c) {
                              final isSelected = _selectedClothingColor == c['label'];
                              return GestureDetector(
                                onTap: () => setState(() => _selectedClothingColor = c['label'] as String),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected ? kPrimary : Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected ? kPrimary : const Color(0xFFE0E0E0),
                                      width: isSelected ? 2 : 1,
                                    ),
                                    boxShadow: isSelected ? [BoxShadow(color: kPrimary.withOpacity(0.2), blurRadius: 6)] : [],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 16, height: 16,
                                        decoration: BoxDecoration(
                                          color: c['color'] as Color,
                                          shape: BoxShape.circle,
                                          border: (c['border'] as bool) ? Border.all(color: const Color(0xFFE0E0E0)) : null,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(c['label'] as String,
                                          style: TextStyle(
                                            fontSize: 13, fontWeight: FontWeight.w600,
                                            color: isSelected ? Colors.white : const Color(0xFF2D2D2D),
                                          )),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          if (_selectedClothingColor != null) ...[
                            const SizedBox(height: 8),
                            Row(children: [
                              const Icon(Icons.check_circle, color: kGreen, size: 16),
                              const SizedBox(width: 6),
                              Text('تم اختيار: $_selectedClothingColor',
                                  style: const TextStyle(fontSize: 12, color: kGreen, fontWeight: FontWeight.w600)),
                            ]),
                          ],
                        ],
                      ),

                      const SizedBox(height: 16),

                      // ── كارد 2: وصف إضافي ──
                      _buildCard(
                        icon: Icons.description_outlined,
                        title: 'وصف إضافي',
                        children: [
                          const Text(
                            'أي تفاصيل تساعد في البحث مثل: يرتدي قبعة، واقف عند لعبة الأرجوحة، شعره قصير...',
                            style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _extraDescController,
                            maxLines: 4,
                            textAlign: TextAlign.right,
                            decoration: InputDecoration(
                              hintText: 'مثال: يرتدي قبعة زرقاء، كان يلعب عند مدخل الحديقة، معه حقيبة صغيرة...',
                              hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
                              hintTextDirection: TextDirection.rtl,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kPrimary, width: 2)),
                              filled: true,
                              fillColor: const Color(0xFFF9F9F9),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // ── كارد 3: الموقع والوقت ──
                      _buildCard(
                        icon: Icons.location_on_outlined,
                        title: 'معلومات الموقع والوقت',
                        children: [
                          _buildLabel('آخر موقع مشاهدة'),
                          const SizedBox(height: 8),
                          Row(children: [
                            Expanded(
                              child: TextFormField(
                                controller: _locationController,
                                readOnly: true,
                                textAlign: TextAlign.right,
                                decoration: InputDecoration(
                                  hintText: 'مثال: حي الربوة، شارع الملك فيد',
                                  hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
                                  hintTextDirection: TextDirection.rtl,
                                  prefixIcon: const Icon(Icons.location_on_outlined),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
                                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kPrimary, width: 2)),
                                  filled: true,
                                  fillColor: const Color(0xFFF9F9F9),
                                ),
                                validator: (v) => (v == null || v.isEmpty) ? 'الرجاء تحديد الموقع' : null,
                              ),
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: _openMapPicker,
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(color: kPrimary, borderRadius: BorderRadius.circular(12)),
                                child: const Icon(Icons.map, color: Colors.white, size: 26),
                              ),
                            ),
                          ]),
                          if (_selectedLocation != null) ...[
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: SizedBox(
                                height: 160,
                                child: GoogleMap(
                                  initialCameraPosition: CameraPosition(target: _selectedLocation!, zoom: 15),
                                  markers: {Marker(markerId: const MarkerId('selected'), position: _selectedLocation!)},
                                  zoomControlsEnabled: false,
                                  scrollGesturesEnabled: false,
                                  rotateGesturesEnabled: false,
                                  tiltGesturesEnabled: false,
                                  zoomGesturesEnabled: false,
                                  myLocationButtonEnabled: false,
                                  liteModeEnabled: true,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 14),
                          _buildLabel('وقت الاختفاء'),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: _selectDateTime,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9F9F9),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE0E0E0)),
                              ),
                              child: Row(children: [
                                const Icon(Icons.access_time, color: Color(0xFF757575)),
                                const SizedBox(width: 12),
                                Expanded(child: Text(
                                  _selectedDateTime != null
                                      ? '${_selectedDateTime!.day}/${_selectedDateTime!.month}/${_selectedDateTime!.year} - ${_selectedDateTime!.hour}:${_selectedDateTime!.minute.toString().padLeft(2, '0')}'
                                      : 'تاريخ الاختفاء',
                                  style: TextStyle(fontSize: 14,
                                      color: _selectedDateTime != null ? const Color(0xFF2D2D2D) : const Color(0xFF9E9E9E)),
                                )),
                                const Icon(Icons.calendar_today, color: Color(0xFF757575), size: 20),
                              ]),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // ── كارد 4: بيانات ولي الأمر ──
                      _buildCard(
                        icon: Icons.person_outline,
                        title: 'بيانات ولي الأمر',
                        children: [
                          _buildLabel('اسم ولي الأمر'),
                          const SizedBox(height: 8),
                          _buildTextField(controller: _guardianNameController, hint: 'الاسم الكامل', icon: Icons.person_outline),
                          const SizedBox(height: 14),
                          _buildLabel('رقم الجوال'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _guardianPhoneController,
                            keyboardType: TextInputType.phone,
                            textDirection: TextDirection.ltr,
                            textAlign: TextAlign.right,
                            decoration: InputDecoration(
                              hintText: '+966 5X XXX XXXX',
                              hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)),
                              prefixIcon: const Icon(Icons.phone_outlined),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kPrimary, width: 2)),
                              filled: true,
                              fillColor: const Color(0xFFF9F9F9),
                            ),
                            validator: (v) => (v == null || v.isEmpty) ? 'هذا الحقل مطلوب' : null,
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.phone, color: Colors.white, size: 20),
                              label: const Text('الاتصال بولي الأمر',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kPrimary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _submitReport,
                          icon: _isLoading
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Icon(Icons.upload, color: Colors.white),
                          label: Text(_isLoading ? 'جاري الإرسال...' : 'رفع البلاغ',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: kPrimary),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('إلغاء',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: kPrimary)),
                        ),
                      ),
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

  Widget _buildCard({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: kPrimary, size: 18),
            const SizedBox(width: 6),
            Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildLabel(String label) =>
      Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF2D2D2D)));

  Widget _buildTextField({required TextEditingController controller, required String hint, required IconData icon, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        hintText: hint,
        hintTextDirection: TextDirection.rtl,
        hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)),
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kPrimary, width: 2)),
        filled: true,
        fillColor: const Color(0xFFF9F9F9),
      ),
      validator: (v) => (v == null || v.isEmpty) ? 'هذا الحقل مطلوب' : null,
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _selectedImage != null ? kGreen : const Color(0xFFE0E0E0),
            width: _selectedImage != null ? 2 : 1,
          ),
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _selectedImage != null ? kGreen.withOpacity(0.1) : kPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_selectedImage != null ? Icons.check_circle : Icons.add_photo_alternate,
                color: _selectedImage != null ? kGreen : kPrimary, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_selectedImage != null ? 'تم اختيار الصورة' : 'اضغط لإضافة صورة',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                    color: _selectedImage != null ? kGreen : const Color(0xFF2D2D2D))),
            const SizedBox(height: 2),
            Text(_selectedImage != null ? _selectedImage!.name : 'JPG, PNG (حد أقصى 5MB)',
                style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E)), overflow: TextOverflow.ellipsis),
          ])),
          if (_selectedImage != null)
            GestureDetector(
              onTap: () => setState(() => _selectedImage = null),
              child: const Icon(Icons.close, color: Color(0xFF9E9E9E), size: 20),
            ),
        ]),
      ),
    );
  }
}

// ── شيت الخريطة ──
class _MapPickerSheet extends StatefulWidget {
  final LatLng initialPos;
  const _MapPickerSheet({required this.initialPos});
  @override
  State<_MapPickerSheet> createState() => _MapPickerSheetState();
}

class _MapPickerSheetState extends State<_MapPickerSheet> {
  late LatLng _pickedLocation;
  GoogleMapController? _mapController;
  bool _loadingLocation = false;

  @override
  void initState() {
    super.initState();
    _pickedLocation = widget.initialPos;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        ),
        child: Column(children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40, height: 4,
            decoration: BoxDecoration(color: const Color(0xFFE0E0E0), borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('تحديد الموقع', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ]),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('اضغط على الخريطة لتحديد آخر موقع شوهد فيه الطفل',
                style: TextStyle(fontSize: 13, color: Color(0xFF757575))),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Stack(children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(target: widget.initialPos, zoom: 15),
                onMapCreated: (c) => _mapController = c,
                onTap: (pos) => setState(() => _pickedLocation = pos),
                markers: {
                  Marker(
                    markerId: const MarkerId('pick'),
                    position: _pickedLocation,
                    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                  ),
                },
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                zoomControlsEnabled: true,
              ),
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 36),
                  child: Icon(Icons.location_pin, color: Color(0xFFEF5350), size: 40),
                ),
              ),
              Positioned(
                bottom: 16, left: 16,
                child: GestureDetector(
                  onTap: () async {
                    setState(() => _loadingLocation = true);
                    try {
                      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.medium);
                      final myPos = LatLng(pos.latitude, pos.longitude);
                      setState(() { _pickedLocation = myPos; _loadingLocation = false; });
                      _mapController?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: myPos, zoom: 16)));
                    } catch (_) { setState(() => _loadingLocation = false); }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 3))],
                    ),
                    child: _loadingLocation
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF3D5A6C)))
                        : const Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(Icons.my_location, color: Color(0xFF3D5A6C), size: 20),
                            SizedBox(width: 6),
                            Text('موقعي الحالي', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF3D5A6C))),
                          ]),
                  ),
                ),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context, _pickedLocation),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3D5A6C),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.check, color: Colors.white),
                label: const Text('تأكيد الموقع', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

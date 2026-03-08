import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'dart:convert';

class CreateReportScreen extends StatefulWidget {
  const CreateReportScreen({super.key});

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _childNameController = TextEditingController();
  final _extraDescriptionController = TextEditingController();
  final _locationController = TextEditingController();

  XFile? _selectedImage;
  DateTime? _selectedDateTime;
  LatLng? _selectedLocation;
  bool _isLoading = false;
  String? _selectedClothingColor;

  static const Color kPrimary = Color(0xFF3D5A6C);
  static const Color kGreen = Color(0xFF00D995);

  // ألوان الملابس
  static const List<Map<String, dynamic>> _clothingColors = [
    {'label': 'أسود',     'color': Color(0xFF212121)},
    {'label': 'رمادي',    'color': Color(0xFF9E9E9E)},
    {'label': 'أبيض',     'color': Color(0xFFF5F5F5)},
    {'label': 'أحمر',     'color': Color(0xFFEF5350)},
    {'label': 'برتقالي',  'color': Color(0xFFFF7043)},
    {'label': 'أصفر',     'color': Color(0xFFFFEE58)},
    {'label': 'أخضر',     'color': Color(0xFF66BB6A)},
    {'label': 'أزرق',     'color': Color(0xFF42A5F5)},
    {'label': 'بنفسجي',   'color': Color(0xFFAB47BC)},
    {'label': 'وردي',     'color': Color(0xFFEC407A)},
  ];

  @override
  void dispose() {
    _childNameController.dispose();
    _extraDescriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  // ─────────────── الكود الحقيقي لم يتغير ───────────────

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
        _locationController.text =
            '${result.latitude.toStringAsFixed(5)}, ${result.longitude.toStringAsFixed(5)}';
      });
    }
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الرجاء إضافة صورة للطفل'), backgroundColor: Colors.red));
      return;
    }
    if (_selectedClothingColor == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الرجاء اختيار لون الملابس العلوية'), backgroundColor: Colors.red));
      return;
    }
    if (_selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الرجاء تحديد وقت الاختفاء'), backgroundColor: Colors.red));
      return;
    }
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الرجاء تحديد موقع آخر مشاهدة'), backgroundColor: Colors.red));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('غير مسجل الدخول');

      String? imageBase64;
      if (_selectedImage != null) {
        final bytes = await File(_selectedImage!.path).readAsBytes();
        imageBase64 = base64Encode(bytes);
      }

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final guardianName = userDoc.data()?['name'] ?? '';
      final guardianPhone = userDoc.data()?['phone'] ?? '';

      await FirebaseFirestore.instance.collection('reports').add({
        'guardianId': user.uid,
        'guardianName': guardianName,
        'guardianPhone': guardianPhone,
        'childName': _childNameController.text.trim(),
        'clothingColor': _selectedClothingColor,
        'description': _extraDescriptionController.text.trim(),
        'location': _locationController.text.trim(),
        'latitude': _selectedLocation!.latitude,
        'longitude': _selectedLocation!.longitude,
        'disappearanceTime': _selectedDateTime!.toIso8601String(),
        'imageBase64': imageBase64,
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // إشعار لفريق الإنقاذ
      await FirebaseFirestore.instance.collection('notifications').add({
        'type': 'newReport',
        'title': 'بلاغ جديد: ${_childNameController.text.trim()}',
        'description': 'تم رفع بلاغ جديد عن طفل مفقود في ${_locationController.text.trim()}',
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إرسال البلاغ بنجاح'), backgroundColor: kGreen),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // ─────────────── UI ───────────────

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4EFEB),
        body: SafeArea(
          child: Column(
            children: [
              // HEADER
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
                    Positioned(
                      right: 16, top: 20,
                      child: IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                      ),
                    ),
                    const Center(
                      child: Text('رفع بلاغ جديد',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // تنبيه علوي
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF9E6),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFFE082)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.info_outline, color: Color(0xFFF57C00), size: 20),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'يرجى التأكد من صحة البيانات قبل إرسال البلاغ. سيتم إشعار فريق الإنقاذ ونظام الدرون فوراً.',
                                  style: TextStyle(fontSize: 12, color: Color(0xFFF57C00)),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ── معلومات أساسية ──
                        _buildCard(
                          icon: Icons.person_outline,
                          title: 'معلومات أساسية مطلوبة',
                          children: [
                            const SizedBox(height: 16),

                            // اسم الطفل
                            _buildLabel('اسم الطفل'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: _childNameController,
                              hint: 'أدخل الاسم الكامل',
                              icon: Icons.person_outline,
                            ),
                            const SizedBox(height: 20),

                            // صورة الطفل
                            _buildLabel('صورة الطفل'),
                            const SizedBox(height: 8),
                            _buildImagePicker(),
                            const SizedBox(height: 20),

                            // لون الملابس العلوية
                            _buildLabel('لون الملابس العلوية'),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: _clothingColors.map((c) {
                                final isSelected = _selectedClothingColor == c['label'];
                                final isWhite = c['label'] == 'أبيض';
                                return GestureDetector(
                                  onTap: () => setState(() => _selectedClothingColor = c['label']),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                    decoration: BoxDecoration(
                                      color: isSelected ? (c['color'] as Color).withOpacity(0.15) : Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isSelected ? c['color'] as Color : const Color(0xFFE0E0E0),
                                        width: isSelected ? 2 : 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 16, height: 16,
                                          decoration: BoxDecoration(
                                            color: c['color'] as Color,
                                            shape: BoxShape.circle,
                                            border: isWhite ? Border.all(color: const Color(0xFFE0E0E0)) : null,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(c['label'] as String,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                              color: const Color(0xFF2D2D2D),
                                            )),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // ── وصف إضافي ──
                        _buildCard(
                          icon: Icons.description_outlined,
                          title: 'وصف إضافي',
                          children: [
                            const SizedBox(height: 8),
                            const Text(
                              'أي تفاصيل تساعد في البحث مثل: يرتدي قبعة، واقف عند لعبة الأراجيح، شعره قصير...',
                              style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E), height: 1.4),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _extraDescriptionController,
                              maxLines: 4,
                              textAlign: TextAlign.right,
                              decoration: InputDecoration(
                                hintText: 'مثال: عمره 7 سنوات تقريباً، يرتدي قبعة زرقاء، كان يلعب عند مدخل الحديقة، معه حقيبة صغيرة...',
                                hintTextDirection: TextDirection.rtl,
                                hintStyle: const TextStyle(fontSize: 12, color: Color(0xFFBDBDBD)),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
                                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kPrimary, width: 2)),
                                filled: true,
                                fillColor: const Color(0xFFF9F9F9),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // ── معلومات الموقع والوقت ──
                        _buildCard(
                          icon: Icons.location_on_outlined,
                          title: 'معلومات الموقع والوقت',
                          children: [
                            const SizedBox(height: 16),

                            _buildLabel('آخر موقع مشاهدة'),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _locationController,
                                    readOnly: true,
                                    textAlign: TextAlign.right,
                                    decoration: InputDecoration(
                                      hintText: 'مثال: حي الربوة، شارع الملك فهد',
                                      hintTextDirection: TextDirection.rtl,
                                      hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)),
                                      prefixIcon: const Icon(Icons.location_on_outlined),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
                                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
                                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kPrimary, width: 2)),
                                      filled: true, fillColor: const Color(0xFFF9F9F9),
                                    ),
                                    validator: (v) => (v == null || v.isEmpty) ? 'الرجاء تحديد الموقع' : null,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                InkWell(
                                  onTap: _openMapPicker,
                                  child: Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(color: kPrimary, borderRadius: BorderRadius.circular(12)),
                                    child: const Icon(Icons.map, color: Colors.white, size: 26),
                                  ),
                                ),
                              ],
                            ),

                            if (_selectedLocation != null) ...[
                              const SizedBox(height: 12),
                              Container(
                                height: 120,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: kGreen, width: 2),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
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

                            const SizedBox(height: 16),

                            _buildLabel('وقت الاختفاء'),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: _selectDateTime,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF9F9F9),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFE0E0E0)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.access_time, color: Color(0xFF757575)),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        _selectedDateTime != null
                                            ? '${_selectedDateTime!.day}/${_selectedDateTime!.month}/${_selectedDateTime!.year} - ${_selectedDateTime!.hour}:${_selectedDateTime!.minute.toString().padLeft(2, '0')}'
                                            : 'تاريخ الاختفاء',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: _selectedDateTime != null ? const Color(0xFF2D2D2D) : const Color(0xFF9E9E9E),
                                        ),
                                      ),
                                    ),
                                    const Icon(Icons.calendar_today, color: Color(0xFF757575), size: 20),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // زر الإرسال
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _submitReport,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            icon: _isLoading
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Icon(Icons.upload_outlined, color: Colors.white),
                            label: const Text('رفع البلاغ',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: kPrimary),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('إلغاء',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: kPrimary)),
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
      ),
    );
  }

  Widget _buildCard({required String title, required List<Widget> children, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: kPrimary, size: 18),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          ]),
          ...children,
        ],
      ),
    );
  }

  Widget _buildLabel(String label) =>
      Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600));

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        hintText: hint,
        hintTextDirection: TextDirection.rtl,
        hintStyle: const TextStyle(fontSize: 13),
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kPrimary, width: 2)),
        filled: true, fillColor: const Color(0xFFF9F9F9),
      ),
      validator: (v) => (v == null || v.isEmpty) ? 'هذا الحقل مطلوب' : null,
    );
  }

  Widget _buildImagePicker() {
    return InkWell(
      onTap: _pickImage,
      borderRadius: BorderRadius.circular(12),
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
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _selectedImage != null ? kGreen.withOpacity(0.1) : kPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _selectedImage != null ? Icons.check_circle : Icons.add_photo_alternate,
                color: _selectedImage != null ? kGreen : kPrimary,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedImage != null ? 'تم اختيار الصورة' : 'اضغط لإضافة صورة',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                        color: _selectedImage != null ? kGreen : const Color(0xFF2D2D2D)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _selectedImage != null ? _selectedImage!.name : 'JPG, PNG (حد أقصى 5MB)',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (_selectedImage != null)
              IconButton(
                icon: const Icon(Icons.close, color: Color(0xFF9E9E9E), size: 20),
                onPressed: () => setState(() => _selectedImage = null),
              ),
          ],
        ),
      ),
    );
  }
}

// ── شيت الخريطة - لم يتغير ──
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
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40, height: 4,
              decoration: BoxDecoration(color: const Color(0xFFE0E0E0), borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('تحديد الموقع', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('اضغط على الخريطة لتحديد آخر موقع شوهد فيه الطفل',
                  style: TextStyle(fontSize: 13, color: Color(0xFF757575))),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Stack(
                children: [
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
                          bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
                          if (!serviceEnabled) { setState(() => _loadingLocation = false); return; }
                          LocationPermission perm = await Geolocator.checkPermission();
                          if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
                          if (perm == LocationPermission.deniedForever) { setState(() => _loadingLocation = false); return; }
                          final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.medium, timeLimit: const Duration(seconds: 10));
                          final myPos = LatLng(pos.latitude, pos.longitude);
                          setState(() { _pickedLocation = myPos; _loadingLocation = false; });
                          _mapController?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: myPos, zoom: 16)));
                        } catch (e) {
                          setState(() => _loadingLocation = false);
                          try {
                            final last = await Geolocator.getLastKnownPosition();
                            if (last != null) {
                              final myPos = LatLng(last.latitude, last.longitude);
                              setState(() => _pickedLocation = myPos);
                              _mapController?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: myPos, zoom: 16)));
                            }
                          } catch (_) {}
                        }
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
                            : const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.my_location, color: Color(0xFF3D5A6C), size: 20),
                                  SizedBox(width: 6),
                                  Text('موقعي الحالي', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF3D5A6C))),
                                ],
                              ),
                      ),
                    ),
                  ),
                ],
              ),
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
                  label: const Text('تأكيد الموقع',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

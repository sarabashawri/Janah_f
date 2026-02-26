import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';

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

  XFile? _selectedImage;
  DateTime? _selectedDateTime;
  LatLng? _selectedLocation;
  bool _isLoading = false;

  static const Color kPrimary = Color(0xFF3D5A6C);
  static const Color kGreen = Color(0xFF00D995);

  @override
  void dispose() {
    _childNameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
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
    // الحصول على الموقع الحالي
    LatLng initialPos = const LatLng(24.7136, 46.6753); // الرياض
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        LocationPermission perm = await Geolocator.checkPermission();
        if (perm == LocationPermission.denied) {
          perm = await Geolocator.requestPermission();
        }
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
    if (_selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الرجاء تحديد وقت الاختفاء'), backgroundColor: Colors.red));
      return;
    }
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الرجاء تحديد موقع آخر مشاهدة'), backgroundColor: Colors.red));
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إرسال البلاغ بنجاح'), backgroundColor: kGreen),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4EFEB),
        body: SafeArea(
          child: Column(
            children: [
              // Header
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
                      right: 16,
                      top: 20,
                      child: IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                      ),
                    ),
                    const Center(
                      child: Text('إنشاء بلاغ جديد', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // ── بيانات الطفل ──
                        _buildCard(children: [
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
                        ]),

                        const SizedBox(height: 20),

                        // ── صورة الطفل ──
                        _buildCard(children: [
                          _buildSectionTitle('صورة الطفل'),
                          const SizedBox(height: 16),
                          _buildImagePicker(),
                        ]),

                        const SizedBox(height: 20),

                        // ── معلومات الاختفاء ──
                        _buildCard(children: [
                          _buildSectionTitle('معلومات الاختفاء'),
                          const SizedBox(height: 16),

                          _buildLabel('آخر موقع شوهد فيه'),
                          const SizedBox(height: 8),
                          // حقل الموقع + زر الخريطة
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _locationController,
                                  readOnly: true,
                                  textAlign: TextAlign.right,
                                  decoration: InputDecoration(
                                    hintText: 'اضغط لتحديد الموقع على الخريطة',
                                    hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)),
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
                              InkWell(
                                onTap: _openMapPicker,
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: kPrimary,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.map, color: Colors.white, size: 26),
                                ),
                              ),
                            ],
                          ),

                          // معاينة صغيرة للموقع المختار
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
                                  markers: {
                                    Marker(markerId: const MarkerId('selected'), position: _selectedLocation!),
                                  },
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
                                          : 'اختر التاريخ والوقت',
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
                        ]),

                        const SizedBox(height: 20),

                        // تنبيه
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF9E6),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFFE082)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.warning_amber_rounded, color: Color(0xFFF57C00)),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'تأكد من صحة جميع المعلومات قبل إرسال البلاغ. سيتم إرسال إشعار لفريق البحث والإنقاذ فوراً',
                                  style: TextStyle(fontSize: 12, color: Color(0xFFF57C00)),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // أزرار
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submitReport,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text('إرسال البلاغ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: kPrimary),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('إلغاء', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: kPrimary)),
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

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _buildSectionTitle(String title) =>
      Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700));

  Widget _buildLabel(String label) =>
      Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600));

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        hintText: hint,
        hintTextDirection: TextDirection.rtl,
        hintStyle: const TextStyle(fontSize: 13),
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF3D5A6C), width: 2)),
        filled: true,
        fillColor: const Color(0xFFF9F9F9),
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
                color: _selectedImage != null ? kGreen.withOpacity(0.1) : const Color(0xFF3D5A6C).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _selectedImage != null ? Icons.check_circle : Icons.add_photo_alternate,
                color: _selectedImage != null ? kGreen : const Color(0xFF3D5A6C),
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedImage != null ? 'تم اختيار الصورة' : 'اضغط لرفع صورة للطفل',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _selectedImage != null ? kGreen : const Color(0xFF2D2D2D),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _selectedImage != null ? _selectedImage!.name : 'مطلوب لتحليل التعرف على الوجه',
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
            // هاندل
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: const Color(0xFFE0E0E0), borderRadius: BorderRadius.circular(2)),
            ),
            // عنوان
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('تحديد الموقع', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('اضغط على الخريطة لتحديد آخر موقع شوهد فيه الطفل',
                  style: TextStyle(fontSize: 13, color: Color(0xFF757575))),
            ),
            const SizedBox(height: 12),
            // الخريطة
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
                  // إشارة تحديد في الوسط
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 36),
                      child: Icon(Icons.location_pin, color: Color(0xFFEF5350), size: 40),
                    ),
                  ),
                  // زر موقعي الحالي
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: GestureDetector(
                      onTap: () async {
                        try {
                          bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
                          if (!serviceEnabled) return;

                          LocationPermission perm = await Geolocator.checkPermission();
                          if (perm == LocationPermission.denied) {
                            perm = await Geolocator.requestPermission();
                          }
                          if (perm == LocationPermission.deniedForever) return;

                          final pos = await Geolocator.getCurrentPosition(
                            desiredAccuracy: LocationAccuracy.high,
                          );
                          final myPos = LatLng(pos.latitude, pos.longitude);
                          setState(() => _pickedLocation = myPos);
                          _mapController?.animateCamera(
                            CameraUpdate.newCameraPosition(
                              CameraPosition(target: myPos, zoom: 16),
                            ),
                          );
                        } catch (_) {}
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.my_location, color: Color(0xFF3D5A6C), size: 20),
                            SizedBox(width: 6),
                            Text(
                              'موقعي الحالي',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF3D5A6C),
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
            // زر تأكيد
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
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
          ],
        ),
      ),
    );
  }
}

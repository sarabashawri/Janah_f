import 'package:flutter/material.dart';

class MissionControlScreen extends StatefulWidget {
  final String reportId;
  const MissionControlScreen({super.key, required this.reportId});

  @override
  State<MissionControlScreen> createState() => _MissionControlScreenState();
}

class _MissionControlScreenState extends State<MissionControlScreen> {
  bool _missionStarted = false;
  bool _showDroneInput = false;
  final TextEditingController _droneCommandController = TextEditingController();

  static const Color _navy = Color(0xFF3D5A6C);
  static const Color _green = Color(0xFF16C47F);
  static const Color _bg = Color(0xFFF4EFEB);

  @override
  void dispose() {
    _droneCommandController.dispose();
    super.dispose();
  }

  void _startMission() {
    setState(() {
      _missionStarted = true;
      _showDroneInput = true;
    });
  }

  void _sendCommand() {
    if (_droneCommandController.text.trim().isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم إرسال الأمر: ${_droneCommandController.text.trim()}'),
        backgroundColor: _green,
        duration: const Duration(seconds: 2),
      ),
    );
    _droneCommandController.clear();
    setState(() => _showDroneInput = false);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _bg,
        body: Column(
          children: [
            // ── HEADER ──
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2E4A5A), _navy],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
              ),
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 10,
                bottom: 16,
                right: 8,
                left: 16,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  Expanded(
                    child: Text(
                      'التحكم بالمهمة ${widget.reportId}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 32),
                ],
              ),
            ),

            Expanded(
              child: _missionStarted ? _buildActiveState() : _buildReadyState(),
            ),
          ],
        ),
      ),
    );
  }

  // ── حالة جاهز للبدء ──
  Widget _buildReadyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 6))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _navy.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.radar, color: _navy, size: 52),
              ),
              const SizedBox(height: 20),
              const Text(
                'جاهز للبدء',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF2D2D2D)),
              ),
              const SizedBox(height: 8),
              const Text(
                'اضغط على الزر أدناه لبدء المهمة',
                style: TextStyle(fontSize: 14, color: Color(0xFF757575)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _startMission,
                  icon: const Icon(Icons.bolt, color: Colors.white, size: 22),
                  label: const Text(
                    'بدء المهمة',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── حالة المهمة نشطة ──
  Widget _buildActiveState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 8),

          // ── بادج المهمة نشطة ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            decoration: BoxDecoration(
              color: _green,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.circle, color: Colors.white, size: 10),
                    SizedBox(width: 8),
                    Text('جارية الآن', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
                Text(
                  'المهمة نشطة',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── نافذة أوامر الدرون ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // عنوان + زر إغلاق
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('أوامر الدرون', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                    if (_showDroneInput)
                      GestureDetector(
                        onTap: () => setState(() {
                          _showDroneInput = false;
                          _droneCommandController.clear();
                        }),
                        child: const Icon(Icons.close, color: Color(0xFF9E9E9E), size: 22),
                      )
                    else
                      GestureDetector(
                        onTap: () => setState(() => _showDroneInput = true),
                        child: const Icon(Icons.add_circle_outline, color: _navy, size: 22),
                      ),
                  ],
                ),

                if (_showDroneInput) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'اكتب الأمر الذي تريد إرساله للدرون',
                    style: TextStyle(fontSize: 12, color: Color(0xFF757575)),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _droneCommandController,
                    maxLines: 3,
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      hintText: 'مثال: توسيع نطاق البحث، العودة للقاعدة، التركيز على منطقة محددة...',
                      hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
                      hintTextDirection: TextDirection.rtl,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: _navy, width: 2),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF9F9F9),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 46,
                          child: OutlinedButton(
                            onPressed: () => setState(() {
                              _showDroneInput = false;
                              _droneCommandController.clear();
                            }),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFE0E0E0)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('إلغاء', style: TextStyle(color: Color(0xFF757575), fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          height: 46,
                          child: ElevatedButton(
                            onPressed: _sendCommand,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _navy,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            child: const Text('إرسال الأمر', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => setState(() => _showDroneInput = true),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: _navy.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _navy.withOpacity(0.2)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send, color: _navy, size: 18),
                          SizedBox(width: 8),
                          Text('إرسال أمر جديد', style: TextStyle(color: _navy, fontWeight: FontWeight.w700, fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── زر المتابعة إلى التفاصيل ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Column(
              children: [
                const Text(
                  'يمكنك المتابعة إلى صفحة تفاصيل البلاغ لمتابعة سير المهمة',
                  style: TextStyle(fontSize: 12, color: Color(0xFF757575)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _navy,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text(
                      'المتابعة إلى التفاصيل',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

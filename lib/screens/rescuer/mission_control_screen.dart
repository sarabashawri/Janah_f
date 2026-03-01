import 'package:flutter/material.dart';
import 'mission_details_screen.dart';
import 'Verification_screen.dart';

class MissionControlScreen extends StatefulWidget {
  final String reportId;
  final bool startActive;
  const MissionControlScreen({super.key, required this.reportId, this.startActive = false});

  @override
  State<MissionControlScreen> createState() => _MissionControlScreenState();
}

class _MissionControlScreenState extends State<MissionControlScreen> {
  late bool _missionStarted;
  bool _showDroneInput = false;
  final TextEditingController _droneCommandController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();
  final List<_ChatMessage> _chatMessages = [];

  static const Color _navy  = Color(0xFF3D5A6C);
  static const Color _green = Color(0xFF16C47F);
  static const Color _red   = Color(0xFFEF5350);
  static const Color _bg    = Color(0xFFF4EFEB);

  @override
  void initState() {
    super.initState();
    _missionStarted = widget.startActive;
    if (_missionStarted) {
      _chatMessages.add(_ChatMessage(text: '🤖 الدرون جاهز واستقبل أمر البدء، يبدأ المسح الآن...', isBot: true));
    }
  }

  @override
  void dispose() {
    _droneCommandController.dispose();
    _chatScrollController.dispose();
    super.dispose();
  }

  void _startMission() {
    setState(() {
      _missionStarted = true;
      _chatMessages.add(_ChatMessage(text: '🤖 الدرون جاهز واستقبل أمر البدء، يبدأ المسح الآن...', isBot: true));
    });
  }

  void _sendCommand() {
    final text = _droneCommandController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _chatMessages.add(_ChatMessage(text: text, isBot: false));
      _droneCommandController.clear();
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() {
        _chatMessages.add(_ChatMessage(text: '✅ تم استقبال الأمر وتنفيذه', isBot: true));
      });
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_chatScrollController.hasClients) {
          _chatScrollController.animateTo(
            _chatScrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _emergencyLanding() {
    showDialog(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Row(children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFEF5350), size: 26),
            SizedBox(width: 8),
            Text('هبوط طارئ', style: TextStyle(color: Color(0xFFEF5350), fontWeight: FontWeight.w800)),
          ]),
          content: const Text('سيتم إصدار أمر هبوط طارئ فوري للدرون. هل أنت متأكد؟',
              style: TextStyle(fontSize: 14)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _chatMessages.add(_ChatMessage(text: '🚨 صدر أمر هبوط طارئ! الدرون يهبط الآن...', isBot: true));
                });
                Future.delayed(const Duration(milliseconds: 100), () {
                  if (_chatScrollController.hasClients) {
                    _chatScrollController.animateTo(
                      _chatScrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                });
              },
              style: ElevatedButton.styleFrom(backgroundColor: _red,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('تأكيد الهبوط', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  // بيانات المهمة الحالية
  MissionData get _missionData => missionsMap[widget.reportId] ?? missionsMap['#1234']!;

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
                bottom: 16, right: 8, left: 16,
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
                    child: Text('التحكم بالمهمة ${widget.reportId}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
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

  // ── جاهز للبدء ──
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
                decoration: BoxDecoration(color: _navy.withOpacity(0.08), shape: BoxShape.circle),
                child: const Icon(Icons.radar, color: _navy, size: 52),
              ),
              const SizedBox(height: 20),
              const Text('جاهز للبدء',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF2D2D2D))),
              const SizedBox(height: 8),
              const Text('اضغط على الزر أدناه لبدء المهمة',
                  style: TextStyle(fontSize: 14, color: Color(0xFF757575)), textAlign: TextAlign.center),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity, height: 54,
                child: ElevatedButton.icon(
                  onPressed: _startMission,
                  icon: const Icon(Icons.bolt, color: Colors.white, size: 22),
                  label: const Text('بدء المهمة',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
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

  // ── حالة نشطة ──
  Widget _buildActiveState() {
    final data = _missionData;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 8),

          // بادج المهمة نشطة
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            decoration: BoxDecoration(color: _green, borderRadius: BorderRadius.circular(16)),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('المهمة نشطة', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                Row(children: [
                  Text('جارية الآن', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                  SizedBox(width: 8),
                  Icon(Icons.circle, color: Colors.white, size: 10),
                ]),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── شات مع الدرون ──
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Column(
              children: [
                // هيدر الشات
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: _navy.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.flight, color: _navy, size: 20),
                    ),
                    const SizedBox(width: 10),
                    const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('شات مع الدرون', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                      Text('DR-01 • متصل', style: TextStyle(fontSize: 11, color: Color(0xFF00D995))),
                    ]),
                  ]),
                ),
                const Divider(height: 1),
                // رسائل الشات
                SizedBox(
                  height: 220,
                  child: _chatMessages.isEmpty
                      ? const Center(
                          child: Text('لا توجد رسائل بعد', style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 13)))
                      : ListView.builder(
                          controller: _chatScrollController,
                          padding: const EdgeInsets.all(12),
                          itemCount: _chatMessages.length,
                          itemBuilder: (_, i) => _buildChatBubble(_chatMessages[i]),
                        ),
                ),
                const Divider(height: 1),
                // حقل الإرسال
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(children: [
                    Expanded(
                      child: TextField(
                        controller: _droneCommandController,
                        textAlign: TextAlign.right,
                        decoration: InputDecoration(
                          hintText: 'اكتب أمراً للدرون...',
                          hintTextDirection: TextDirection.rtl,
                          hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: const BorderSide(color: _navy, width: 2)),
                          filled: true, fillColor: const Color(0xFFF9F9F9),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          isDense: true,
                        ),
                        onSubmitted: (_) => _sendCommand(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _sendCommand,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: _navy, shape: BoxShape.circle),
                        child: const Icon(Icons.send, color: Colors.white, size: 20),
                      ),
                    ),
                  ]),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── لقطات من الكاميرا ──
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(children: [
                  Icon(Icons.videocam_outlined, color: _navy, size: 18),
                  SizedBox(width: 8),
                  Text('لقطات من الكاميرا', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                ]),
                const SizedBox(height: 14),
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: const [
                    _CameraThumb(time: '18:14:40'),
                    _CameraThumb(time: '18:13:35'),
                    _CameraThumb(time: '18:16:50'),
                    _CameraThumb(time: '18:15:45'),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── نقاط الاشتباه ──
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(children: [
                  Icon(Icons.warning_amber_rounded, color: Color(0xFFFFB300), size: 18),
                  SizedBox(width: 8),
                  Text('نقاط الاشتباه', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                ]),
                const SizedBox(height: 14),
                data.points.isEmpty
                    ? const Center(child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Text('لا توجد نقاط اشتباه حتى الآن',
                            style: TextStyle(color: Color(0xFF9E9E9E))),
                      ))
                    : Column(
                        children: data.points.map((p) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _SuspiciousPointCard(
                            point: p,
                            onTap: () => Navigator.push(context, MaterialPageRoute(
                              builder: (_) => VerificationScreen(reportId: data.reportId, pointNumber: p.number),
                            )),
                          ),
                        )).toList(),
                      ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── هبوط طارئ ──
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _emergencyLanding,
              icon: const Icon(Icons.emergency_outlined, color: Colors.white, size: 22),
              label: const Text('هبوط طارئ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── المتابعة إلى التفاصيل ──
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
              child: const Text('المتابعة إلى التفاصيل',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildChatBubble(_ChatMessage msg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: msg.isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          if (msg.isBot) ...[
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(color: _navy.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.flight, color: _navy, size: 14),
            ),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: msg.isBot ? const Color(0xFFF0F4F7) : _navy,
                borderRadius: BorderRadius.only(
                  topRight: const Radius.circular(16),
                  topLeft: const Radius.circular(16),
                  bottomRight: msg.isBot ? const Radius.circular(16) : const Radius.circular(4),
                  bottomLeft: msg.isBot ? const Radius.circular(4) : const Radius.circular(16),
                ),
              ),
              child: Text(msg.text,
                  style: TextStyle(
                    fontSize: 13,
                    color: msg.isBot ? const Color(0xFF2D2D2D) : Colors.white,
                  )),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isBot;
  _ChatMessage({required this.text, required this.isBot});
}

// ── لقطات الكاميرا ──
class _CameraThumb extends StatelessWidget {
  const _CameraThumb({required this.time});
  final String time;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        color: const Color(0xFFE0E0E0),
        child: Stack(children: [
          Center(child: Icon(Icons.camera_alt_outlined, size: 34, color: Colors.grey.shade600)),
          Positioned(
            bottom: 10, left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.55),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(children: [
                const Icon(Icons.camera_alt, size: 12, color: Colors.white),
                const SizedBox(width: 6),
                Text(time, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}

// ── كارد نقطة الاشتباه ──
class _SuspiciousPointCard extends StatelessWidget {
  const _SuspiciousPointCard({required this.point, required this.onTap});
  final SuspiciousPoint point;
  final VoidCallback onTap;

  bool get isBad => point.status.trim() == 'غير مطابق';
  Color get bg => isBad ? const Color(0xFFFFEBEE) : const Color(0xFFFFF8E1);
  Color get border => isBad ? const Color(0xFFEF5350) : const Color(0xFFFFD54F);
  Color get badge => isBad ? const Color(0xFFEF5350) : const Color(0xFFFFB300);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border, width: 1.6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Text('نقطة اشتباه #${point.number}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900))),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: badge, borderRadius: BorderRadius.circular(18)),
                child: Text(point.status,
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(point.time, style: const TextStyle(fontSize: 12, color: Color(0xFF757575))),
          const SizedBox(height: 6),
          Row(children: [
            const Icon(Icons.location_on, size: 14, color: Color(0xFFEF5350)),
            const SizedBox(width: 6),
            Expanded(child: Text(point.location,
                style: const TextStyle(fontSize: 12, color: Color(0xFF757575)))),
            const SizedBox(width: 8),
            InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Text('عرض والتحقق',
                    style: TextStyle(color: Color(0xFF3D5A6C), fontWeight: FontWeight.w900, fontSize: 12)),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward_ios, size: 12, color: Color(0xFF3D5A6C)),
              ]),
            ),
          ]),
        ],
      ),
    );
  }
}

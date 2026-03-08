import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'Verification_screen.dart';

// ← غيري هذا الـ IP لـ IP الكمبيوتر اللي يشتغل عليه TypeFly
const String _TYPEFLY_IP = '192.168.8.75';
const String _TYPEFLY_URL = 'http://$_TYPEFLY_IP:50000';

class MissionControlScreen extends StatefulWidget {
  final String reportId;
  final bool startActive;
  const MissionControlScreen({super.key, required this.reportId, this.startActive = false});

  @override
  State<MissionControlScreen> createState() => _MissionControlScreenState();
}

class _MissionControlScreenState extends State<MissionControlScreen> {
  late bool _missionStarted;
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
      _chatMessages.add(_ChatMessage(text: '🤖 مرحباً، أنا جناح. تم تفعيل نظام البحث والإنقاذ. جاهز لاستقبال أوامرك، كيف يمكنني المساعدة؟', isBot: true));
    }
  }

  @override
  void dispose() {
    _droneCommandController.dispose();
    _chatScrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
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

  void _startMission() {
    setState(() {
      _missionStarted = true;
      _chatMessages.add(_ChatMessage(text: '🤖 مرحباً، أنا جناح. تم تفعيل نظام البحث والإنقاذ. جاهز لاستقبال أوامرك، كيف يمكنني المساعدة؟', isBot: true));
    });
  }

  void _sendQuick(String text) {
    setState(() => _chatMessages.add(_ChatMessage(text: text, isBot: false)));
    _scrollToBottom();
    _sendToTypefly(text);
  }

  void _sendCommand() {
    final text = _droneCommandController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _chatMessages.add(_ChatMessage(text: text, isBot: false));
      _droneCommandController.clear();
    });
    _scrollToBottom();
    _sendToTypefly(text);
  }

  Future<void> _sendToTypefly(String command) async {
    try {
      final response = await http.post(
        Uri.parse('$_TYPEFLY_URL/api/command'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': command, 'reportId': widget.reportId}),
      ).timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (response.statusCode == 200) {
        // الرد سيجي من Firebase تلقائياً عبر StreamBuilder
      } else {
        setState(() => _chatMessages.add(_ChatMessage(
          text: '⚠️ تعذر الاتصال بالدرون',
          isBot: true,
        )));
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _chatMessages.add(_ChatMessage(
        text: '❌ لا يوجد اتصال بالدرون - تأكدي أن TypeFly يعمل على الكمبيوتر',
        isBot: true,
      )));
    }
    _scrollToBottom();
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
          content: const Text('سيتم إصدار أمر هبوط طارئ فوري للدرون. هل أنت متأكد؟', style: TextStyle(fontSize: 14)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() => _chatMessages.add(_ChatMessage(text: '🚨 صدر أمر هبوط طارئ! الدرون يهبط الآن...', isBot: true)));
                _scrollToBottom();
              },
              style: ElevatedButton.styleFrom(backgroundColor: _red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('تأكيد الهبوط', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _bg,
        body: Column(
          children: [
            // HEADER
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFF2E4A5A), _navy], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
              ),
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, bottom: 16, right: 8, left: 16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
                    padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                  ),
                  Expanded(
                    child: Text('التحكم بالمهمة', textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                  ),
                  const SizedBox(width: 32),
                ],
              ),
            ),
            Expanded(child: _missionStarted ? _buildActiveState() : _buildReadyState()),
          ],
        ),
      ),
    );
  }

  Widget _buildReadyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(22),
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
              const Text('جاهز للبدء', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF2D2D2D))),
              const SizedBox(height: 8),
              const Text('اضغط على الزر أدناه لبدء المهمة', style: TextStyle(fontSize: 14, color: Color(0xFF757575)), textAlign: TextAlign.center),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity, height: 54,
                child: ElevatedButton.icon(
                  onPressed: _startMission,
                  icon: const Icon(Icons.bolt, color: Colors.white, size: 22),
                  label: const Text('بدء المهمة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: _green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveState() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('reports').doc(widget.reportId).snapshots(),
      builder: (context, snap) {
        final data = snap.data?.data() as Map<String, dynamic>? ?? {};
        final childName = data['childName'] ?? '';

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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(childName.isNotEmpty ? 'مهمة: $childName' : 'المهمة نشطة',
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                    const Row(children: [
                      Text('جارية الآن', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                      SizedBox(width: 8),
                      Icon(Icons.circle, color: Colors.white, size: 10),
                    ]),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // هبوط طارئ
              SizedBox(
                width: double.infinity, height: 60,
                child: ElevatedButton.icon(
                  onPressed: _emergencyLanding,
                  icon: const Icon(Icons.emergency_outlined, color: Colors.white, size: 24),
                  label: const Text('هبوط طارئ', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1)),
                  style: ElevatedButton.styleFrom(backgroundColor: _red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), padding: const EdgeInsets.symmetric(vertical: 14), elevation: 0),
                ),
              ),

              const SizedBox(height: 16),

              // شات مع الدرون
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Column(
                  children: [
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
                          Text('جناح - نظام البحث والإنقاذ', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                          Text('متصل', style: TextStyle(fontSize: 11, color: Color(0xFF00D995))),
                        ]),
                      ]),
                    ),
                    const Divider(height: 1),
                    SizedBox(
                      height: 220,
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('mission_messages')
                            .where('reportId', isEqualTo: widget.reportId)
                            .orderBy('createdAt')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return const Center(
                              child: Text('لا توجد رسائل بعد', style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 13)),
                            );
                          }
                          final docs = snapshot.data!.docs;
                          WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                          return ListView.builder(
                            controller: _chatScrollController,
                            padding: const EdgeInsets.all(12),
                            itemCount: docs.length,
                            itemBuilder: (_, i) {
                              final data = docs[i].data() as Map<String, dynamic>;
                              return _buildChatBubble(_ChatMessage(
                                text: data['text'] ?? '',
                                isBot: data['isBot'] ?? false,
                              ));
                            },
                          );
                        },
                      ),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                      child: Wrap(
                        spacing: 8, runSpacing: 6,
                        children: [
                          _QuickChip(label: 'ماذا ترى؟', onTap: () => _sendQuick('ماذا ترى؟')),
                          _QuickChip(label: 'تحرك للأمام', onTap: () => _sendQuick('تحرك للأمام')),
                          _QuickChip(label: 'التقط صورة الآن', onTap: () => _sendQuick('التقط صورة الآن')),
                          _QuickChip(label: 'عد للقاعدة', onTap: () => _sendQuick('عد للقاعدة')),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
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

              // بث مباشر
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(children: [
                      Icon(Icons.videocam, color: _navy, size: 18),
                      SizedBox(width: 8),
                      Text('بث مباشر من الدرون', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      Spacer(),
                      _LiveBadge(),
                    ]),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: double.infinity, height: 200,
                        color: const Color(0xFF1A1A2E),
                        child: Stack(children: [
                          Center(child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.videocam, color: Colors.white.withOpacity(0.3), size: 48),
                              const SizedBox(height: 8),
                              Text('جناح • جاري البث', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
                            ],
                          )),
                          Positioned(top: 10, right: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: _red, borderRadius: BorderRadius.circular(6)),
                              child: const Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
                            ),
                          ),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // زر المتابعة للتفاصيل
              SizedBox(
                width: double.infinity, height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: _navy, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                  child: const Text('المتابعة إلى التفاصيل', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChatBubble(_ChatMessage msg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: msg.isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          if (msg.isBot) ...[
            Container(width: 28, height: 28, decoration: BoxDecoration(color: _navy.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.flight, color: _navy, size: 14)),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: msg.isBot ? const Color(0xFFF0F4F7) : _navy,
                borderRadius: BorderRadius.only(
                  topRight: const Radius.circular(16), topLeft: const Radius.circular(16),
                  bottomRight: msg.isBot ? const Radius.circular(16) : const Radius.circular(4),
                  bottomLeft: msg.isBot ? const Radius.circular(4) : const Radius.circular(16),
                ),
              ),
              child: Text(msg.text, style: TextStyle(fontSize: 13, color: msg.isBot ? const Color(0xFF2D2D2D) : Colors.white)),
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

class _SuspiciousPointCard extends StatelessWidget {
  const _SuspiciousPointCard({required this.point, required this.onTap});
  final dynamic point;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1), borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFD54F), width: 1.6),
      ),
      child: Row(children: [
        Expanded(child: Text('نقطة اشتباه', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900))),
        InkWell(
          onTap: onTap,
          child: const Row(mainAxisSize: MainAxisSize.min, children: [
            Text('عرض والتحقق', style: TextStyle(color: Color(0xFF3D5A6C), fontWeight: FontWeight.w900, fontSize: 12)),
            SizedBox(width: 4),
            Icon(Icons.arrow_forward_ios, size: 12, color: Color(0xFF3D5A6C)),
          ]),
        ),
      ]),
    );
  }
}

class _QuickChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _QuickChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF3D5A6C).withOpacity(0.08), borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF3D5A6C).withOpacity(0.25)),
        ),
        child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF3D5A6C))),
      ),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: const Color(0xFFEF5350), borderRadius: BorderRadius.circular(6)),
      child: const Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.circle, color: Colors.white, size: 6),
        SizedBox(width: 4),
        Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
      ]),
    );
  }
}

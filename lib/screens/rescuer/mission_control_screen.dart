import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:janah_complete/services/flask_api_service.dart';
import 'package:janah_complete/screens/rescuer/Verification_screen.dart';

// ─── Setup Phase ──────────────────────────────────────────────────────────────
enum _SetupPhase { idle, checking, uploading, polling, ready, error }

// ─── Video Source ─────────────────────────────────────────────────────────────
enum VideoSource { laptop, tello }

class MissionControlScreen extends StatefulWidget {
  final String reportId;
  final bool startActive;
  const MissionControlScreen({
    super.key,
    required this.reportId,
    this.startActive = false,
  });

  @override
  State<MissionControlScreen> createState() => _MissionControlScreenState();
}

class _MissionControlScreenState extends State<MissionControlScreen>
    with SingleTickerProviderStateMixin {
  _SetupPhase _setupPhase = _SetupPhase.idle;
  String _errorMessage = '';
  int _pollSeconds = 0;
  bool _isSending = false;
  bool _missionApproved = false;
  VideoSource _videoSource = VideoSource.laptop;
  final List<_SuspiciousPoint> _suspiciousPoints = [];
  final List<_LocalImageMessage> _localImageMessages = [];
  Uint8List? _latestFrame;
  StreamSubscription<Map<String, dynamic>>? _alertSub;
  late TabController _tabController;
  static final List<_SuspiciousPoint> _cache = [];

  final TextEditingController _droneCommandController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();

  static const Color _navy  = Color(0xFF3D5A6C);
  static const Color _green = Color(0xFF16C47F);
  static const Color _red   = Color(0xFFEF5350);
  static const Color _bg    = Color(0xFFF4EFEB);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    if (_cache.isNotEmpty) _suspiciousPoints.addAll(_cache);
    if (widget.startActive) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _checkAndInitMission());
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _alertSub?.cancel();
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

  // ─── Check if mission already started → skip setup if so ─────────────────
  Future<void> _checkAndInitMission() async {
    if (!mounted || widget.reportId.isEmpty) {
      _initializeMission();
      return;
    }
    try {
      final doc = await FirebaseFirestore.instance
          .collection('reports')
          .doc(widget.reportId)
          .get();
      final status = doc.data()?['status'] as String? ?? '';
      if (status == 'searching' || status == 'inProgress') {
        // Mission already approved — reconnect stream directly
        if (mounted) {
          setState(() {
            _missionApproved = true;
            _setupPhase = _SetupPhase.ready;
          });
          _startAlertStream();
        }
        return;
      }
    } catch (_) {}
    _initializeMission();
  }

  // ─── Phase 1 + 2 — Initialize Mission ────────────────────────────────────
  Future<void> _initializeMission() async {
    if (!mounted) return;
    _cache.clear();
    setState(() => _suspiciousPoints.clear());

    // Phase 1 — Health Check
    setState(() => _setupPhase = _SetupPhase.checking);
    final healthy = await FlaskApiService.isHealthy();
    if (!mounted) return;

    if (!healthy) {
      setState(() {
        _setupPhase = _SetupPhase.error;
        _errorMessage = 'خادم جناح غير متصل ❌\nتأكد أن TypeFly يعمل على نفس الشبكة';
      });
      return;
    }

    // Phase 2A — Upload reference photo + metadata
    setState(() => _setupPhase = _SetupPhase.uploading);
    try {
      await FlaskApiService.setupMission(widget.reportId);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _setupPhase = _SetupPhase.error;
        _errorMessage = 'فشل رفع بيانات الطفل:\n$e';
      });
      return;
    }
    if (!mounted) return;

    // Phase 2B — Poll until FaceNet finishes processing embeddings (max 20 min)
    setState(() {
      _setupPhase = _SetupPhase.polling;
      _pollSeconds = 0;
    });
    const maxPollSeconds = 2700; // 45 minutes
    while (mounted && _pollSeconds < maxPollSeconds) {
      final status = await FlaskApiService.getReferenceStatus();
      if (status['setup'] == true) break;
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) setState(() => _pollSeconds += 2);
    }
    if (!mounted) return;

    if (_pollSeconds >= maxPollSeconds) {
      setState(() {
        _setupPhase = _SetupPhase.error;
        _errorMessage = 'انتهت مهلة التهيئة (45 دقيقة)\nتحقق من أداء الخادم وأعد المحاولة';
      });
      return;
    }

    // Update report status to searching in Firebase
    try {
      await FirebaseFirestore.instance
          .collection('reports')
          .doc(widget.reportId)
          .update({'status': 'searching'});
    } catch (_) {
      // Non-critical — continue even if status update fails
    }

    setState(() => _setupPhase = _SetupPhase.ready);
    _showMissionApprovalDialog();
  }

  void _showMissionApprovalDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Row(children: [
            Icon(Icons.check_circle_outline, color: Color(0xFF16C47F), size: 26),
            SizedBox(width: 8),
            Text('تأكيد بدء المهمة', style: TextStyle(fontWeight: FontWeight.w800)),
          ]),
          content: const Text(
            'النظام جاهز. هل تبدأ المهمة؟',
            style: TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() => _setupPhase = _SetupPhase.idle);
              },
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await FlaskApiService.approvePlan();
                  if (mounted) {
                    setState(() => _missionApproved = true);
                    _startAlertStream();
                    await _writeMissionMessage(
                      text: 'تم بدء المهمة ✅',
                      isBot: true,
                      isAlert: false,
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    setState(() {
                      _setupPhase = _SetupPhase.error;
                      _errorMessage = 'فشل إرسال الموافقة للخادم: $e\nتحقق من الاتصال وأعد المحاولة.';
                    });
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16C47F),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('موافق — ابدأ المهمة',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  void _startMission() => _initializeMission();

  // ─── Phase 3 — Send Command ───────────────────────────────────────────────
  Future<void> _sendCommand() async {
    final text = _droneCommandController.text.trim();
    if (text.isEmpty || _isSending) return;

    _droneCommandController.clear();
    setState(() => _isSending = true);

    // Write user message to Firebase
    await _writeMissionMessage(text: text, isBot: false, isAlert: false);

    try {
      await for (final event in FlaskApiService.sendCommand(text)) {
        if (!mounted) break;
        final type = event['type'] as String? ?? 'text';
        final content = event['content'] as String? ?? '';
        if (type == 'text' && content.isNotEmpty) {
          await _writeMissionMessage(text: content, isBot: true, isAlert: false);
        } else if (type == 'alert' && content.isNotEmpty) {
          await _writeMissionMessage(text: content, isBot: true, isAlert: true);
          final cv = event['cv'] as Map<String, dynamic>?;
          if (cv != null && mounted) _handleCvAlert(cv);
        } else if (type == 'image' && content.isNotEmpty) {
          final b64 = content.contains(',') ? content.split(',').last : content;
          try {
            final bytes = base64Decode(b64);
            if (mounted) {
              setState(() {
                _localImageMessages.add(
                  _LocalImageMessage(imageBytes: bytes, createdAt: DateTime.now()),
                );
                _suspiciousPoints.insert(0, _SuspiciousPoint(
                  number: _suspiciousPoints.length + 1,
                  matchScore: 0,
                  colorMatch: false,
                  alertType: 'manual',
                  detectedAt: DateTime.now(),
                  capturedImageBase64: b64,
                ));
              });
            }
          } catch (_) {}
        }
      }
    } catch (e) {
      if (mounted) {
        await _writeMissionMessage(
          text: 'خطأ في الاتصال بالخادم: $e',
          isBot: true,
          isAlert: false,
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _sendQuick(String text) async {
    _droneCommandController.text = text;
    await _sendCommand();
  }

  // ─── Phase 4 — Emergency Landing ─────────────────────────────────────────
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
            Text('هبوط طارئ',
                style: TextStyle(
                    color: Color(0xFFEF5350), fontWeight: FontWeight.w800)),
          ]),
          content: const Text(
            'سيتم إصدار أمر هبوط طارئ فوري للدرون. هل أنت متأكد؟',
            style: TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await FlaskApiService.emergencyLand();
                  if (mounted) {
                    await _writeMissionMessage(
                      text: '🚨 تم إصدار أمر الهبوط الطارئ للدرون',
                      isBot: true,
                      isAlert: false,
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    await _writeMissionMessage(
                      text: 'فشل إرسال أمر الهبوط: $e',
                      isBot: true,
                      isAlert: false,
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _red,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('تأكيد الهبوط',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  // ─── CV Alert Handler (shared by _sendCommand and _startAlertStream) ───────
  void _handleCvAlert(Map<String, dynamic> cv) {
    final img = _latestFrame;
    final snapshotFromCv = cv['snapshot'] as String?;
    final imgB64 = img != null ? base64Encode(img) : snapshotFromCv;

    if (img != null) {
      setState(() => _localImageMessages.add(
        _LocalImageMessage(imageBytes: img, createdAt: DateTime.now()),
      ));
    }

    // Save to Firestore so suspicious points persist if app closes
    if (widget.reportId.isNotEmpty) {
      FirebaseFirestore.instance
          .collection('reports')
          .doc(widget.reportId)
          .collection('suspiciousPoints')
          .add({
        'matchScore': (cv['match_score'] as num?)?.toInt() ?? 0,
        'colorMatch': cv['color_match'] as bool? ?? false,
        'alertType': cv['alert_type'] as String? ?? 'candidate',
        'capturedImageBase64': imgB64 ?? '',
        'status': 'pending',
        'detectedAt': FieldValue.serverTimestamp(),
      });
    }

    setState(() {
      _suspiciousPoints.insert(0, _SuspiciousPoint(
        number: _suspiciousPoints.length + 1,
        matchScore: (cv['match_score'] as num?)?.toInt() ?? 0,
        colorMatch: cv['color_match'] as bool? ?? false,
        alertType: cv['alert_type'] as String? ?? 'candidate',
        detectedAt: DateTime.now(),
        capturedImageBase64: imgB64,
      ));
    });
    _cache..clear()..addAll(_suspiciousPoints);
  }

  // ─── Phase 5 — Alert Stream ───────────────────────────────────────────────
  void _startAlertStream() {
    _alertSub?.cancel();
    _alertSub = FlaskApiService.alertStream().listen(
      (event) async {
        if (!mounted) return;
        final content = event['content'] as String? ?? '';
        final cv = event['cv'] as Map<String, dynamic>?;

        if (content.isNotEmpty) {
          await _writeMissionMessage(
            text: content,
            isBot: true,
            isAlert: true,
          );
        }

        if (cv != null && mounted) {
          _handleCvAlert(cv);
        }
      },
      onError: (_) {
        // alertStream() handles reconnect internally — no action needed
      },
    );
  }

  // ─── Firebase Helper ──────────────────────────────────────────────────────
  Future<void> _writeMissionMessage({
    required String text,
    required bool isBot,
    required bool isAlert,
  }) async {
    await FirebaseFirestore.instance.collection('mission_messages').add({
      'reportId': widget.reportId,
      'text': text,
      'isBot': isBot,
      'isAlert': isAlert,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ─── Build ─────────────────────────────────────────────────────────────────
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
                gradient: LinearGradient(
                  colors: [Color(0xFF2E4A5A), _navy],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(22)),
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
                    icon: const Icon(Icons.arrow_back,
                        color: Colors.white, size: 22),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  Expanded(
                    child: Text(
                      'التحكم بالمهمة',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 32),
                ],
              ),
            ),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_setupPhase) {
      case _SetupPhase.idle:
        return _buildReadyState();
      case _SetupPhase.checking:
        return _buildLoadingState('جارٍ التحقق من الاتصال...');
      case _SetupPhase.uploading:
        return _buildLoadingState('جارٍ رفع بيانات الطفل...');
      case _SetupPhase.polling:
        final mins = _pollSeconds ~/ 60;
        final secs = (_pollSeconds % 60).toString().padLeft(2, '0');
        return _buildLoadingState(
            'جارٍ تهيئة نظام التعرف على الوجه...\n$mins:$secs / 45:00 دقيقة');
      case _SetupPhase.ready:
        return _buildActiveState();
      case _SetupPhase.error:
        return _buildErrorState();
    }
  }

  // ─── Idle — Start screen ───────────────────────────────────────────────────
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
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 6))
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                    color: _navy.withOpacity(0.08), shape: BoxShape.circle),
                child: const Icon(Icons.radar, color: _navy, size: 52),
              ),
              const SizedBox(height: 20),
              const Text('جاهز للبدء',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2D2D2D))),
              const SizedBox(height: 8),
              const Text(
                'اضغط على الزر أدناه لبدء المهمة',
                style: TextStyle(fontSize: 14, color: Color(0xFF757575)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // ── Video Source Selector ─────────────────────────────
              Align(
                alignment: Alignment.centerRight,
                child: Text('مصدر الكاميرا',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700])),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _SourceCard(
                      icon: Icons.laptop,
                      label: 'محاكاة',
                      sublabel: 'كاميرا اللابتوب',
                      selected: _videoSource == VideoSource.laptop,
                      onTap: () => setState(() => _videoSource = VideoSource.laptop),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _SourceCard(
                      icon: Icons.flight,
                      label: 'مهمة حقيقية',
                      sublabel: 'Tello Drone',
                      selected: _videoSource == VideoSource.tello,
                      onTap: () => setState(() => _videoSource = VideoSource.tello),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _startMission,
                  icon: const Icon(Icons.bolt, color: Colors.white, size: 22),
                  label: const Text('بدء المهمة',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _green,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
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

  // ─── Loading — Phase progress ──────────────────────────────────────────────
  Widget _buildLoadingState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 6))
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: _navy, strokeWidth: 3),
              const SizedBox(height: 20),
              Text(
                message,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2D2D2D)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Error — Retry screen ──────────────────────────────────────────────────
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 6))
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: _red.withOpacity(0.08), shape: BoxShape.circle),
                child: const Icon(Icons.wifi_off_rounded, color: _red, size: 48),
              ),
              const SizedBox(height: 20),
              Text(
                _errorMessage,
                style: const TextStyle(fontSize: 14, color: Color(0xFF2D2D2D)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _initializeMission,
                  icon:
                      const Icon(Icons.refresh, color: Colors.white, size: 20),
                  label: const Text('إعادة المحاولة',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _navy,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
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

  // ─── Active Mission ────────────────────────────────────────────────────────
  Widget _buildActiveState() {
    final isReady = _setupPhase == _SetupPhase.ready;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('reports')
          .doc(widget.reportId)
          .snapshots(),
      builder: (context, snap) {
        final data = snap.data?.data() as Map<String, dynamic>? ?? {};
        final childName = data['childName'] ?? '';

        return Column(
          children: [
            // ── Mission active badge ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                decoration: BoxDecoration(
                    color: _green, borderRadius: BorderRadius.circular(16)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      childName.isNotEmpty ? 'مهمة: $childName' : 'المهمة نشطة',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800),
                    ),
                    const Row(children: [
                      Text('جارية الآن',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                      SizedBox(width: 8),
                      Icon(Icons.circle, color: Colors.white, size: 10),
                    ]),
                  ],
                ),
              ),
            ),

            // ── TabBar ─────────────────────────────────────────────────────
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                labelColor: _navy,
                unselectedLabelColor: Colors.grey,
                indicatorColor: _navy,
                tabs: const [
                  Tab(text: 'البث والتحكم'),
                  Tab(text: 'نقاط الاشتباه'),
                ],
              ),
            ),

            // ── TabBarView ─────────────────────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // ── Tab 1: البث والتحكم ────────────────────────────────
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const SizedBox(height: 4),

                        // Live video feed — PRIMARY element, shown first
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4))
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Icon(
                                  _videoSource == VideoSource.tello
                                      ? Icons.flight
                                      : Icons.laptop,
                                  color: _navy,
                                  size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  _videoSource == VideoSource.tello
                                      ? 'بث مباشر من الدرون'
                                      : 'بث مباشر من كاميرا اللابتوب',
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700)),
                              ]),
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 240,
                                  child: _MjpegView(
                                    url: _videoSource == VideoSource.laptop
                                        ? FlaskApiService.laptopFeedUrl
                                        : FlaskApiService.videoFeedUrl,
                                    onFrame: (f) {
                                      _latestFrame = f;
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Chat panel
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4))
                            ],
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(14),
                                child: Row(children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                        color: _navy.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10)),
                                    child: const Icon(Icons.flight,
                                        color: _navy, size: 20),
                                  ),
                                  const SizedBox(width: 10),
                                  const Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('جناح - نظام البحث والإنقاذ',
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w800)),
                                      Text('متصل ✅',
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF00D995))),
                                    ],
                                  ),
                                ]),
                              ),
                              const Divider(height: 1),
                              SizedBox(
                                height: 280,
                                child: StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection('mission_messages')
                                      .where('reportId',
                                          isEqualTo: widget.reportId)
                                      .orderBy('createdAt')
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    final docs = snapshot.hasData
                                        ? snapshot.data!.docs
                                        : [];
                                    final List<_ChatItem> items = [
                                      ...docs.map((d) {
                                        final data =
                                            d.data() as Map<String, dynamic>;
                                        final ts = data['createdAt'];
                                        final time = ts is Timestamp
                                            ? ts.toDate()
                                            : DateTime.now();
                                        return _ChatItem.message(
                                          text: data['text'] ?? '',
                                          isBot: data['isBot'] ?? false,
                                          isAlert: data['isAlert'] ?? false,
                                          time: time,
                                        );
                                      }),
                                      ..._localImageMessages
                                          .map((img) => _ChatItem.image(
                                                imageBytes: img.imageBytes,
                                                time: img.createdAt,
                                              )),
                                    ]..sort(
                                        (a, b) => a.time.compareTo(b.time));

                                    if (items.isEmpty) {
                                      return const Center(
                                        child: Text(
                                          'الطائرة جاهزة ✅\nأرسل أمرك الأول',
                                          style: TextStyle(
                                              color: Color(0xFF9E9E9E),
                                              fontSize: 13),
                                          textAlign: TextAlign.center,
                                        ),
                                      );
                                    }
                                    WidgetsBinding.instance
                                        .addPostFrameCallback(
                                            (_) => _scrollToBottom());
                                    return ListView.builder(
                                      controller: _chatScrollController,
                                      padding: const EdgeInsets.all(12),
                                      itemCount: items.length,
                                      itemBuilder: (_, i) {
                                        final item = items[i];
                                        if (item.imageBytes != null) {
                                          return _buildImageBubble(
                                              item.imageBytes!);
                                        }
                                        return _buildChatBubble(_ChatMessage(
                                          text: item.text ?? '',
                                          isBot: item.isBot,
                                          isAlert: item.isAlert,
                                        ));
                                      },
                                    );
                                  },
                                ),
                              ),
                              const Divider(height: 1),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(12, 12, 12, 8),
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 6,
                                  children: [
                                    _QuickChip(
                                        label: 'ماذا ترى؟',
                                        onTap: () => _sendQuick('ماذا ترى؟'),
                                        enabled: isReady && !_isSending),
                                    _QuickChip(
                                        label: 'تحرك للأمام',
                                        onTap: () =>
                                            _sendQuick('تحرك للأمام'),
                                        enabled: isReady && !_isSending),
                                    _QuickChip(
                                        label: 'التقط صورة الآن',
                                        onTap: () =>
                                            _sendQuick('التقط صورة الآن'),
                                        enabled: isReady && !_isSending),
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
                                      enabled: isReady && !_isSending,
                                      textAlign: TextAlign.right,
                                      textDirection: TextDirection.rtl,
                                      onSubmitted: (_) => _sendCommand(),
                                      decoration: InputDecoration(
                                        hintText: isReady
                                            ? 'اكتب أمرك بالعربية...'
                                            : 'الأوامر ستُفعَّل في المرحلة القادمة',
                                        hintTextDirection: TextDirection.rtl,
                                        hintStyle: const TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF9E9E9E)),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            borderSide: const BorderSide(
                                                color: Color(0xFFE0E0E0))),
                                        enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            borderSide: BorderSide(
                                                color:
                                                    _navy.withOpacity(0.3))),
                                        disabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            borderSide: const BorderSide(
                                                color: Color(0xFFE0E0E0))),
                                        filled: true,
                                        fillColor: isReady
                                            ? Colors.white
                                            : const Color(0xFFF0F0F0),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 10),
                                        isDense: true,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: (isReady && !_isSending)
                                        ? _sendCommand
                                        : null,
                                    child: Opacity(
                                      opacity: (isReady && !_isSending)
                                          ? 1.0
                                          : 0.35,
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: const BoxDecoration(
                                            color: _navy,
                                            shape: BoxShape.circle),
                                        child: _isSending
                                            ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                        color: Colors.white,
                                                        strokeWidth: 2),
                                              )
                                            : const Icon(Icons.send,
                                                color: Colors.white, size: 20),
                                      ),
                                    ),
                                  ),
                                ]),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Emergency landing — at the bottom, not blocking the view
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton.icon(
                            onPressed: _emergencyLanding,
                            icon: const Icon(Icons.emergency_outlined,
                                color: Colors.white, size: 24),
                            label: const Text('هبوط طارئ',
                                style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 1)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _red,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Back button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _navy,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            child: const Text('العودة إلى التفاصيل',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white)),
                          ),
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),

                  // ── Tab 2: نقاط الاشتباه ──────────────────────────────
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4))
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(children: [
                                Icon(Icons.location_searching,
                                    color: Color(0xFF3D5A6C), size: 18),
                                SizedBox(width: 8),
                                Text('نقاط الاشتباه',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700)),
                              ]),
                              const SizedBox(height: 12),
                              if (_suspiciousPoints.isEmpty)
                                const Center(
                                  child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 8),
                                    child: Text(
                                      'لا توجد نقاط اشتباه بعد',
                                      style: TextStyle(
                                          color: Color(0xFF9E9E9E),
                                          fontSize: 13),
                                    ),
                                  ),
                                )
                              else
                                ..._suspiciousPoints
                                    .map((p) => _buildSuspiciousCard(p)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSuspiciousCard(_SuspiciousPoint point) {
    final isPending   = point.status == 'pending';
    final isConfirmed = point.status == 'confirmed';

    final badgeColor = isPending
        ? const Color(0xFFFFB300)
        : isConfirmed
            ? const Color(0xFF00D995)
            : const Color(0xFFEF5350);
    final badgeText = isPending
        ? 'قيد المراجعة'
        : isConfirmed
            ? 'تم العثور'
            : 'غير مطابق';
    final bgColor = isPending
        ? const Color(0xFFFFFDE7)
        : isConfirmed
            ? const Color(0xFFE8FFF5)
            : const Color(0xFFFFEBEB);
    final borderColor = isPending
        ? const Color(0xFFFFEB3B)
        : isConfirmed
            ? const Color(0xFF00D995)
            : const Color(0xFFEF5350);

    final mins = DateTime.now().difference(point.detectedAt).inMinutes;
    final timeText = mins < 1 ? 'الآن' : 'منذ $mins دقيقة';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('نقطة اشتباه #${point.number}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(timeText,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF757575))),
                const SizedBox(height: 2),
                Text(
                  point.alertType == 'manual'
                      ? 'التقاط يدوي 📷'
                      : 'تطابق الوجه: ${point.matchScore}% · الملابس: ${point.colorMatch ? "✓" : "✗"}',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF757575)),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(20)),
                  child: Text(badgeText,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () async {
                    final result = await Navigator.push<String>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VerificationScreen(
                          reportId: widget.reportId,
                          pointNumber: point.number,
                          matchScore: point.matchScore,
                          colorMatch: point.colorMatch,
                          alertType: point.alertType,
                          capturedImageBase64: point.capturedImageBase64,
                        ),
                      ),
                    );
                    if (result != null && mounted) {
                      setState(() => point.status = result);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3D5A6C),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('عرض والتحقق',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageBubble(Uint8List bytes) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8, right: 4, left: 40),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(bytes, width: 180, height: 160, fit: BoxFit.cover),
        ),
      ),
    );
  }

  Widget _buildChatBubble(_ChatMessage msg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment:
            msg.isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          if (msg.isBot) ...[
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                  color: msg.isAlert
                      ? _red.withOpacity(0.12)
                      : _navy.withOpacity(0.1),
                  shape: BoxShape.circle),
              child: Icon(
                msg.isAlert ? Icons.notifications_active : Icons.flight,
                color: msg.isAlert ? _red : _navy,
                size: 14,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: msg.isAlert
                    ? _red.withOpacity(0.08)
                    : msg.isBot
                        ? const Color(0xFFF0F4F7)
                        : _navy,
                borderRadius: BorderRadius.only(
                  topRight: const Radius.circular(16),
                  topLeft: const Radius.circular(16),
                  bottomRight: msg.isBot
                      ? const Radius.circular(16)
                      : const Radius.circular(4),
                  bottomLeft: msg.isBot
                      ? const Radius.circular(4)
                      : const Radius.circular(16),
                ),
                border: msg.isAlert
                    ? Border.all(color: _red.withOpacity(0.3))
                    : null,
              ),
              child: Text(msg.text,
                  style: TextStyle(
                      fontSize: 13,
                      color: msg.isBot
                          ? const Color(0xFF2D2D2D)
                          : Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Data Models ──────────────────────────────────────────────────────────────

class _SuspiciousPoint {
  final int number;
  final int matchScore;
  final bool colorMatch;
  final String alertType;
  final DateTime detectedAt;
  String status; // 'pending' | 'confirmed' | 'rejected'
  final String? capturedImageBase64;

  _SuspiciousPoint({
    required this.number,
    required this.matchScore,
    required this.colorMatch,
    required this.alertType,
    required this.detectedAt,
    this.status = 'pending',
    this.capturedImageBase64,
  });
}

class _LocalImageMessage {
  final Uint8List imageBytes;
  final DateTime createdAt;
  _LocalImageMessage({required this.imageBytes, required this.createdAt});
}

class _ChatItem {
  final String? text;
  final bool isBot;
  final bool isAlert;
  final Uint8List? imageBytes;
  final DateTime time;

  _ChatItem._({this.text, required this.isBot, required this.isAlert, this.imageBytes, required this.time});

  factory _ChatItem.message({required String text, required bool isBot, required bool isAlert, required DateTime time}) =>
      _ChatItem._(text: text, isBot: isBot, isAlert: isAlert, time: time);

  factory _ChatItem.image({required Uint8List imageBytes, required DateTime time}) =>
      _ChatItem._(imageBytes: imageBytes, isBot: true, isAlert: false, time: time);
}

class _ChatMessage {
  final String text;
  final bool isBot;
  final bool isAlert;
  _ChatMessage({
    required this.text,
    required this.isBot,
    this.isAlert = false,
  });
}

// ─── MJPEG Video Widget ───────────────────────────────────────────────────────

class _MjpegView extends StatefulWidget {
  final String url;
  final void Function(Uint8List)? onFrame;
  const _MjpegView({required this.url, this.onFrame});

  @override
  State<_MjpegView> createState() => _MjpegViewState();
}

class _MjpegViewState extends State<_MjpegView> {
  Uint8List? _frame;
  http.Client? _client;
  StreamSubscription<List<int>>? _sub;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _connect();
  }

  @override
  void didUpdateWidget(_MjpegView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _sub?.cancel();
      _client?.close();
      _connect();
    }
  }

  Future<void> _connect() async {
    if (!mounted) return;
    setState(() {
      _error = false;
      _frame = null;
    });

    try {
      _client = http.Client();
      final request = http.Request('GET', Uri.parse(widget.url));
      final response = await _client!
          .send(request)
          .timeout(const Duration(seconds: 10));

      final buf = <int>[];

      _sub = response.stream.listen(
        (chunk) {
          buf.addAll(chunk);

          // Find JPEG frames by SOI (FF D8) and EOI (FF D9) markers
          int soiIdx = -1;
          for (int i = 0; i < buf.length - 1; i++) {
            if (buf[i] == 0xFF && buf[i + 1] == 0xD8) {
              soiIdx = i;
              break;
            }
          }
          if (soiIdx == -1) return;

          for (int j = soiIdx + 2; j < buf.length - 1; j++) {
            if (buf[j] == 0xFF && buf[j + 1] == 0xD9) {
              // Complete JPEG frame found
              final frame = Uint8List.fromList(buf.sublist(soiIdx, j + 2));
              buf.removeRange(0, j + 2);
              if (mounted) {
                setState(() => _frame = frame);
                widget.onFrame?.call(frame);
              }
              break;
            }
          }

          // Prevent buffer overflow (> 1 MB)
          if (buf.length > 1048576) buf.clear();
        },
        onError: (_) {
          if (mounted) setState(() => _error = true);
        },
        onDone: () {
          if (mounted) setState(() => _error = true);
        },
      );
    } catch (_) {
      if (mounted) setState(() => _error = true);
    }
  }

  @override
  void dispose() {
    // Cancel subscription before closing client to avoid callbacks after close
    _sub?.cancel();
    _client?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error) {
      return Container(
        color: const Color(0xFF1A1A2E),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.videocam_off,
                  color: Colors.white54, size: 36),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _connect,
                child: const Text('إعادة الاتصال',
                    style: TextStyle(color: Colors.white70)),
              ),
            ],
          ),
        ),
      );
    }

    if (_frame == null) {
      return Container(
        color: const Color(0xFF1A1A2E),
        child: Stack(children: [
          const Center(
            child: CircularProgressIndicator(
                color: Colors.white38, strokeWidth: 2),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                  color: const Color(0xFFEF5350),
                  borderRadius: BorderRadius.circular(6)),
              child: const Text('LIVE',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800)),
            ),
          ),
        ]),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.memory(_frame!, fit: BoxFit.cover, gaplessPlayback: true),
        Positioned(
          top: 10,
          right: 10,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
                color: const Color(0xFFEF5350),
                borderRadius: BorderRadius.circular(6)),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, color: Colors.white, size: 6),
                SizedBox(width: 4),
                Text('LIVE',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Helper Widgets ───────────────────────────────────────────────────────────

class _QuickChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool enabled;
  const _QuickChip({
    required this.label,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.4,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF3D5A6C).withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: const Color(0xFF3D5A6C).withOpacity(0.25)),
          ),
          child: Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3D5A6C))),
        ),
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
      decoration: BoxDecoration(
          color: const Color(0xFFEF5350),
          borderRadius: BorderRadius.circular(6)),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, color: Colors.white, size: 6),
          SizedBox(width: 4),
          Text('LIVE',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

// ─── Source Selector Cards ────────────────────────────────────────────────────

class _SourceCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final bool selected;
  final VoidCallback onTap;
  const _SourceCard({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF3D5A6C);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: selected ? navy.withOpacity(0.08) : Colors.grey[100],
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? navy : Colors.grey[300]!,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? navy : Colors.grey[500], size: 26),
            const SizedBox(height: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: selected ? navy : Colors.grey[600])),
            Text(sublabel,
                style: TextStyle(fontSize: 10, color: Colors.grey[500])),
          ],
        ),
      ),
    );
  }
}


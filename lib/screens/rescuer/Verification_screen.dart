import 'package:flutter/material.dart';

class VerificationScreen extends StatefulWidget {
  final String reportId;
  final int pointNumber;

  const VerificationScreen({
    super.key,
    this.reportId = '#1234',
    this.pointNumber = 1,
  });

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  bool _isSubmitting = false;

  static const Color _navy  = Color(0xFF3D5A6C);
  static const Color _green = Color(0xFF00D995);
  static const Color _red   = Color(0xFFEF5350);
  static const Color _bg    = Color(0xFFF4EFEB);

  void _handleMatch() async {
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      showDialog(
        context: context,
        builder: (_) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('تأكيد المطابقة', textAlign: TextAlign.right),
            content: const Text('سيتم إشعار ولي الأمر فوراً بتأكيد العثور على الطفل. هل تريد المتابعة؟', textAlign: TextAlign.right),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
              ElevatedButton(
                onPressed: () { Navigator.pop(context); Navigator.pop(context); },
                style: ElevatedButton.styleFrom(backgroundColor: _green),
                child: const Text('تأكيد العثور', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }
    setState(() => _isSubmitting = false);
  }

  void _handleNoMatch() {
    showDialog(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('غير مطابق', textAlign: TextAlign.right),
          content: const Text('سيتم تسجيل هذه النقطة كغير مطابقة ومتابعة البحث.', textAlign: TextAlign.right),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () { Navigator.pop(context); Navigator.pop(context); },
              style: ElevatedButton.styleFrom(backgroundColor: _red),
              child: const Text('متابعة البحث', style: TextStyle(color: Colors.white)),
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
        body: SafeArea(
          child: Column(
            children: [
              // ── HEADER ──
              Container(
                width: double.infinity,
                color: _navy,
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const Expanded(
                      child: Text('التحقق من النتائج',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                    ),
                    const SizedBox(width: 36),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [

                      // ── كارد نقطة الاشتباه ──
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFDE7),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFFFEB3B), width: 1.5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // الاسم والتفاصيل على اليسار
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('نقطة اشتباه #${widget.pointNumber}',
                                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                                    const SizedBox(height: 8),
                                    Row(mainAxisSize: MainAxisSize.min, children: const [
                                      Icon(Icons.location_on, size: 14, color: _red),
                                      SizedBox(width: 4),
                                      Text('قرب الموقع المحدد - 200 متر شمالاً',
                                          style: TextStyle(fontSize: 12, color: Color(0xFF757575))),
                                    ]),
                                    const SizedBox(height: 4),
                                    Row(mainAxisSize: MainAxisSize.min, children: const [
                                      Icon(Icons.access_time, size: 14, color: Color(0xFF9E9E9E)),
                                      SizedBox(width: 4),
                                      Text('منذ 15 دقيقة',
                                          style: TextStyle(fontSize: 12, color: Color(0xFF757575))),
                                    ]),
                                  ],
                                ),
                                // باج قيد المراجعة على اليمين
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFB300),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text('قيد المراجعة',
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── مقارنة الصور ──
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3))],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Align(
                              alignment: Alignment.centerRight,
                              child: Text('مقارنة الصور',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                // صورة الطفل (يمين)
                                Expanded(
                                  child: Column(
                                    children: [
                                      Container(
                                        height: 130,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE8E8E8),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Center(child: Icon(Icons.person, size: 50, color: Color(0xFF9E9E9E))),
                                      ),
                                      const SizedBox(height: 6),
                                      const Text('محمد أحمد',
                                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                                          textAlign: TextAlign.center),
                                      const Text('صورة الطفل الأصلية',
                                          style: TextStyle(fontSize: 10, color: Color(0xFF9E9E9E)),
                                          textAlign: TextAlign.center),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(color: _navy.withOpacity(0.1), shape: BoxShape.circle),
                                  child: const Icon(Icons.compare_arrows, color: _navy, size: 22),
                                ),
                                const SizedBox(width: 10),
                                // صورة الدرون (يسار)
                                Expanded(
                                  child: Column(
                                    children: [
                                      Stack(
                                        children: [
                                          Container(
                                            height: 130,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFCFE8CF),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: const Center(child: Icon(Icons.flight, size: 40, color: Color(0xFF4CAF50))),
                                          ),
                                          Positioned(
                                            top: 8, right: 8,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(color: _red, borderRadius: BorderRadius.circular(6)),
                                              child: const Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      const Text('DR-01',
                                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                                          textAlign: TextAlign.center),
                                      const Text('لقطة من الدرون',
                                          style: TextStyle(fontSize: 10, color: Color(0xFF9E9E9E)),
                                          textAlign: TextAlign.center),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── توصية الذكاء الاصطناعي ──
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8FFF5),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _green.withOpacity(0.4), width: 1.5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // الأيقونة على اليسار، الكلام على اليمين
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text('توصية الذكاء الاصطناعي',
                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF2E7D32))),
                                    Text('مطابقة محتملة!',
                                        style: TextStyle(fontSize: 12, color: Color(0xFF388E3C))),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(color: _green.withOpacity(0.2), shape: BoxShape.circle),
                                  child: const Icon(Icons.psychology, color: Color(0xFF2E7D32), size: 26),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            // شريط الثقة — 82% على اليمين
                            Row(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: LinearProgressIndicator(
                                      value: 0.82,
                                      backgroundColor: Colors.green.shade100,
                                      valueColor: const AlwaysStoppedAnimation<Color>(_green),
                                      minHeight: 10,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: const [
                                    Text('82%', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF2E7D32), fontSize: 22)),
                                    Text('نسبة الثقة', style: TextStyle(fontSize: 11, color: Color(0xFF66BB6A))),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            const Align(
                              alignment: Alignment.centerRight,
                              child: Text('أسباب التوصية:',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF2D2D2D))),
                            ),
                            const SizedBox(height: 8),
                            const _AiReason(text: 'تطابق ملامح الوجه: 78%'),
                            const _AiReason(text: 'تطابق الملابس: 85%'),
                            const _AiReason(text: 'الموقع قريب من آخر ظهور مسجل'),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: _green.withOpacity(0.3)),
                              ),
                              child: Row(children: const [
                                Text('ℹ️', style: TextStyle(fontSize: 16)),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'النظام يوصي بـ "تطابق" بناءً على التحليل. يرجى المراجعة والتأكيد.',
                                    style: TextStyle(fontSize: 11, color: Color(0xFF2E7D32)),
                                  ),
                                ),
                              ]),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── قرار التحقق ──
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3))],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Align(
                              alignment: Alignment.centerRight,
                              child: Text('قرار التحقق',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                            ),
                            const SizedBox(height: 4),
                            const Align(
                              alignment: Alignment.centerRight,
                              child: Text('بناءً على المعلومات أعلاه، هل هذا هو الطفل المفقود؟',
                                  style: TextStyle(fontSize: 12, color: Color(0xFF757575)),
                                  textAlign: TextAlign.right),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                // مطابق — يمين
                                Expanded(
                                  child: GestureDetector(
                                    onTap: _isSubmitting ? null : _handleMatch,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 18),
                                      decoration: BoxDecoration(color: _green, borderRadius: BorderRadius.circular(14)),
                                      child: Column(children: const [
                                        Icon(Icons.check_circle, color: Colors.white, size: 30),
                                        SizedBox(height: 6),
                                        Text('مطابق', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
                                        Text('تأكيد العثور', style: TextStyle(fontSize: 11, color: Colors.white70)),
                                      ]),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // غير مطابق — يسار
                                Expanded(
                                  child: GestureDetector(
                                    onTap: _handleNoMatch,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 18),
                                      decoration: BoxDecoration(color: _red, borderRadius: BorderRadius.circular(14)),
                                      child: Column(children: const [
                                        Icon(Icons.cancel, color: Colors.white, size: 30),
                                        SizedBox(height: 6),
                                        Text('غير مطابق', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
                                        Text('متابعة البحث', style: TextStyle(fontSize: 11, color: Colors.white70)),
                                      ]),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── تحذير ──
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8E1),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFFFCC02)),
                        ),
                        child: Row(children: const [
                          Text('⚠️', style: TextStyle(fontSize: 18)),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'تأكد من دقة قرارك. سيتم إرسال إشعار فوري لولي الأمر في حالة التطابق.',
                              style: TextStyle(fontSize: 12, color: Color(0xFF5D4037)),
                            ),
                          ),
                        ]),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AiReason extends StatelessWidget {
  const _AiReason({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(children: [
        const Icon(Icons.circle, size: 6, color: Color(0xFF2E7D32)),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 12, color: Color(0xFF2D2D2D))),
      ]),
    );
  }
}

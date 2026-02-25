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

  static const Color _navy = Color(0xFF3D5A6C);

  void _handleMatch(BuildContext context) async {
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 500));
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (_) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('تأكيد المطابقة', textAlign: TextAlign.right),
            content: const Text(
              'سيتم إشعار ولي الأمر فوراً بتأكيد العثور على الطفل. هل تريد المتابعة؟',
              textAlign: TextAlign.right,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00D995)),
                child: const Text('تأكيد العثور', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }
    setState(() => _isSubmitting = false);
  }

  void _handleNoMatch(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('غير مطابق', textAlign: TextAlign.right),
          content: const Text(
            'سيتم تسجيل هذه النقطة كغير مطابقة ومتابعة البحث.',
            textAlign: TextAlign.right,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF5350)),
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
        backgroundColor: const Color(0xFFF4EFEB),
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
                    const Spacer(),
                    const Text(
                      'التحقق من النتائج',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

              // ── BODY ──
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // ── كارد نقطة الاشتباه ──
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFFFEB3B), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            )
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'نقطة اشتباه #${widget.pointNumber}',
                                    style: const TextStyle(
                                        fontSize: 15, fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 8),
                                  const Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        'قرب الموقع المحدد - 200 متر شمالاً',
                                        style: TextStyle(
                                            fontSize: 12, color: Color(0xFF757575)),
                                      ),
                                      SizedBox(width: 4),
                                      Icon(Icons.location_on,
                                          size: 14, color: Color(0xFFEF5350)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  const Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        'منذ 15 دقيقة',
                                        style: TextStyle(
                                            fontSize: 12, color: Color(0xFF757575)),
                                      ),
                                      SizedBox(width: 4),
                                      Icon(Icons.access_time,
                                          size: 14, color: Color(0xFF9E9E9E)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF9C4),
                                borderRadius: BorderRadius.circular(20),
                                border:
                                    Border.all(color: const Color(0xFFFFEB3B)),
                              ),
                              child: const Text(
                                'قيد المراجعة',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFF57F17),
                                ),
                              ),
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
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'مقارنة الصور',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                // صورة الدرون
                                Expanded(
                                  child: Column(
                                    children: [
                                      Container(
                                        height: 120,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE0E0E0),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Center(
                                          child: Icon(Icons.flight,
                                              size: 40, color: Color(0xFF9E9E9E)),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      const Text(
                                        'صورة الدرون',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF757575)),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // أيقونة المقارنة
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: _navy.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.compare_arrows,
                                      color: _navy, size: 22),
                                ),
                                const SizedBox(width: 12),
                                // صورة الطفل
                                Expanded(
                                  child: Column(
                                    children: [
                                      Container(
                                        height: 120,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE0E0E0),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Center(
                                          child: Icon(Icons.person,
                                              size: 40, color: Color(0xFF9E9E9E)),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      const Text(
                                        'صورة الطفل',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF757575)),
                                        textAlign: TextAlign.center,
                                      ),
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
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'توصية الذكاء الاصطناعي',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF2E7D32),
                                      ),
                                    ),
                                    Text(
                                      'مطابقة محتملة!',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF388E3C)),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color:
                                        const Color(0xFF00D995).withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.psychology,
                                      color: Color(0xFF2E7D32), size: 22),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // شريط الثقة
                            Row(
                              children: [
                                const Text('82%',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF2E7D32),
                                      fontSize: 13,
                                    )),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: 0.82,
                                      backgroundColor: Colors.grey.shade200,
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                              Color(0xFF00D995)),
                                      minHeight: 8,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text('نسبة الثقة',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF66BB6A))),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                'أسباب التوصية:',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF2D2D2D)),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const _AiReason(text: 'تطابق ملامح الوجه: 78%'),
                            const _AiReason(text: 'تطابق الملابس: 85%'),
                            const _AiReason(
                                text: 'الموقع قريب من آخر ظهور مسجل'),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF9C4),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: const Color(0xFFFFEB3B)),
                              ),
                              child: const Row(
                                children: [
                                  Text('⚠️'),
                                  SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'النظام يوصي بـ "تطابق" بناءً على التحليل. يرجى المراجعة والتأكيد.',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF5D4037)),
                                    ),
                                  ),
                                ],
                              ),
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
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'قرار التحقق',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'بناءً على المعلومات أعلاه، هل هذا هو الطفل المفقود؟',
                              style: TextStyle(
                                  fontSize: 12, color: Color(0xFF757575)),
                              textAlign: TextAlign.right,
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                // غير مطابق
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => _handleNoMatch(context),
                                    child: Container(
                                      padding:
                                          const EdgeInsets.symmetric(vertical: 16),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEF5350),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: const Column(
                                        children: [
                                          Icon(Icons.cancel,
                                              color: Colors.white, size: 28),
                                          SizedBox(height: 6),
                                          Text('غير مطابق',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.white)),
                                          Text('متابعة البحث',
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.white70)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // مطابق
                                Expanded(
                                  child: GestureDetector(
                                    onTap: _isSubmitting
                                        ? null
                                        : () => _handleMatch(context),
                                    child: Container(
                                      padding:
                                          const EdgeInsets.symmetric(vertical: 16),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF00D995),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: const Column(
                                        children: [
                                          Icon(Icons.check_circle,
                                              color: Colors.white, size: 28),
                                          SizedBox(height: 6),
                                          Text('مطابق',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.white)),
                                          Text('تأكيد العثور',
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.white70)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── تحذير إشعار ولي الأمر ──
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8E1),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFFFCC02)),
                        ),
                        child: const Row(
                          children: [
                            Text('⚠️', style: TextStyle(fontSize: 18)),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'تأكد من دقة قرارك. سيتم إرسال إشعار فوري لولي الأمر في حالة التطابق.',
                                style: TextStyle(
                                    fontSize: 12, color: Color(0xFF5D4037)),
                              ),
                            ),
                          ],
                        ),
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
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 6, color: Color(0xFF2E7D32)),
          const SizedBox(width: 8),
          Text(text,
              style: const TextStyle(fontSize: 12, color: Color(0xFF2D2D2D))),
        ],
      ),
    );
  }
}

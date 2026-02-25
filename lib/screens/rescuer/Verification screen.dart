import 'package:flutter/material.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  bool _isSubmitting = false;

  void _handleMatch(BuildContext context) async {
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 500));
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (_) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('تأكيد المطابقة'),
            content: const Text('سيتم إشعار ولي الأمر فوراً بتأكيد العثور على الطفل. هل تريد المتابعة؟'),
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
          title: const Text('غير مطابق'),
          content: const Text('سيتم تسجيل هذه النقطة كغير مطابقة ومتابعة البحث.'),
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
        body: Column(
          children: [
            // ── HEADER ──
            Container(
              width: double.infinity,
              color: const Color(0xFF3D5A6C),
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8,
                bottom: 16,
                right: 8,
                left: 16,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_forward, color: Colors.white),
                  ),
                  const Expanded(
                    child: Text(
                      'التحقق من النتائج',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48),
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
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3))],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text('نقطة اشتباه #1', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: const [
                                    Text('قرب الموقع المحدد - 200 متر شمالاً', style: TextStyle(fontSize: 12, color: Color(0xFF757575))),
                                    SizedBox(width: 4),
                                    Icon(Icons.location_on, size: 14, color: Color(0xFFEF5350)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: const [
                                    Text('منذ 15 دقيقة', style: TextStyle(fontSize: 12, color: Color(0xFF757575))),
                                    SizedBox(width: 4),
                                    Icon(Icons.access_time, size: 14, color: Color(0xFF9E9E9E)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF9C4),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFFFEB3B)),
                            ),
                            child: const Text('قيد المراجعة', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFF57F17))),
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
                          const Text('مقارنة الصور', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              // صورة الدرون
                              Expanded(
                                child: Column(
                                  children: [
                                    Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Container(
                                            height: 140,
                                            color: const Color(0xFF4CAF50),
                                            child: const Center(
                                              child: Icon(Icons.landscape, color: Colors.white54, size: 48),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFEF5350),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: const Text('LIVE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white)),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    const Text('DR-01', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF3D5A6C))),
                                    const Text('18:15:42', style: TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              // صورة الطفل
                              Expanded(
                                child: Column(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        height: 140,
                                        color: const Color(0xFFE0E0E0),
                                        child: const Center(
                                          child: Icon(Icons.person, color: Colors.white70, size: 64),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text('محمد أحمد', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                                    const Text('صورة الطفل الأصلية', style: TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
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
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF81C784), width: 1.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('82%', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF2E7D32))),
                              Row(
                                children: [
                                  const Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text('توصية الذكاء الاصطناعي', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF2E7D32))),
                                      Text('مطابقة محتملة!', style: TextStyle(fontSize: 12, color: Color(0xFF388E3C))),
                                    ],
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF00D995).withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.psychology, color: Color(0xFF2E7D32), size: 22),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Text('نسبة الثقة', style: TextStyle(fontSize: 11, color: Color(0xFF66BB6A))),
                          const SizedBox(height: 12),
                          const Text('أسباب التوصية:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF2D2D2D))),
                          const SizedBox(height: 8),
                          _AiReason(text: 'تطابق ملامح الوجه: 78%'),
                          _AiReason(text: 'تطابق الملابس: 85%'),
                          _AiReason(text: 'الموقع قريب من آخر ظهور مسجل'),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF9C4),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFFFEB3B)),
                            ),
                            child: const Row(
                              children: [
                                Text('⚠️'),
                                SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'النظام يوصي بـ "تطابق" بناءً على التحليل. يرجى المراجعة والتأكيد.',
                                    style: TextStyle(fontSize: 11, color: Color(0xFF5D4037)),
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
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('قرار التحقق', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          const Text('بناءً على المعلومات أعلاه، هل هذا هو الطفل المفقود؟', style: TextStyle(fontSize: 12, color: Color(0xFF757575))),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              // غير مطابق
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _handleNoMatch(context),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEF5350),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: const Column(
                                      children: [
                                        Icon(Icons.cancel, color: Colors.white, size: 28),
                                        SizedBox(height: 6),
                                        Text('غير مطابق', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                                        Text('متابعة البحث', style: TextStyle(fontSize: 11, color: Colors.white70)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // مطابق
                              Expanded(
                                child: GestureDetector(
                                  onTap: _isSubmitting ? null : () => _handleMatch(context),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF00D995),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: const Column(
                                      children: [
                                        Icon(Icons.check_circle, color: Colors.white, size: 28),
                                        SizedBox(height: 6),
                                        Text('مطابق', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                                        Text('تأكيد العثور', style: TextStyle(fontSize: 11, color: Colors.white70)),
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
                              style: TextStyle(fontSize: 12, color: Color(0xFF5D4037)),
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
          Text(text, style: const TextStyle(fontSize: 12, color: Color(0xFF2D2D2D))),
        ],
      ),
    );
  }
}

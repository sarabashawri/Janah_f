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
          // الصف الأول
          Row(
            children: [
              Text(
                'نقطة اشتباه #${point.number}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: badge,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  point.status,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            point.time,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF757575),
            ),
          ),

          const SizedBox(height: 6),

          Row(
            children: [
              const Icon(Icons.location_on,
                  size: 14, color: Color(0xFFEF5350)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  point.location,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF757575),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 🔥 هنا التعديل — زر يسار تحت البادج
          Align(
            alignment: Alignment.centerLeft,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'عرض والتحقق',
                    style: TextStyle(
                      color: Color(0xFF3D5A6C),
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Color(0xFF3D5A6C),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum ReportStatus { pending, accepted, searching, matchFound, resolved }

extension ReportStatusX on ReportStatus {
  /// Raw string written to Firestore.
  String toFirestore() => name; // 'pending', 'accepted', 'searching', 'matchFound', 'resolved'

  /// Parse a Firestore string — handles legacy values from old documents.
  static ReportStatus fromFirestore(String? s) => switch (s) {
    'pending'                    => ReportStatus.pending,
    'accepted'                   => ReportStatus.accepted,
    'searching' || 'inProgress' || 'active' => ReportStatus.searching,
    'matchFound' || 'found'                => ReportStatus.matchFound,
    'resolved'  || 'closed'               => ReportStatus.resolved,
    _                                      => ReportStatus.pending,
  };
}

class Report {
  final String id;
  final String childName;
  final String description;
  final String imageUrl;
  final String clothingColor;
  final DateTime lastSeen;
  final String location;
  final double latitude;
  final double longitude;
  final String guardianName;
  final String guardianPhone;
  final ReportStatus status;
  final DateTime createdAt;
  final List<ReportUpdate>? updates;

  Report({
    required this.id,
    required this.childName,
    required this.description,
    required this.imageUrl,
    required this.clothingColor,
    required this.lastSeen,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.guardianName,
    required this.guardianPhone,
    required this.status,
    required this.createdAt,
    this.updates,
  });

  String get statusText {
    switch (status) {
      case ReportStatus.pending:
        return 'قيد الانتظار';
      case ReportStatus.accepted:
        return 'تم القبول';
      case ReportStatus.searching:
        return 'جاري البحث';
      case ReportStatus.matchFound:
        return 'تم العثور';
      case ReportStatus.resolved:
        return 'تم الإغلاق';
    }
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    } else {
      return 'منذ ${difference.inDays} يوم';
    }
  }
}

class ReportUpdate {
  final String title;
  final String description;
  final DateTime timestamp;
  final String icon;

  ReportUpdate({
    required this.title,
    required this.description,
    required this.timestamp,
    required this.icon,
  });
}

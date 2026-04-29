/// A single Umrah guide lesson, sourced from Firestore and cached in sqflite.
class UmrahGuide {
  const UmrahGuide({
    required this.id,
    required this.title,
    required this.category,
    required this.body,
    this.arabicText,
    required this.stepOrder,
    this.iconName,
    required this.cachedAt,
  });

  final String id;
  final String title;
  final String category;
  final String body;
  final String? arabicText;
  final int stepOrder;
  final String? iconName;
  final DateTime cachedAt;

  // ── Firestore → model ─────────────────────────────────────────────────────

  factory UmrahGuide.fromFirestore(String id, Map<String, dynamic> data) {
    return UmrahGuide(
      id: id,
      title: data['title'] as String? ?? '',
      category: data['category'] as String? ?? '',
      body: data['body'] as String? ?? '',
      arabicText: data['arabic_text'] as String?,
      stepOrder: (data['step_order'] as num?)?.toInt() ?? 0,
      iconName: data['icon_name'] as String?,
      cachedAt: DateTime.now(),
    );
  }

  // ── sqflite row → model ───────────────────────────────────────────────────

  factory UmrahGuide.fromMap(Map<String, dynamic> row) {
    return UmrahGuide(
      id: row['id'] as String,
      title: row['title'] as String,
      category: row['category'] as String,
      body: row['body'] as String,
      arabicText: row['arabic_text'] as String?,
      stepOrder: row['step_order'] as int,
      iconName: row['icon_name'] as String?,
      cachedAt: DateTime.parse(row['cached_at'] as String),
    );
  }

  // ── model → sqflite row ───────────────────────────────────────────────────

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'category': category,
        'body': body,
        'arabic_text': arabicText,
        'step_order': stepOrder,
        'icon_name': iconName,
        'cached_at': cachedAt.toIso8601String(),
      };

  UmrahGuide copyWith({
    String? id,
    String? title,
    String? category,
    String? body,
    String? arabicText,
    int? stepOrder,
    String? iconName,
    DateTime? cachedAt,
  }) {
    return UmrahGuide(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      body: body ?? this.body,
      arabicText: arabicText ?? this.arabicText,
      stepOrder: stepOrder ?? this.stepOrder,
      iconName: iconName ?? this.iconName,
      cachedAt: cachedAt ?? this.cachedAt,
    );
  }
}

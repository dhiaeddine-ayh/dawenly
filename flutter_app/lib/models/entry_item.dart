class EntryItemModel {
  final int id;
  final String text;
  final String? type; // 'journal', 'idea', 'problem', 'thought'
  final String createdAt;
  final String? mood;
  final List<String> tags;

  EntryItemModel({
    required this.id,
    required this.text,
    this.type = 'journal',
    required this.createdAt,
    this.mood,
    this.tags = const [],
  });

  factory EntryItemModel.fromJson(Map<String, dynamic> json) {
    final rawText = json['transcript']?.toString() ??
        json['summary']?.toString() ??
        json['text']?.toString() ??
        json['content']?.toString() ??
        '';

    List<String> tagsList = [];
    if (json['tags'] is List) {
      tagsList = (json['tags'] as List).map((t) => t.toString()).toList();
    } else if (json['tags'] is String && (json['tags'] as String).isNotEmpty) {
      try {
        tagsList = (json['tags'] as String).split(',').map((t) => t.trim()).toList();
      } catch (_) {}
    }

    return EntryItemModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      text: rawText,
      type: json['type']?.toString() ?? 'journal',
      createdAt: json['entry_date']?.toString() ??
          json['created_at']?.toString() ??
          DateTime.now().toIso8601String(),
      mood: json['mood']?.toString(),
      tags: tagsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transcript': text,
      'type': type,
      'entry_date': createdAt.length >= 10 ? createdAt.substring(0, 10) : createdAt,
      'created_at': createdAt,
      'mood': mood,
      'tags': tags,
    };
  }
}

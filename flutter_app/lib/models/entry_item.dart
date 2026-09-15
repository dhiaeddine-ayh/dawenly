class EntryItemModel {
  final int id;
  final String text;
  final String? type; // 'journal', 'idea', 'problem', 'thought'
  final String createdAt;

  EntryItemModel({
    required this.id,
    required this.text,
    this.type,
    required this.createdAt,
  });

  factory EntryItemModel.fromJson(Map<String, dynamic> json) {
    return EntryItemModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      text: json['text']?.toString() ?? json['content']?.toString() ?? '',
      type: json['type']?.toString() ?? 'journal',
      createdAt: json['created_at']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }
}

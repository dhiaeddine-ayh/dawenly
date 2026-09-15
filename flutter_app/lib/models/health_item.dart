class HealthItemModel {
  final int id;
  final String category; // 'تمرين', 'دواء', 'أكل', 'عرض', 'نوم', 'نفسية', 'ملاحظة'
  final String content;
  final String date;
  final String? time;

  HealthItemModel({
    required this.id,
    required this.category,
    required this.content,
    required this.date,
    this.time,
  });

  factory HealthItemModel.fromJson(Map<String, dynamic> json) {
    return HealthItemModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      category: json['category']?.toString() ?? 'ملاحظة',
      content: json['content']?.toString() ?? json['text']?.toString() ?? '',
      date: json['date']?.toString() ?? DateTime.now().toIso8601String().substring(0, 10),
      time: json['time']?.toString(),
    );
  }
}

class HealthItemModel {
  final int id;
  final String category; // 'تمرين', 'دواء', 'أكل', 'عرض', 'نوم', 'نفسية', 'ملاحظة'
  final String content;
  final String date;
  final String? time;
  final String? bodyRegion; // 'راس', 'صدر', 'معدة', 'بطن', 'ذراعين', 'ساقين', 'عام'

  HealthItemModel({
    required this.id,
    required this.category,
    required this.content,
    required this.date,
    this.time,
    this.bodyRegion,
  });

  String get title => content.isNotEmpty ? content : category;

  factory HealthItemModel.fromJson(Map<String, dynamic> json) {
    return HealthItemModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      category: json['category']?.toString() ?? 'ملاحظة',
      content: json['content']?.toString() ?? json['detail']?.toString() ?? json['text']?.toString() ?? '',
      date: json['date']?.toString() ?? json['entry_date']?.toString() ?? DateTime.now().toIso8601String().substring(0, 10),
      time: json['time']?.toString() ?? json['at_time']?.toString(),
      bodyRegion: json['body_region']?.toString() ?? json['bodyRegion']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'detail': content,
      'entry_date': date,
      'at_time': time,
      'body_region': bodyRegion,
    };
  }
}

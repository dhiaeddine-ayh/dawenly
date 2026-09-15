class HabitModel {
  final int id;
  final String title;
  final String? icon;
  final String? kind; // 'do' or 'quit'
  final String? frequency;
  final int streak;
  final int total;
  final List<String> logs; // Dates YYYY-MM-DD that are checked

  HabitModel({
    required this.id,
    required this.title,
    this.icon,
    this.kind = 'do',
    this.frequency,
    this.streak = 0,
    this.total = 0,
    this.logs = const [],
  });

  factory HabitModel.fromJson(Map<String, dynamic> json) {
    List<String> logsList = [];
    if (json['logs'] is List) {
      logsList = (json['logs'] as List).map((e) => e.toString()).toList();
    }
    return HabitModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title']?.toString() ?? json['name']?.toString() ?? '',
      icon: json['icon']?.toString() ?? json['emoji']?.toString() ?? '✨',
      kind: json['kind']?.toString() ?? 'do',
      frequency: json['frequency']?.toString(),
      streak: json['streak'] is int
          ? json['streak']
          : (int.tryParse(json['streak']?.toString() ?? '0') ?? 0),
      total: json['total'] is int
          ? json['total']
          : (int.tryParse(json['total']?.toString() ?? '0') ?? 0),
      logs: logsList,
    );
  }

  bool isDoneOn(String isoDate) {
    return logs.contains(isoDate);
  }

  String get emoji => icon ?? '✨';
  bool get isCompletedToday => logs.contains(DateTime.now().toIso8601String().substring(0, 10));

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'emoji': icon,
      'kind': kind,
      'streak': streak,
      'total': total,
      'logs': logs,
    };
  }
}

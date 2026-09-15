class HabitModel {
  final int id;
  final String title;
  final String? icon;
  final String? frequency;
  final int streak;
  final List<String> logs; // Dates YYYY-MM-DD that are checked

  HabitModel({
    required this.id,
    required this.title,
    this.icon,
    this.frequency,
    this.streak = 0,
    this.logs = const [],
  });

  factory HabitModel.fromJson(Map<String, dynamic> json) {
    List<String> logsList = [];
    if (json['logs'] is List) {
      logsList = (json['logs'] as List).map((e) => e.toString()).toList();
    }
    return HabitModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      title: json['title']?.toString() ?? json['name']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '✨',
      frequency: json['frequency']?.toString(),
      streak: json['streak'] is int ? json['streak'] : (int.tryParse(json['streak']?.toString() ?? '0') ?? 0),
      logs: logsList,
    );
  }

  bool isDoneOn(String isoDate) {
    return logs.contains(isoDate);
  }
}

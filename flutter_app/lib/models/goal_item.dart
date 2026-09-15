class GoalItemModel {
  final int id;
  final String title;
  final String? targetDate;
  final int progress; // 0 to 100
  final String status; // 'active', 'completed', 'paused'
  final String? category;

  GoalItemModel({
    required this.id,
    required this.title,
    this.targetDate,
    this.progress = 0,
    this.status = 'active',
    this.category,
  });

  factory GoalItemModel.fromJson(Map<String, dynamic> json) {
    return GoalItemModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      title: json['title']?.toString() ?? '',
      targetDate: json['target_date']?.toString(),
      progress: json['progress'] is int
          ? json['progress']
          : (int.tryParse(json['progress']?.toString() ?? '0') ?? 0),
      status: json['status']?.toString() ?? 'active',
      category: json['category']?.toString(),
    );
  }
}

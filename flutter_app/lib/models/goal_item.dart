class GoalItemModel {
  final int id;
  final String title;
  final String? targetDate;
  final int progress; // 0 to 100
  final double current;
  final double? target;
  final String? unit;
  final String status; // 'active', 'completed', 'paused'
  final String? category;

  GoalItemModel({
    required this.id,
    required this.title,
    this.targetDate,
    this.progress = 0,
    this.current = 0.0,
    this.target,
    this.unit,
    this.status = 'active',
    this.category,
  });

  factory GoalItemModel.fromJson(Map<String, dynamic> json) {
    final cur = (json['current'] is num)
        ? (json['current'] as num).toDouble()
        : (double.tryParse(json['current']?.toString() ?? '0') ?? 0.0);
    final tgt = (json['target'] is num)
        ? (json['target'] as num).toDouble()
        : double.tryParse(json['target']?.toString() ?? '');

    int prog = 0;
    if (json['progress'] != null) {
      prog = json['progress'] is int
          ? json['progress']
          : (int.tryParse(json['progress']?.toString() ?? '0') ?? 0);
    } else if (tgt != null && tgt > 0) {
      prog = ((cur / tgt) * 100).clamp(0, 100).round();
    }

    return GoalItemModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title']?.toString() ?? '',
      targetDate: json['target_date']?.toString() ?? json['deadline']?.toString(),
      progress: prog,
      current: cur,
      target: tgt,
      unit: json['unit']?.toString(),
      status: json['status']?.toString() ?? 'active',
      category: json['category']?.toString(),
    );
  }

  bool get isCompleted => status == 'completed' || progress >= 100;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'current': current,
      'target': target,
      'unit': unit,
      'deadline': targetDate,
      'progress': progress,
      'status': status,
    };
  }
}

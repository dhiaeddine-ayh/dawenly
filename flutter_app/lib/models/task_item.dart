class TaskModel {
  final int id;
  final String title;
  final String? date;
  final String? time;
  final bool done;
  final String? note;
  final String? resources;

  TaskModel({
    required this.id,
    required this.title,
    this.date,
    this.time,
    this.done = false,
    this.note,
    this.resources,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title']?.toString() ?? '',
      date: json['date']?.toString() ?? json['due_date']?.toString(),
      time: json['time']?.toString() ?? json['due_time']?.toString(),
      done: json['done'] == 1 || json['done'] == true || json['status'] == 'done',
      note: json['note']?.toString(),
      resources: json['resources']?.toString(),
    );
  }

  bool get isCompleted => done;
  String? get dueDate => date;

  TaskModel copyWith({bool? done}) {
    return TaskModel(
      id: id,
      title: title,
      date: date,
      time: time,
      done: done ?? this.done,
      note: note,
      resources: resources,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'due_date': date,
      'due_time': time,
      'done': done,
      'status': done ? 'done' : 'pending',
      'note': note,
      'resources': resources,
    };
  }
}

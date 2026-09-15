class TaskModel {
  final int id;
  final String title;
  final String? date;
  final String? time;
  final bool done;

  TaskModel({
    required this.id,
    required this.title,
    this.date,
    this.time,
    this.done = false,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      title: json['title']?.toString() ?? '',
      date: json['date']?.toString(),
      time: json['time']?.toString(),
      done: json['done'] == 1 || json['done'] == true,
    );
  }

  TaskModel copyWith({bool? done}) {
    return TaskModel(
      id: id,
      title: title,
      date: date,
      time: time,
      done: done ?? this.done,
    );
  }
}

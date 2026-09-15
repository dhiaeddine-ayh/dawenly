class UserModel {
  final int id;
  final String email;
  final String name;
  final String? avatar;
  final int streak;
  final bool isOwner;
  final String? today;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.avatar,
    this.streak = 1,
    this.isOwner = false,
    this.today,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 1,
      email: json['email']?.toString() ?? '',
      name: json['name']?.toString() ?? 'مستخدم دوّنلي',
      avatar: json['avatar']?.toString(),
      streak: json['streak'] is int ? json['streak'] : 1,
      isOwner: json['isOwner'] == true || json['is_owner'] == 1,
      today: json['today']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'avatar': avatar,
    'streak': streak,
    'isOwner': isOwner,
    'today': today,
  };
}

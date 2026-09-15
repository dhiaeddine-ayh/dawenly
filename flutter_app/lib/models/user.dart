class UserModel {
  final int id;
  final String email;
  final String name;
  final String? avatar;
  final int? streak;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.avatar,
    this.streak,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      email: json['email']?.toString() ?? '',
      name: json['name']?.toString() ?? json['email']?.toString() ?? 'مستخدم',
      avatar: json['avatar']?.toString(),
      streak: json['streak'] is int ? json['streak'] : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'avatar': avatar,
    'streak': streak,
  };
}

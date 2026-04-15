class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? avatarUrl;
  final bool isActive;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.avatarUrl,
    required this.isActive,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        role: json['role']?.toString() ?? 'user',
        avatarUrl: json['avatar_url']?.toString(),
        isActive: json['is_active'] ?? true,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
        'avatar_url': avatarUrl,
        'is_active': isActive,
      };
}
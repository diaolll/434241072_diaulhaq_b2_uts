class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String department;
  final String? avatar;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone = '',
    required this.role,
    this.department = '',
    this.avatar,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        phone: json['phone']?.toString() ?? '',
        role: json['role']?.toString() ?? 'user',
        department: json['department']?.toString() ?? '',
        avatar: json['avatar']?.toString() ?? json['avatar_url']?.toString(),
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'])
            : DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'role': role,
        'department': department,
        'avatar': avatar,
        'avatar_url': avatar,
        'created_at': createdAt.toIso8601String(),
      };

  // Computed properties
  String get initials => name
      .split(' ')
      .where((s) => s.isNotEmpty)
      .map((s) => s[0].toUpperCase())
      .take(2)
      .join();

  String get displayName => name;
  bool get isAdmin => role == 'admin';
  bool get isSupport => role == 'support' || role == 'admin';
}
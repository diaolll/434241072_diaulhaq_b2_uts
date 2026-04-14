class UserEntity {
  final int id;
  final String username;
  final String email;
  final String fullName;
  final String? phone;
  final String role;
  final String? avatar;
  final String status;

  UserEntity({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    this.phone,
    required this.role,
    this.avatar,
    required this.status,
  });

  bool get isAdmin => role == 'admin';
  bool get isActive => status == 'active';
}

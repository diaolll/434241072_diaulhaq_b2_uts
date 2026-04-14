import 'user_model.dart';

class CommentModel {
  final int id;
  final int ticketId;
  final String content;
  final bool isInternal;
  final DateTime createdAt;
  final UserModel user;

  CommentModel({
    required this.id,
    required this.ticketId,
    required this.content,
    required this.isInternal,
    required this.createdAt,
    required this.user,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] ?? 0,
      ticketId: json['ticket_id'] ?? 0,
      content: json['content'] ?? '',
      isInternal: json['is_internal'] ?? false,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      user: json['user'] != null ? UserModel.fromJson(json['user']) : UserModel.fromJson({}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticket_id': ticketId,
      'content': content,
      'is_internal': isInternal,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

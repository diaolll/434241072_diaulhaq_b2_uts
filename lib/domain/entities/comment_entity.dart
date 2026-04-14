import 'user_entity.dart';

class CommentEntity {
  final int id;
  final int ticketId;
  final String content;
  final bool isInternal;
  final DateTime createdAt;
  final UserEntity user;

  CommentEntity({
    required this.id,
    required this.ticketId,
    required this.content,
    required this.isInternal,
    required this.createdAt,
    required this.user,
  });
}

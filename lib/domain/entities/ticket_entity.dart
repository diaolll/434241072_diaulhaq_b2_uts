import 'user_entity.dart';

class TicketEntity {
  final int id;
  final String title;
  final String description;
  final String category;
  final String priority;
  final String status;
  final int? assignedTo;
  final int createdBy;
  final List<String> attachments;
  final String? location;
  final String? evidenceUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserEntity? creator;
  final UserEntity? assignee;
  final int commentCount;

  TicketEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.status,
    this.assignedTo,
    required this.createdBy,
    required this.attachments,
    this.location,
    this.evidenceUrl,
    required this.createdAt,
    required this.updatedAt,
    this.creator,
    this.assignee,
    this.commentCount = 0,
  });

  bool get isOpen => status == 'open';
  bool get isInProgress => status == 'in_progress';
  bool get isResolved => status == 'resolved';
  bool get isClosed => status == 'closed';

  String get statusDisplay {
    switch (status) {
      case 'open':
        return 'Open';
      case 'in_progress':
        return 'In Progress';
      case 'resolved':
        return 'Resolved';
      case 'closed':
        return 'Closed';
      default:
        return status;
    }
  }

  String get priorityDisplay {
    switch (priority) {
      case 'low':
        return 'Low';
      case 'medium':
        return 'Medium';
      case 'high':
        return 'High';
      default:
        return priority;
    }
  }
}

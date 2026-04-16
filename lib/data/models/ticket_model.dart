import 'user_model.dart';

class TicketModel {
  final String id;
  final String ticketNo;
  final String title;
  final String description;
  final String? category;
  final String priority;
  final String status;
  final String userId;
  final String? assignedTo;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserModel? user;
  final UserModel? assignee;
  final List<AttachmentModel> attachments;
  final List<CommentModel> comments;
  final List<HistoryModel> history;

  TicketModel({
    required this.id,
    required this.ticketNo,
    required this.title,
    required this.description,
    this.category,
    required this.priority,
    required this.status,
    required this.userId,
    this.assignedTo,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.assignee,
    this.attachments = const [],
    this.comments = const [],
    this.history = const [],
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    // Handle both 'attachments' and 'ticket_attachments' keys
    final attachmentsList = json['attachments'] ?? json['ticket_attachments'] ?? [];

    return TicketModel(
      id: json['id']?.toString() ?? '',
      ticketNo: json['ticket_no']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      category: json['category'],
      priority: json['priority']?.toString() ?? 'medium',
      status: json['status']?.toString() ?? 'open',
      userId: json['user_id']?.toString() ?? '',
      assignedTo: json['assigned_to'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : DateTime.now(),
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      assignee: json['assignee'] != null ? UserModel.fromJson(json['assignee']) : null,
      attachments: (attachmentsList as List? ?? [])
          .map((e) => AttachmentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      comments: (json['comments'] as List? ?? [])
          .map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      history: (json['history'] as List? ?? [])
          .map((e) => HistoryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // Computed getters for display
  String get statusDisplay {
    switch (status.toLowerCase()) {
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
    switch (priority.toLowerCase()) {
      case 'high':
        return 'High';
      case 'medium':
        return 'Medium';
      case 'low':
        return 'Low';
      case 'critical':
        return 'Critical';
      default:
        return priority;
    }
  }
}

class AttachmentModel {
  final String id;
  final String ticketId;
  final String fileUrl;
  final String fileName;
  final String fileType;
  final DateTime createdAt;

  AttachmentModel({
    required this.id,
    required this.ticketId,
    required this.fileUrl,
    required this.fileName,
    required this.fileType,
    required this.createdAt,
  });

  factory AttachmentModel.fromJson(Map<String, dynamic> json) => AttachmentModel(
        id: json['id']?.toString() ?? '',
        ticketId: json['ticket_id']?.toString() ?? '',
        fileUrl: json['file_url']?.toString() ?? '',
        fileName: json['file_name']?.toString() ?? '',
        fileType: json['file_type']?.toString() ?? '',
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'].toString())
            : DateTime.now(),
      );
}

class CommentModel {
  final String id;
  final String ticketId;
  final String userId;
  final String content;
  final DateTime createdAt;
  final UserModel? user;

  CommentModel({
    required this.id,
    required this.ticketId,
    required this.userId,
    required this.content,
    required this.createdAt,
    this.user,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) => CommentModel(
        id: json['id']?.toString() ?? '',
        ticketId: json['ticket_id']?.toString() ?? '',
        userId: json['user_id']?.toString() ?? '',
        content: json['content']?.toString() ?? '',
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'].toString())
            : DateTime.now(),
        user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      );
}

class HistoryModel {
  final String id;
  final String ticketId;
  final String changedBy;
  final String oldStatus;
  final String newStatus;
  final String note;
  final DateTime createdAt;
  final UserModel? user;

  HistoryModel({
    required this.id,
    required this.ticketId,
    required this.changedBy,
    required this.oldStatus,
    required this.newStatus,
    required this.note,
    required this.createdAt,
    this.user,
  });

  factory HistoryModel.fromJson(Map<String, dynamic> json) => HistoryModel(
        id: json['id']?.toString() ?? '',
        ticketId: json['ticket_id']?.toString() ?? '',
        changedBy: json['changed_by']?.toString() ?? '',
        oldStatus: json['old_status'] ?? '',
        newStatus: json['new_status'] ?? '',
        note: json['note'] ?? '',
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'].toString())
            : DateTime.now(),
        user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      );
}

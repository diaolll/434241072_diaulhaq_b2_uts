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

  factory TicketModel.fromJson(Map<String, dynamic> json) => TicketModel(
        id: json['id'],
        ticketNo: json['ticket_no'],
        title: json['title'],
        description: json['description'],
        category: json['category'],
        priority: json['priority'],
        status: json['status'],
        userId: json['user_id'],
        assignedTo: json['assigned_to'],
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: DateTime.parse(json['updated_at']),
        user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
        assignee: json['assignee'] != null ? UserModel.fromJson(json['assignee']) : null,
        attachments: (json['attachments'] as List? ?? [])
            .map((e) => AttachmentModel.fromJson(e))
            .toList(),
        comments: (json['comments'] as List? ?? [])
            .map((e) => CommentModel.fromJson(e))
            .toList(),
        history: (json['history'] as List? ?? [])
            .map((e) => HistoryModel.fromJson(e))
            .toList(),
      );
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
        id: json['id'],
        ticketId: json['ticket_id'],
        fileUrl: json['file_url'],
        fileName: json['file_name'],
        fileType: json['file_type'],
        createdAt: DateTime.parse(json['created_at']),
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
        id: json['id'],
        ticketId: json['ticket_id'],
        userId: json['user_id'],
        content: json['content'],
        createdAt: DateTime.parse(json['created_at']),
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
        id: json['id'],
        ticketId: json['ticket_id'],
        changedBy: json['changed_by'],
        oldStatus: json['old_status'] ?? '',
        newStatus: json['new_status'] ?? '',
        note: json['note'] ?? '',
        createdAt: DateTime.parse(json['created_at']),
        user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      );
}

// Re-import UserModel here or put in same file
import 'user_model.dart'; // jika pisah file
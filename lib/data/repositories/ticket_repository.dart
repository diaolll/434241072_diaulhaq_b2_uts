import 'package:dio/dio.dart';
import '../datasources/api_client.dart';
import '../models/ticket_model.dart';
import '../../core/constants/api_constants.dart';

class TicketRepository {
  final _api = ApiClient().dio;

  Future<Map<String, dynamic>> getTickets({int page = 1, int limit = 10}) async {
    final res = await _api.get(ApiConstants.tickets, queryParameters: {
      'page': page,
      'limit': limit,
    });
    final data = res.data['data'] as List;
    return {
      'tickets': data.map((e) => TicketModel.fromJson(e)).toList(),
      'total': res.data['total'],
    };
  }

  Future<TicketModel> getTicketById(String id) async {
    final res = await _api.get(ApiConstants.ticketById(id));
    return TicketModel.fromJson(res.data['data']);
  }

  Future<TicketModel> createTicket({
    required String title,
    required String description,
    String? category,
    String? priority,
  }) async {
    final res = await _api.post(ApiConstants.tickets, data: {
      'title': title,
      'description': description,
      'category': category ?? '',
      'priority': priority ?? 'medium',
    });
    return TicketModel.fromJson(res.data['data']);
  }

  Future<void> updateStatus(String id, String status, String note) async {
    await _api.put(ApiConstants.ticketStatus(id), data: {
      'status': status,
      'note': note,
    });
  }

  Future<void> assignTicket(String id, String assignTo) async {
    await _api.put(ApiConstants.ticketAssign(id), data: {'assign_to': assignTo});
  }

  Future<void> addComment(String ticketId, String content) async {
    await _api.post(ApiConstants.ticketComments(ticketId), data: {'content': content});
  }

  Future<String> uploadAttachment(String ticketId, String filePath, String fileName) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
    });
    final res = await _api.post(
      ApiConstants.ticketAttachments(ticketId),
      data: formData,
    );
    return res.data['url'];
  }

  Future<Map<String, int>> getDashboardStats() async {
    final res = await _api.get(ApiConstants.dashboardStats);
    final data = res.data['data'] as Map<String, dynamic>;
    return data.map((k, v) => MapEntry(k, (v as num).toInt()));
  }

  Future<List<dynamic>> getNotifications() async {
    final res = await _api.get(ApiConstants.notifications);
    return res.data['data'] as List;
  }

  Future<void> markNotifRead(String id) async {
    await _api.put(ApiConstants.markRead(id));
  }
}
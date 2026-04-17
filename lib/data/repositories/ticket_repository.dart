import '../models/ticket_model.dart';
import '../../core/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TicketRepository {
  final _client = SupabaseService.client;

  /// Get current user ID from Supabase Auth (RLS friendly)
  String? get _currentUserId => _client.auth.currentUser?.id;

  /// Get current user role from SharedPreferences (synced from users table)
  Future<String> get _currentRole async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_role') ?? 'user';
  }

  /// Check if current user is admin/helpdesk
  Future<bool> get _isAdmin async {
    final role = await _currentRole;
    return role == 'admin' || role == 'helpdesk';
  }

  /// Get all tickets - admin/helpdesk see all, users see own
  Future<List<TicketModel>> getTickets() async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('User not authenticated');

    final role = await _currentRole;
    final isAdmin = await _isAdmin;

    print('🎫 GetTickets: userId=$userId, role=$role, isAdmin=$isAdmin');

    try {
      // Admin/Helpdesk lihat semua tiket, user biasa hanya milik sendiri
      final response = await _client
          .from('tickets')
          .select()
          .order('created_at', ascending: false);

      print('🎫 Raw response count: ${response.length}');

      final List filtered = isAdmin
          ? response as List
          : (response as List).where((t) => t['user_id'] == userId).toList();

      print('🎫 Filtered count: ${filtered.length}');

      return filtered.map((e) => TicketModel.fromJson(e)).toList();
    } catch (e) {
      print('❌ GetTickets error: $e');
      rethrow;
    }
  }

  /// Get ticket by ID - include attachments, comments, and history
  Future<TicketModel> getTicketById(String id) async {
    try {
      // Fetch ticket dengan comments, attachments (tanpa relationship syntax)
      final response = await _client
          .from('tickets')
          .select('''
            *,
            ticket_attachments(*),
            comments(*)
          ''')
          .eq('id', id)
          .maybeSingle();

      if (response == null) {
        throw Exception('Ticket not found: $id');
      }

      // Ambil semua user_id dari comments dan history
      final comments = response['comments'] as List? ?? [];
      print('💬 Comments count: ${comments.length}');

      // Fetch assignee data separately
      final assignedTo = response['assigned_to'] as String?;
      Map<String, dynamic>? assigneeData;
      if (assignedTo != null) {
        try {
          final assignee = await _client
              .from('users')
              .select('id, name, email')
              .eq('id', assignedTo)
              .maybeSingle();
          assigneeData = assignee;
          print('👤 Assignee: ${assignee?['name']}');
        } catch (e) {
          print('⚠️ Failed to fetch assignee: $e');
        }
      }
      response['assignee'] = assigneeData;

      // Fetch ticket history
      final history = await _client
          .from('ticket_history')
          .select('*')
          .eq('ticket_id', id)
          .order('created_at', ascending: false);

      print('📜 History count: ${history.length}');
      response['history'] = history;

      final userIds = comments
          .map((c) => c['user_id'] as String?)
          .where((id) => id != null)
          .toSet()
          .cast<String>()
          .toList();

      // Tambahkan user_id dari history
      for (var h in history) {
        final changerId = h['changed_by'] as String?;
        if (changerId != null) userIds.add(changerId);
      }

      print('👤 User IDs from comments & history: $userIds');

      // Fetch data user untuk setiap user_id
      Map<String, Map<String, dynamic>> usersData = {};
      if (userIds.isNotEmpty) {
        final users = await _client
            .from('users')
            .select('id, name, email')
            .inFilter('id', userIds);

        print('📦 Users data fetched: ${users.length} users');

        for (var user in users) {
          usersData[user['id']] = user;
          print('   - ${user['id']}: ${user['name']}');
        }
      }

      // Inject data user ke dalam comments
      for (var comment in comments) {
        final userId = comment['user_id'] as String?;
        if (userId != null && usersData.containsKey(userId)) {
          comment['user'] = usersData[userId];
        }
      }

      // Inject data user ke dalam history
      for (var h in history) {
        final changerId = h['changed_by'] as String?;
        if (changerId != null && usersData.containsKey(changerId)) {
          h['user'] = usersData[changerId];
        }
      }

      return TicketModel.fromJson(response);
    } catch (e) {
      print('❌ Error loading ticket: $e');
      throw Exception('Failed to load ticket: $e');
    }
  }

  /// Create new ticket - hanya role 'user' yang bisa membuat tiket
  Future<TicketModel> createTicket({
    required String title,
    required String description,
    String? category,
    String priority = 'medium',
  }) async {
    final userId = _currentUserId;
    if (userId == null) {
      print('❌ User not authenticated');
      throw Exception('User not authenticated. Please login first.');
    }

    // Cek role - hanya user biasa yang bisa buat tiket
    final role = await _currentRole;
    if (role != 'user') {
      print('❌ Only regular users can create tickets. Current role: $role');
      throw Exception('Hanya user biasa yang dapat membuat tiket. Admin dan Helpdesk tidak perlu membuat tiket.');
    }

    print('📝 Creating ticket: userId=$userId, title=$title');

    // Generate ticket number
    final ticketNo = 'TKT-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';

    try {
      // Insert ticket
      final response = await _client
          .from('tickets')
          .insert({
            'ticket_no': ticketNo,
            'title': title,
            'description': description,
            'category': category,
            'priority': priority,
            'status': 'open',
            'user_id': userId,
          })
          .select()
          .single();

      print('✅ Ticket created: ${response['id']}');

      // Create notification for admin/helpdesk (non-blocking, fire and forget)
      _createNotificationForAdmins(
        title: 'Tiket Baru',
        message: 'Tiket #$ticketNo: $title',
        ticketId: response['id'],
        type: 'info',
      );

      return TicketModel.fromJson(response);
    } on PostgrestException catch (e) {
      print('❌ Supabase error: ${e.message} - ${e.details}');
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      print('❌ Create ticket error: $e');
      throw Exception('Failed to create ticket: $e');
    }
  }

  /// Update ticket status
  Future<void> updateStatus(String id, String status, String note) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('User not authenticated');

    // Update ticket status
    await _client
        .from('tickets')
        .update({'status': status})
        .eq('id', id);

    // Add to history
    await _client.from('ticket_history').insert({
      'ticket_id': id,
      'changed_by': userId,
      'old_status': '',
      'new_status': status,
      'note': note,
    });

    // Get ticket details for notification
    final ticket = await _client.from('tickets').select('*').eq('id', id).single();
    final ticketNo = ticket['ticket_no'] ?? '';
    final title = ticket['title'] ?? '';

    // Notify ticket creator
    await createNotification(
      userId: ticket['user_id'],
      title: 'Status Tiket Diubah',
      message: 'Tiket #$ticketNo: $title - Status sekarang: $status',
      ticketId: id,
      type: status == 'resolved' ? 'success' : 'info',
    );
  }

  /// Assign ticket to user
  Future<void> assignTicket(String id, String assignTo) async {
    await _client
        .from('tickets')
        .update({'assigned_to': assignTo})
        .eq('id', id);

    // Notify assigned user
    await createNotification(
      userId: assignTo,
      title: 'Tiket Ditugaskan',
      message: 'Anda telah ditugaskan untuk tiket #$id',
      ticketId: id,
      type: 'info',
    );
  }

  /// Get ticket history
  Future<List<Map<String, dynamic>>> getTicketHistory(String ticketId) async {
    final response = await _client
        .from('ticket_history')
        .select('''
          *,
          users(name)
        ''')
        .eq('ticket_id', ticketId)
        .order('created_at', ascending: false);

    return (response as List).cast<Map<String, dynamic>>();
  }

  /// Add comment to ticket
  Future<void> addComment(String ticketId, String content) async {
    final userId = _currentUserId;
    if (userId == null) {
      print('❌ User not authenticated');
      throw Exception('User not authenticated. Please login first.');
    }

    print('💬 Adding comment: ticketId=$ticketId, userId=$userId');

    try {
      await _client.from('comments').insert({
        'ticket_id': ticketId,
        'user_id': userId,
        'content': content,
      });
      print('✅ Comment added');

      // Get ticket details & notify (non-blocking)
      try {
        final ticket = await _client.from('tickets').select('*').eq('id', ticketId).maybeSingle();
        if (ticket != null) {
          final ticketCreatorId = ticket['user_id'];
          final assignedTo = ticket['assigned_to'];
          final ticketNo = ticket['ticket_no'] ?? '';

          // Notify ticket creator if comment not from creator
          if (ticketCreatorId != null && ticketCreatorId != userId) {
            createNotification(
              userId: ticketCreatorId,
              title: 'Komentar Baru',
              message: 'Ada komentar baru pada tiket #$ticketNo',
              ticketId: ticketId,
              type: 'info',
            );
          }

          // Notify assigned user if different
          if (assignedTo != null && assignedTo != userId && assignedTo != ticketCreatorId) {
            createNotification(
              userId: assignedTo,
              title: 'Komentar Baru',
              message: 'Ada komentar baru pada tiket #$ticketNo',
              ticketId: ticketId,
              type: 'info',
            );
          }
        }
      } catch (e) {
        print('⚠️ Notification error (ignored): $e');
      }
    } on PostgrestException catch (e) {
      print('❌ Supabase error: ${e.message} - ${e.details}');
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      print('❌ Add comment error: $e');
      throw Exception('Failed to add comment: $e');
    }
  }

  /// Save attachment metadata after uploading to Supabase Storage
  Future<void> saveAttachmentMetadata({
    required String ticketId,
    required String fileUrl,
    required String fileName,
    required String fileType,
  }) async {
    try {
      print('💾 Saving metadata: ticketId=$ticketId, file=$fileName');

      final response = await _client
          .from('ticket_attachments')
          .insert({
            'ticket_id': ticketId,
            'file_url': fileUrl,
            'file_name': fileName,
            'file_type': fileType,
          })
          .select();

      print('✅ Metadata saved: $response');
    } catch (e) {
      print('❌ FAILED to save metadata: $e');
      rethrow;
    }
  }

  /// Get dashboard stats - for admin/helpdesk, return all tickets
  Future<Map<String, int>> getDashboardStats() async {
    final userId = _currentUserId;
    if (userId == null) return {};

    final isAdmin = await _isAdmin;

    final response = await _client
        .from('tickets')
        .select('status, user_id');

    // Filter: admin/helpdesk lihat semua, user biasa hanya milik sendiri
    final List filtered = isAdmin
        ? response as List
        : (response as List).where((t) => t['user_id'] == userId).toList();

    final stats = <String, int>{
      'total': filtered.length,
      'open': 0,
      'in_progress': 0,
      'resolved': 0,
      'closed': 0,
    };

    for (var ticket in filtered) {
      final status = ticket['status'] as String;
      stats[status] = (stats[status] ?? 0) + 1;
    }

    return stats;
  }

  /// Get notifications for current user
  Future<List<dynamic>> getNotifications() async {
    final userId = _currentUserId;
    if (userId == null) return [];

    final response = await _client
        .from('notifications')
        .select('*')
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(50);

    return response as List;
  }

  /// Get list of helpdesk users for assignment
  Future<List<Map<String, dynamic>>> getHelpdeskList() async {
    final response = await _client
        .from('users')
        .select('id, name, email')
        .or('role.eq.helpdesk,role.eq.admin')
        .order('name');

    return (response as List).cast<Map<String, dynamic>>();
  }

  /// Mark notification as read
  Future<void> markNotifRead(String id) async {
    await _client
        .from('notifications')
        .update({'is_read': true})
        .eq('id', id);
  }

  /// Create notification for a user
  Future<void> createNotification({
    required String userId,
    required String title,
    required String message,
    String? ticketId,
    String type = 'info',
  }) async {
    try {
      await _client.from('notifications').insert({
        'user_id': userId,
        'ticket_id': ticketId,
        'title': title,
        'message': message,
        'type': type,
        'is_read': false,
      });
    } catch (e) {
      print('❌ Failed to create notification: $e');
    }
  }

  /// Create notification for all admins and helpdesk
  Future<void> _createNotificationForAdmins({
    required String title,
    required String message,
    String? ticketId,
    String type = 'info',
  }) async {
    try {
      // Get all admin and helpdesk users
      final admins = await _client
          .from('users')
          .select('id')
          .or('role.eq.admin,role.eq.helpdesk');

      final List adminIds = (admins as List).map((u) => u['id']).toList();

      // Create notification for each admin
      for (final adminId in adminIds) {
        await createNotification(
          userId: adminId,
          title: title,
          message: message,
          ticketId: ticketId,
          type: type,
        );
      }
    } catch (e) {
      print('❌ Failed to create admin notifications: $e');
    }
  }
}

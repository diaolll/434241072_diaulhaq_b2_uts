import '../models/ticket_model.dart';
import '../models/user_model.dart';

/// Mock Data Service for UI Preview
/// Provides dummy data for development and testing
class MockDataService {
  static final MockDataService _instance = MockDataService._internal();
  factory MockDataService() => _instance;
  MockDataService._internal();

  // ==================== USER DATA ====================
  UserModel? _currentUser;

  UserModel get currentUser {
    _currentUser ??= UserModel(
      id: 'user_001',
      name: 'John Doe',
      email: 'john.doe@example.com',
      phone: '+62 812 3456 7890',
      role: 'user',
      department: 'Engineering',
      avatar: null,
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
    );
    return _currentUser!;
  }

  void setCurrentUser(UserModel user) {
    _currentUser = user;
  }

  // ==================== TICKET DATA ====================
  final List<TicketModel> _tickets = [
    TicketModel(
      id: 'tk_001',
      ticketNo: 'TKT-2024-001',
      title: 'WiFi tidak dapat terhubung di lantai 3',
      description: 'Saya tidak dapat terhubung ke WiFi kantor di lantai 3 bagian selatan. '
          'Sudah mencoba restart dan forget network tapi tetap tidak bisa. '
          'Mohon bantuannya segera karena ada deadline project.',
      category: 'Network',
      priority: 'high',
      status: 'open',
      userId: 'user_001',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      comments: [
        CommentModel(
          id: 'cm_001',
          ticketId: 'tk_001',
          userId: 'user_001',
          content: 'Mohon segera diproses, terima kasih.',
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
      ],
      attachments: [],
    ),
    TicketModel(
      id: 'tk_002',
      ticketNo: 'TKT-2024-002',
      title: 'Monitor tidak menampilkan gambar',
      description: 'Monitor LG 24" saya tiba-tiba blank screen. '
          'Power indicator menyala tapi tidak ada tampilan sama sekali.',
      category: 'Hardware',
      priority: 'medium',
      status: 'in_progress',
      userId: 'user_001',
      assignedTo: 'tech_001',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 6)),
      comments: [
        CommentModel(
          id: 'cm_002',
          ticketId: 'tk_002',
          userId: 'tech_001',
          content: 'Sedang kami cek, kemungkinan kabel VGA loose.',
          createdAt: DateTime.now().subtract(const Duration(hours: 12)),
          user: UserModel(
            id: 'tech_001',
            name: 'Support Team',
            email: 'support@company.com',
            phone: '',
            role: 'support',
            department: 'IT Support',
            avatar: null,
            createdAt: DateTime.now(),
          ),
        ),
        CommentModel(
          id: 'cm_003',
          ticketId: 'tk_002',
          userId: 'user_001',
          content: 'Baik, saya tunggu update nya.',
          createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        ),
      ],
      attachments: [],
    ),
    TicketModel(
      id: 'tk_003',
      ticketNo: 'TKT-2024-003',
      title: 'Aplikasi ERP error saat login',
      description: 'Setelah update aplikasi ERP versi terbaru, saya tidak bisa login. '
          'Muncul pesan error: "Invalid credentials" padahal password sudah benar. '
          'Mohon bantuannya untuk reset password atau cek sistem.',
      category: 'Software',
      priority: 'high',
      status: 'open',
      userId: 'user_001',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
      comments: [],
      attachments: [],
    ),
    TicketModel(
      id: 'tk_004',
      ticketNo: 'TKT-2024-004',
      title: 'Request install software tambahan',
      description: 'Saya butuh install Adobe Creative Cloud untuk keperluan design. '
          'Mohon approval dan bantuan installasi.',
      category: 'Software',
      priority: 'low',
      status: 'resolved',
      userId: 'user_001',
      assignedTo: 'tech_002',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      comments: [
        CommentModel(
          id: 'cm_004',
          ticketId: 'tk_004',
          userId: 'tech_002',
          content: 'Software sudah diinstall. Silakan dicoba.',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          user: UserModel(
            id: 'tech_002',
            name: 'Admin IT',
            email: 'admin@company.com',
            phone: '',
            role: 'admin',
            department: 'IT',
            avatar: null,
            createdAt: DateTime.now(),
          ),
        ),
      ],
      attachments: [],
    ),
    TicketModel(
      id: 'tk_005',
      ticketNo: 'TKT-2024-005',
      title: 'Printer lantai 2 paper jam',
      description: 'Printer HP lantai 2 mengalami paper jam. '
          'Sudah coba buka cover tapi kertas tidak kelihatan. '
          'Mohon bantuan teknisi.',
      category: 'Hardware',
      priority: 'medium',
      status: 'resolved',
      userId: 'user_001',
      assignedTo: 'tech_001',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now().subtract(const Duration(days: 4)),
      comments: [
        CommentModel(
          id: 'cm_005',
          ticketId: 'tk_005',
          userId: 'tech_001',
          content: 'Kertas sudah berhasil dikeluarkan. Printer normal kembali.',
          createdAt: DateTime.now().subtract(const Duration(days: 4)),
          user: UserModel(
            id: 'tech_001',
            name: 'Support Team',
            email: 'support@company.com',
            phone: '',
            role: 'support',
            department: 'IT Support',
            avatar: null,
            createdAt: DateTime.now(),
          ),
        ),
      ],
      attachments: [],
    ),
    TicketModel(
      id: 'tk_006',
      ticketNo: 'TKT-2024-006',
      title: 'Email tidak bisa sinkron',
      description: 'Email Outlook saya tidak sinkron sejak jam 9 pagi. '
          'Email masuk tidak muncul dan email keluar stuck di outbox.',
      category: 'Network',
      priority: 'medium',
      status: 'closed',
      userId: 'user_001',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      updatedAt: DateTime.now().subtract(const Duration(days: 6)),
      comments: [],
      attachments: [],
    ),
  ];

  // ==================== GET METHODS ====================
  List<TicketModel> getTickets() => List.from(_tickets);

  List<TicketModel> getTicketsByStatus(String status) {
    return _tickets.where((t) => t.status == status).toList();
  }

  TicketModel? getTicketById(String id) {
    try {
      return _tickets.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  Map<String, int> getDashboardStats() {
    return {
      'total': _tickets.length,
      'open': _tickets.where((t) => t.status == 'open').length,
      'in_progress': _tickets.where((t) => t.status == 'in_progress').length,
      'resolved': _tickets.where((t) => t.status == 'resolved').length,
      'closed': _tickets.where((t) => t.status == 'closed').length,
    };
  }

  // ==================== CREATE/UPDATE METHODS ====================
  TicketModel createTicket({
    required String title,
    required String description,
    String? category,
    String priority = 'medium',
    String? imagePath,
  }) {
    final ticket = TicketModel(
      id: 'tk_${DateTime.now().millisecondsSinceEpoch}',
      ticketNo: 'TKT-2024-${_tickets.length + 1}',
      title: title,
      description: description,
      category: category ?? 'General',
      priority: priority,
      status: 'open',
      userId: currentUser.id,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      comments: [],
      attachments: [],
    );
    _tickets.insert(0, ticket);
    return ticket;
  }

  TicketModel updateTicketStatus(String ticketId, String newStatus) {
    final index = _tickets.indexWhere((t) => t.id == ticketId);
    if (index == -1) throw Exception('Ticket not found');

    final updated = _tickets[index];
    final newTicket = TicketModel(
      id: updated.id,
      ticketNo: updated.ticketNo,
      title: updated.title,
      description: updated.description,
      category: updated.category,
      priority: updated.priority,
      status: newStatus,
      userId: updated.userId,
      assignedTo: updated.assignedTo,
      createdAt: updated.createdAt,
      updatedAt: DateTime.now(),
      user: updated.user,
      assignee: updated.assignee,
      comments: updated.comments,
      attachments: updated.attachments,
    );
    _tickets[index] = newTicket;
    return newTicket;
  }

  CommentModel addComment({
    required String ticketId,
    required String content,
  }) {
    final index = _tickets.indexWhere((t) => t.id == ticketId);
    if (index == -1) throw Exception('Ticket not found');

    final ticket = _tickets[index];
    final comment = CommentModel(
      id: 'cm_${DateTime.now().millisecondsSinceEpoch}',
      ticketId: ticketId,
      userId: currentUser.id,
      content: content,
      createdAt: DateTime.now(),
      user: currentUser,
    );

    final updatedComments = [...ticket.comments, comment];
    _tickets[index] = TicketModel(
      id: ticket.id,
      ticketNo: ticket.ticketNo,
      title: ticket.title,
      description: ticket.description,
      category: ticket.category,
      priority: ticket.priority,
      status: ticket.status,
      userId: ticket.userId,
      assignedTo: ticket.assignedTo,
      createdAt: ticket.createdAt,
      updatedAt: DateTime.now(),
      user: ticket.user,
      assignee: ticket.assignee,
      comments: updatedComments,
      attachments: ticket.attachments,
    );

    return comment;
  }

  // ==================== AUTH METHODS ====================
  bool login(String email, String password) {
    // Mock login - accept any email with password length >= 6
    if (password.length >= 6) {
      _currentUser = UserModel(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        name: email.split('@')[0].replaceAll('.', ' ').capitalize(),
        email: email,
        phone: '+62 812 3456 7890',
        role: 'user',
        department: 'Engineering',
        avatar: null,
        createdAt: DateTime.now(),
      );
      return true;
    }
    return false;
  }

  bool register({
    required String name,
    required String email,
    required String password,
  }) {
    // Mock register
    if (password.length >= 6) {
      _currentUser = UserModel(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        email: email,
        phone: '',
        role: 'user',
        department: '',
        avatar: null,
        createdAt: DateTime.now(),
      );
      return true;
    }
    return false;
  }

  void logout() {
    _currentUser = null;
  }

  // ==================== SEARCH METHODS ====================
  List<TicketModel> searchTickets(String query) {
    if (query.isEmpty) return _tickets;
    final lowerQuery = query.toLowerCase();
    return _tickets.where((t) =>
      t.title.toLowerCase().contains(lowerQuery) ||
      t.description.toLowerCase().contains(lowerQuery) ||
      t.ticketNo.toLowerCase().contains(lowerQuery)
    ).toList();
  }
}

// String extension for capitalization
extension StringExtension on String {
  String capitalize() {
    return split(' ')
        .map((word) => word.isEmpty ? '' : '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/ticket_repository.dart';
import '../repositories/auth_repository.dart';
import '../models/ticket_model.dart';
import '../models/user_model.dart';

// ==================== REPOSITORY PROVIDERS ====================
final ticketRepoProvider = Provider<TicketRepository>((ref) {
  return TicketRepository();
});

final authRepoProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

// ==================== AUTH PROVIDERS ====================
final authStateProvider = StateProvider<bool>((ref) => false);

final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final authRepo = ref.watch(authRepoProvider);
  final userId = await authRepo.getUserId();
  final name = await authRepo.getUserName();
  final email = await authRepo.getUserEmail();
  final role = await authRepo.getRole();

  if (userId == null && name == null && email == null) {
    return null;
  }

  return UserModel(
    id: userId ?? '1',
    name: name ?? 'User',
    email: email ?? '',
    role: role ?? 'user',
    createdAt: DateTime.now(),
  );
});

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepo = ref.read(authRepoProvider);
  return AuthNotifier(authRepo);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepo;

  AuthNotifier(this._authRepo) : super(AuthState.initial());

  bool get isAuthenticated => state.isAuthenticated;
  UserModel? get user => state.user;

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true);

    try {
      final result = await _authRepo.login(email, password);
      final user = result['user'] as UserModel;

      state = AuthState.authenticated(user);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true);

    try {
      final user = await _authRepo.register(name, email, password);
      state = AuthState.authenticated(user);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    await _authRepo.logout();
    state = AuthState.initial();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

class AuthState {
  final bool isAuthenticated;
  final UserModel? user;
  final bool isLoading;
  final String? error;

  AuthState({
    required this.isAuthenticated,
    this.user,
    this.isLoading = false,
    this.error,
  });

  factory AuthState.initial() => AuthState(isAuthenticated: false);

  factory AuthState.authenticated(UserModel user) => AuthState(
        isAuthenticated: true,
        user: user,
      );

  AuthState copyWith({
    bool? isAuthenticated,
    UserModel? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// ==================== TICKET PROVIDERS ====================
final ticketsProvider = StateNotifierProvider<TicketsNotifier, TicketsState>((ref) {
  final repo = ref.read(ticketRepoProvider);
  return TicketsNotifier(repo);
});

final ticketListProvider = Provider<List<TicketModel>>((ref) {
  return ref.watch(ticketsProvider).tickets;
});

final ticketStatsProvider = Provider<Map<String, int>>((ref) {
  return ref.watch(ticketsProvider).stats;
});

final filteredTicketsProvider = Provider.family<List<TicketModel>, String?>((ref, status) {
  final allTickets = ref.watch(ticketListProvider);
  if (status == null || status == 'all') return allTickets;
  return allTickets.where((t) => t.status == status).toList();
});

class TicketsNotifier extends StateNotifier<TicketsState> {
  final TicketRepository _repo;

  TicketsNotifier(this._repo) : super(TicketsState.initial()) {
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    state = state.copyWith(isLoading: true);

    try {
      final tickets = await _repo.getTickets();
      final stats = await _repo.getDashboardStats();

      state = state.copyWith(
        tickets: tickets,
        stats: stats,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        tickets: [],
        stats: {},
      );
    }
  }

  Future<void> refresh() async {
    await _loadTickets();
  }

  List<TicketModel> searchTickets(String query) {
    final lowerQuery = query.toLowerCase();
    return state.tickets.where((t) =>
      t.title.toLowerCase().contains(lowerQuery) ||
      t.description.toLowerCase().contains(lowerQuery) ||
      (t.category?.toLowerCase().contains(lowerQuery) ?? false)
    ).toList();
  }

  TicketModel? getTicketById(String id) {
    try {
      // First try to find in cached tickets
      final cached = state.tickets.firstWhere((t) => t.id == id);
      return cached;
    } catch (_) {
      return null;
    }
  }

  Future<TicketModel> createTicket({
    required String title,
    required String description,
    String? category,
    String priority = 'medium',
  }) async {
    state = state.copyWith(isSubmitting: true);

    try {
      final ticket = await _repo.createTicket(
        title: title,
        description: description,
        category: category,
        priority: priority,
      );

      // Refresh tickets after creating
      await _loadTickets();

      state = state.copyWith(isSubmitting: false);
      return ticket;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> updateTicketStatus(String ticketId, String newStatus, {String? note}) async {
    state = state.copyWith(isSubmitting: true);

    try {
      await _repo.updateStatus(ticketId, newStatus, note ?? '');
      await _loadTickets();
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> addComment({
    required String ticketId,
    required String content,
  }) async {
    state = state.copyWith(isSubmitting: true);

    try {
      await _repo.addComment(ticketId, content);
      await _loadTickets();
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
      rethrow;
    }
  }
}

class TicketsState {
  final List<TicketModel> tickets;
  final Map<String, int> stats;
  final bool isLoading;
  final bool isSubmitting;
  final String? error;

  TicketsState({
    this.tickets = const [],
    this.stats = const {},
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
  });

  factory TicketsState.initial() => TicketsState();

  TicketsState copyWith({
    List<TicketModel>? tickets,
    Map<String, int>? stats,
    bool? isLoading,
    bool? isSubmitting,
    String? error,
  }) {
    return TicketsState(
      tickets: tickets ?? this.tickets,
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
    );
  }
}

// ==================== SEARCH PROVIDER ====================
final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = Provider<List<TicketModel>>((ref) {
  final query = ref.watch(searchQueryProvider);
  final ticketsNotifier = ref.read(ticketsProvider.notifier);
  if (query.isEmpty) return ref.read(ticketListProvider);
  return ticketsNotifier.searchTickets(query);
});

// ==================== THEME PROVIDER ====================
final themeModeProvider = StateProvider<ThemeMode>((ref) {
  return ThemeMode.system;
});

// ==================== NOTIFICATION PROVIDER ====================
final unreadCountProvider = StateProvider<int>((ref) => 0);

final notificationNotifierProvider = StateNotifierProvider<NotificationNotifier, int>((ref) {
  final repo = ref.read(ticketRepoProvider);
  return NotificationNotifier(repo);
});

class NotificationNotifier extends StateNotifier<int> {
  final TicketRepository _repo;

  NotificationNotifier(this._repo) : super(0) {
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    try {
      final notifs = await _repo.getNotifications();
      final unread = notifs.where((n) => !(n['is_read'] ?? false)).length;
      print('🔔 Unread count loaded: $unread from ${notifs.length} total notifications');
      state = unread;
    } catch (e) {
      print('❌ Error loading unread count: $e');
      state = 0;
    }
  }

  Future<void> refresh() async {
    await _loadUnreadCount();
  }

  Future<void> markAllRead() async {
    try {
      final notifs = await _repo.getNotifications();
      for (final n in notifs) {
        if (!(n['is_read'] ?? false)) {
          await _repo.markNotifRead(n['id']);
        }
      }
      state = 0;
    } catch (e) {
      // Silently fail
    }
  }
}

// ==================== NAVIGATION PROVIDER ====================
final selectedTabProvider = StateProvider<int>((ref) => 0);

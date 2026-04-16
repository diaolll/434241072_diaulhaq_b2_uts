import '../../core/config/env_config.dart';

class ApiConstants {
  // Base URL dari EnvConfig (bisa di-set lewat .env atau runtime)
  static String get baseUrl => EnvConfig.apiBaseUrl;

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String resetPassword = '/auth/reset-password';

  // Tickets
  static const String tickets = '/tickets';
  static String ticketById(String id) => '/tickets/$id';
  static String ticketStatus(String id) => '/tickets/$id/status';
  static String ticketAssign(String id) => '/tickets/$id/assign';
  static String ticketComments(String id) => '/tickets/$id/comments';
  static String ticketAttachments(String id) => '/tickets/$id/attachments';

  // Dashboard
  static const String dashboardStats = '/dashboard/stats';

  // Notifications
  static const String notifications = '/notifications';
  static String markRead(String id) => '/notifications/$id/read';
}
class ApiConstants {
  // ANDROID EMULATOR: http://10.0.2.2:8080/api/v1
  // IOS SIMULATOR: http://localhost:8080/api/v1
  // HP BENERAN: http://192.168.x.x:8080/api/v1
  static const String baseUrl = 'http://localhost:8080/api/v1';
  
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
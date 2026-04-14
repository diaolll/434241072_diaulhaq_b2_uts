class AppConstants {
  static const String appName = 'E-Ticketing';
  static const String appVersion = '1.0.0';

  // API
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );
  static const String apiVersion = '/api/v1';

  // Storage Keys
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserId = 'user_id';
  static const String keyUsername = 'username';
  static const String keyUserRole = 'user_role';

  // Routes
  static const String routeSplash = '/';
  static const String routeLogin = '/login';
  static const String routeHome = '/home';
  static const String routeTicketDetail = '/ticket/:id';
  static const String routeCreateTicket = '/ticket/create';
  static const String routeProfile = '/profile';

  // Status
  static const Map<String, String> ticketStatus = {
    'open': 'Open',
    'in_progress': 'In Progress',
    'resolved': 'Resolved',
    'closed': 'Closed',
  };

  // Priority
  static const Map<String, String> ticketPriority = {
    'low': 'Low',
    'medium': 'Medium',
    'high': 'High',
  };

  // Category
  static const List<String> ticketCategories = [
    'Infrastructure',
    'Network',
    'Hardware',
    'Software',
    'Security',
    'Other',
  ];
}

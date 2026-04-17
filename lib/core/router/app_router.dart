import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../presentation/screens/splash_screen.dart';
import '../../presentation/screens/login_screen.dart';
import '../../presentation/screens/register_screen.dart';
import '../../presentation/screens/reset_password_screen.dart';
import '../../presentation/screens/dashboard/dashboard_screen.dart';
import '../../presentation/screens/tickets/ticket_list_screen.dart';
import '../../presentation/screens/tickets/ticket_detail_screen.dart';
import '../../presentation/screens/tickets/create_ticket_screen.dart';
import '../../presentation/screens/profile_screen.dart';
import '../../presentation/screens/settings_screen.dart';
import '../../presentation/screens/notification_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final isAuth = token != null && token.isNotEmpty;
    final loc = state.matchedLocation;

    final publicRoutes = ['/', '/login', '/register', '/reset-password'];
    if (!isAuth && !publicRoutes.contains(loc)) return '/login';
    if (isAuth && (loc == '/login' || loc == '/register')) return '/dashboard';

    // Role-based access control
    if (isAuth) {
      final role = prefs.getString('user_role') ?? 'user';

      // Hanya role 'user' yang bisa buat tiket
      if (loc == '/tickets/create' && role != 'user') {
        return '/tickets';
      }
    }

    return null;
  },
  routes: [
    GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
    GoRoute(path: '/reset-password', builder: (_, __) => const ResetPasswordScreen()),
    GoRoute(path: '/dashboard', builder: (_, __) => const DashboardScreen()),
    GoRoute(path: '/tickets', builder: (_, __) => const TicketListScreen()),
    // IMPORTANT: /tickets/create must be before /tickets/:id
    GoRoute(path: '/tickets/create', builder: (_, __) => const CreateTicketScreen()),
    GoRoute(
      path: '/tickets/:id',
      builder: (_, state) => TicketDetailScreen(ticketId: state.pathParameters['id']!),
    ),
    GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
    GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
    GoRoute(path: '/notifications', builder: (_, __) => const NotificationScreen()),
  ],
);
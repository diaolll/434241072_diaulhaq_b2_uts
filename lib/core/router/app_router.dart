import 'package:go_router/go_router.dart';
import '../../presentation/screens/splash_screen.dart';
import '../../presentation/screens/login_screen.dart';
import '../../presentation/screens/register_screen.dart';
import '../../presentation/screens/reset_password_screen.dart';
import '../../presentation/screens/dashboard/dashboard_screen.dart';
import '../../presentation/screens/tickets/ticket_list_screen.dart';
import '../../presentation/screens/tickets/ticket_detail_screen.dart';
import '../../presentation/screens/tickets/create_ticket_screen.dart';
import '../../presentation/screens/profile_screen.dart';
import '../../presentation/screens/notification_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
    GoRoute(path: '/reset-password', builder: (_, __) => const ResetPasswordScreen()),
    GoRoute(path: '/dashboard', builder: (_, __) => const DashboardScreen()),
    GoRoute(path: '/tickets', builder: (_, __) => const TicketListScreen()),
    GoRoute(
      path: '/tickets/:id',
      builder: (_, state) => TicketDetailScreen(ticketId: state.pathParameters['id']!),
    ),
    GoRoute(path: '/tickets/create', builder: (_, __) => const CreateTicketScreen()),
    GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
    GoRoute(path: '/notifications', builder: (_, __) => const NotificationScreen()),
  ],
);

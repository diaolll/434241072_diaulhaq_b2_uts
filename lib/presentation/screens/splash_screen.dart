import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/providers/providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: const Interval(0, 0.6, curve: Curves.easeOut));
    _scale = Tween(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0, 0.5, curve: Curves.easeOut)),
    );
    _ctrl.forward();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;

    final auth = ref.read(authNotifierProvider);

    if (mounted) {
      context.go(auth.isAuthenticated ? '/dashboard' : '/login');
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Center(
          child: FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // App Icon / Logo - Lebih kecil
                  Image.asset(
                    'assets/logo/logoipsum-411.png',
                    width: 60,  // Diperkecil dari 100
                    height: 60, // Diperkecil dari 100
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.help_outline,
                        size: 60,
                        color: Color(0xFF1976D2),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  // App Name
                  const Text(
                    'tsmobileniech',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Subtitle
                  Text(
                    'E-Ticketing Helpdesk',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[600],
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 64),
                  // Loading Indicator
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

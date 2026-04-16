import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/providers/providers.dart';
import '../../../core/theme/modern_theme.dart';
import '../widgets/common/app_button.dart';
import '../widgets/common/app_input.dart';

/// Modern Login Screen
/// Features:
/// - Hero illustration with gradient
/// - Smooth fade-in animations
/// - Interactive form with focus states
/// - Social login options
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final authNotifier = ref.read(authNotifierProvider.notifier);
    final success = await authNotifier.login(
      _emailCtrl.text.trim(),
      _passwordCtrl.text.trim(),
    );

    if (mounted) {
      if (success) {
        context.go('/dashboard');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Email atau password salah',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: ModernTheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final authState = ref.watch(authNotifierProvider);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          const Color(0xFF1C1917),
                          ModernTheme.surfaceDarkElevated,
                        ]
                      : [
                          ModernTheme.primaryPale,
                          ModernTheme.surfaceVariant,
                        ],
                ),
              ),
            ),
          ),

          // Decorative circles
          Positioned(
            top: -100,
            right: -100,
            child: AnimatedBuilder(
              animation: _fadeInAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _fadeInAnimation.value,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          ModernTheme.primary.withValues(alpha: 0.2),
                          ModernTheme.primary.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          Positioned(
            bottom: -80,
            left: -80,
            child: AnimatedBuilder(
              animation: _fadeInAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _fadeInAnimation.value * 0.8,
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          ModernTheme.secondary.withValues(alpha: 0.15),
                          ModernTheme.secondary.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 450),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Hero Section
                        _buildHeroSection(size),
                        const SizedBox(height: 48),

                        // Welcome Text
                        _buildWelcomeText(),
                        const SizedBox(height: 40),

                        // Email Input
                        _buildAnimatedInput(
                          delay: 0,
                          child: AppInput(
                            controller: _emailCtrl,
                            label: 'Email',
                            hint: 'nama@email.com',
                            prefixIcon: Icons.mail_outline_rounded,
                            type: AppInputType.email,
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Email wajib diisi';
                              if (!v.contains('@')) return 'Email tidak valid';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Password Input
                        _buildAnimatedInput(
                          delay: 100,
                          child: AppInput(
                            controller: _passwordCtrl,
                            label: 'Password',
                            hint: 'Masukkan password',
                            prefixIcon: Icons.lock_outline_rounded,
                            type: AppInputType.password,
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Password wajib diisi';
                              if (v.length < 6) return 'Password minimal 6 karakter';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Forgot Password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => context.push('/reset-password'),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            ),
                            child: Text(
                              'Lupa Password?',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: ModernTheme.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Login Button
                        _buildAnimatedInput(
                          delay: 200,
                          child: AppButton(
                            text: 'Masuk',
                            onPressed: _login,
                            isLoading: authState.isLoading,
                            isGradient: true,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Divider
                        _buildAnimatedInput(
                          delay: 300,
                          child: Row(
                            children: [
                              Expanded(child: Divider(color: ModernTheme.stone300)),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  'atau lanjut dengan',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    color: ModernTheme.stone500,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Expanded(child: Divider(color: ModernTheme.stone300)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Social Login Buttons
                        _buildAnimatedInput(
                          delay: 400,
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildSocialButton(
                                  icon: Icons.g_mobiledata,
                                  label: 'Google',
                                  onTap: () {
                                    // TODO: Implement Google login
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildSocialButton(
                                  icon: Icons.apple,
                                  label: 'Apple',
                                  onTap: () {
                                    // TODO: Implement Apple login
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Register Link
                        _buildAnimatedInput(
                          delay: 500,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Belum punya akun? ',
                                style: GoogleFonts.plusJakartaSans(
                                  color: ModernTheme.stone600,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextButton(
                                onPressed: () => context.push('/register'),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  minimumSize: const Size(0, 32),
                                ),
                                child: Text(
                                  'Daftar Sekarang',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: ModernTheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(Size size) {
    return AnimatedBuilder(
      animation: _fadeInAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeInAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -0.1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _animationController,
              curve: const Interval(0, 0.5, curve: Curves.easeOut),
            )),
            child: Column(
              children: [
                // Logo Container
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    gradient: ModernTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: ModernTheme.primaryGlow,
                  ),
                  child: const Icon(
                    Icons.support_agent_rounded,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),

                // App Name
                Text(
                  'HelpDesk',
                  style: GoogleFonts.outfit(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: ModernTheme.stone800,
                    letterSpacing: -1,
                  ),
                ),
                Text(
                  'E-Ticketing System',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: ModernTheme.stone500,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeText() {
    return AnimatedBuilder(
      animation: _fadeInAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeInAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _animationController,
              curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
            )),
            child: Column(
              children: [
                Text(
                  'Selamat Datang! 👋',
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: ModernTheme.stone800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Masuk untuk mengelola tiket dan bantuan',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    color: ModernTheme.stone500,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedInput({required Widget child, required int delay}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + delay),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ModernTheme.stone300, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: ModernTheme.stone900.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: ModernTheme.stone700),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: ModernTheme.stone700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

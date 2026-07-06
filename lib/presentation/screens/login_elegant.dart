import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/providers/providers.dart';
import '../../../core/theme/elegant_theme.dart';
import '../widgets/elegant/elegant_widgets.dart';

/// Elegant Login Screen - Redesigned
/// A distinctive, modern login experience with personality
class ElegantLoginScreen extends ConsumerStatefulWidget {
  const ElegantLoginScreen({super.key});

  @override
  ConsumerState<ElegantLoginScreen> createState() => _ElegantLoginScreenState();
}

class _ElegantLoginScreenState extends ConsumerState<ElegantLoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _fadeController.dispose();
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
            content: Text(
              'Email atau password salah',
              style: GoogleFonts.inter(fontWeight: FontWeight.w500),
            ),
            backgroundColor: ElegantTheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Background with gradient and pattern
          _buildBackground(isDark),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Logo Section - More prominent and distinctive
                        _buildLogoSection(isDark),
                        const SizedBox(height: 48),

                        // Welcome Text - More personality
                        _buildWelcomeText(isDark),
                        const SizedBox(height: 40),

                        // Input Fields with card style
                        _buildInputCard(isDark),
                        const SizedBox(height: 20),

                        // Forgot Password - Integrated style
                        _buildForgotPassword(isDark),
                        const SizedBox(height: 8),

                        // Login Button
                        ElegantButton(
                          text: 'Masuk',
                          onPressed: _login,
                          isLoading: authState.isLoading,
                        ),
                        const SizedBox(height: 32),

                        // Divider with style
                        _buildDivider(isDark),
                        const SizedBox(height: 24),

                        // Register Section
                        _buildRegisterSection(isDark),
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

  Widget _buildBackground(bool isDark) {
    return Stack(
      children: [
        // Gradient background
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      const Color(0xFF0C0C0E),
                      const Color(0xFF1A1A2E),
                      const Color(0xFF0C0C0E),
                    ]
                  : [
                      const Color(0xFFF8FAFC),
                      const Color(0xFFF1F5F9),
                      const Color(0xFFF8FAFC),
                    ],
            ),
          ),
        ),

        // Decorative blob - top right
        Positioned(
          top: -100,
          right: -80,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  (isDark ? ElegantTheme.primaryLight : ElegantTheme.primary)
                      .withValues(alpha: 0.15),
                  (isDark ? ElegantTheme.primaryLight : ElegantTheme.primary)
                      .withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),

        // Decorative blob - bottom left
        Positioned(
          bottom: -80,
          left: -60,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  (isDark ? ElegantTheme.primary : ElegantTheme.primaryLight)
                      .withValues(alpha: 0.1),
                  (isDark ? ElegantTheme.primary : ElegantTheme.primaryLight)
                      .withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),

        // Grid pattern overlay
        if (!isDark)
          Positioned.fill(
            child: Opacity(
              opacity: 0.03,
              child: CustomPaint(
                painter: _GridPainter(),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLogoSection(bool isDark) {
    return Column(
      children: [
        // App Logo with distinctive styling
        Stack(
          alignment: Alignment.center,
          children: [
            // Outer glow ring
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          ElegantTheme.primaryLight.withValues(alpha: 0.2),
                          ElegantTheme.primary.withValues(alpha: 0.1),
                        ]
                      : [
                          ElegantTheme.primary.withValues(alpha: 0.15),
                          ElegantTheme.primaryLight.withValues(alpha: 0.1),
                        ],
                ),
              ),
            ),

            // Inner container with logo
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? ElegantTheme.surfaceDarkCard
                    : ElegantTheme.white,
                boxShadow: [
                  BoxShadow(
                    color: (isDark
                            ? ElegantTheme.primaryLight
                            : ElegantTheme.primary)
                        .withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: ClipOval(
                child: Image.asset(
                  'assets/logo/app_icon.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // Orbiting dots - subtle animation
            if (!isDark)
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(seconds: 3),
                builder: (context, value, child) {
                  return Transform.rotate(
                    angle: value * 6.28,
                    child: child,
                  );
                },
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: ElegantTheme.primary.withValues(alpha: 0.1),
                      width: 1,
                      strokeAlign: BorderSide.strokeAlignOutside,
                    ),
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 20),

        // App name with more personality
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'E-',
              style: GoogleFonts.inter(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: isDark
                    ? ElegantTheme.gray100
                    : ElegantTheme.gray900,
                letterSpacing: -1,
              ),
            ),
            Text(
              'Ticketing',
              style: GoogleFonts.inter(
                fontSize: 32,
                fontWeight: FontWeight.w300,
                color: isDark
                    ? ElegantTheme.gray400
                    : ElegantTheme.gray600,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Tagline - more engaging
        Text(
          'HelpDesk Support System',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: ElegantTheme.gray500,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeText(bool isDark) {
    return Column(
      children: [
        Text(
          'Selamat datang kembali',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: isDark ? ElegantTheme.gray100 : ElegantTheme.gray900,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Masuk ke akun Anda untuk melanjutkan',
          style: GoogleFonts.inter(
            fontSize: 15,
            color: ElegantTheme.gray500,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildInputCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? ElegantTheme.surfaceDarkCard
            : ElegantTheme.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? ElegantTheme.gray800
              : ElegantTheme.gray200.withValues(alpha: 0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : ElegantTheme.gray900)
                .withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Email Input
          ElegantInput(
            controller: _emailCtrl,
            label: 'Email',
            hint: 'nama@email.com',
            prefixIcon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Email wajib diisi';
              if (!v.contains('@')) return 'Email tidak valid';
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Password Input
          ElegantInput(
            controller: _passwordCtrl,
            label: 'Password',
            hint: 'Masukkan password',
            prefixIcon: Icons.lock_outline_rounded,
            obscureText: true,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Password wajib diisi';
              if (v.length < 6) return 'Minimal 6 karakter';
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildForgotPassword(bool isDark) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () => context.push('/reset-password'),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.help_outline_rounded,
              size: 16,
              color: ElegantTheme.gray500,
            ),
            const SizedBox(width: 6),
            Text(
              'Lupa password?',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: ElegantTheme.gray500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  isDark
                      ? ElegantTheme.gray800
                      : ElegantTheme.gray200,
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'baru di sini?',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: ElegantTheme.gray500,
              letterSpacing: 0.3,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  isDark
                      ? ElegantTheme.gray800
                      : ElegantTheme.gray200,
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (isDark
                ? ElegantTheme.primaryLight
                : ElegantTheme.primary)
            .withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isDark
                  ? ElegantTheme.primaryLight
                  : ElegantTheme.primary)
              .withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Belum punya akun? ',
            style: GoogleFonts.inter(
              color: ElegantTheme.gray600,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          GestureDetector(
            onTap: () => context.push('/register'),
            child: Row(
              children: [
                Text(
                  'Daftar',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? ElegantTheme.primaryLight
                        : ElegantTheme.primary,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 18,
                  color: isDark
                      ? ElegantTheme.primaryLight
                      : ElegantTheme.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Grid pattern painter for subtle background texture
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ElegantTheme.gray900
      ..strokeWidth = 0.5;

    const spacing = 40.0;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

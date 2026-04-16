import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/theme/modern_theme.dart';
import '../widgets/common/app_button.dart';
import '../widgets/common/app_input.dart';

/// Modern Reset Password Screen
/// Features:
/// - Clean, modern UI matching other auth screens
/// - Email input with validation
/// - Success state with animation
/// - Supabase password reset integration
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _loading = false;
  bool _emailSent = false;

  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
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
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      await SupabaseService.client.auth.resetPasswordForEmail(
        _emailCtrl.text.trim(),
      );
      if (mounted) {
        setState(() {
          _emailSent = true;
          _loading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Link reset password telah dikirim ke email',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: ModernTheme.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Gagal mengirim email reset: $e',
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
                          ModernTheme.accent.withValues(alpha: 0.15),
                          ModernTheme.accent.withValues(alpha: 0),
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
                        _buildHeroSection(),
                        const SizedBox(height: 40),

                        // Welcome Text
                        _buildWelcomeText(),
                        const SizedBox(height: 32),

                        // Email Input
                        if (!_emailSent) ...[
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
                          const SizedBox(height: 24),

                          // Reset Button
                          _buildAnimatedInput(
                            delay: 100,
                            child: AppButton(
                              text: 'Kirim Link Reset',
                              onPressed: _resetPassword,
                              isLoading: _loading,
                              isGradient: true,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Back to Login
                          _buildAnimatedInput(
                            delay: 200,
                            child: TextButton.icon(
                              onPressed: () => context.pop(),
                              icon: const Icon(Icons.arrow_back_rounded),
                              label: Text(
                                'Kembali ke Login',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w600,
                                  color: ModernTheme.primary,
                                ),
                              ),
                            ),
                          ),
                        ] else ...[
                          // Success State
                          _buildSuccessState(),
                        ],
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

  Widget _buildHeroSection() {
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
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                gradient: ModernTheme.primaryGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: ModernTheme.primaryGlow,
              ),
              child: const Icon(
                Icons.lock_reset_rounded,
                size: 48,
                color: Colors.white,
              ),
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
                  _emailSent ? 'Email Terkirim!' : 'Lupa Password?',
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: ModernTheme.stone800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _emailSent
                      ? 'Kami telah mengirimkan link reset password ke ${_emailCtrl.text.isEmpty ? "email Anda" : _emailCtrl.text}'
                      : 'Masukkan email Anda untuk menerima link reset password',
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

  Widget _buildSuccessState() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ModernTheme.success.withValues(alpha: 0.1),
            ModernTheme.success.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ModernTheme.success.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: ModernTheme.success.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mark_email_read_rounded,
              size: 40,
              color: ModernTheme.success,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Cek Inbox Email Anda',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: ModernTheme.stone800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Kami telah mengirimkan instruksi untuk reset password Anda.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: ModernTheme.stone500,
            ),
          ),
          const SizedBox(height: 24),
          AppButton(
            text: 'Kembali ke Login',
            onPressed: () => context.pop(),
            type: AppButtonType.outline,
          ),
        ],
      ),
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
}

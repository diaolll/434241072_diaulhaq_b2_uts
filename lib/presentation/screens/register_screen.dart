import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/providers/providers.dart';
import '../../../core/theme/modern_theme.dart';
import '../widgets/common/app_button.dart';
import '../widgets/common/app_input.dart';

/// Modern Register Screen
/// Features:
/// - Clean, modern UI matching login screen
/// - Password strength indicator
/// - Terms & conditions checkbox
/// - Social signup options
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _agreeToTerms = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

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
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Silakan setujui syarat dan ketentuan',
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
      return;
    }

    final authNotifier = ref.read(authNotifierProvider.notifier);
    final success = await authNotifier.register(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text.trim(),
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Registrasi berhasil! Anda sudah login',
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
                    'Registrasi gagal. Silakan coba lagi.',
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

  int _passwordStrength = 0;
  String _passwordStrengthLabel = '';

  void _checkPasswordStrength(String password) {
    if (password.isEmpty) {
      setState(() {
        _passwordStrength = 0;
        _passwordStrengthLabel = '';
      });
      return;
    }

    int strength = 0;
    if (password.length >= 6) strength++;
    if (password.length >= 10) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;

    String label;
    if (strength <= 2) {
      label = 'Lemah';
    } else if (strength <= 3) {
      label = 'Sedang';
    } else {
      label = 'Kuat';
    }

    setState(() {
      _passwordStrength = strength;
      _passwordStrengthLabel = label;
    });
  }

  Color _getStrengthColor() {
    if (_passwordStrength <= 2) return ModernTheme.error;
    if (_passwordStrength <= 3) return ModernTheme.warning;
    return ModernTheme.success;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final authState = ref.watch(authNotifierProvider);

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
                        // Logo & Title
                        _buildHeader(),
                        const SizedBox(height: 48),

                        // Name Input
                        _buildAnimatedInput(
                          delay: 0,
                          child: AppInput(
                            controller: _nameCtrl,
                            label: 'Nama Lengkap',
                            hint: 'Masukkan nama lengkap',
                            prefixIcon: Icons.person_outline_rounded,
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Nama wajib diisi';
                              if (v.length < 3) return 'Nama minimal 3 karakter';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Email Input
                        _buildAnimatedInput(
                          delay: 100,
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
                          delay: 200,
                          child: AppInput(
                            controller: _passwordCtrl,
                            label: 'Password',
                            hint: 'Minimal 6 karakter',
                            prefixIcon: Icons.lock_outline_rounded,
                            type: AppInputType.password,
                            obscureText: _obscurePassword,
                            onChanged: _checkPasswordStrength,
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Password wajib diisi';
                              if (v.length < 6) return 'Password minimal 6 karakter';
                              return null;
                            },
                            suffixIcon: GestureDetector(
                              onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                child: Icon(
                                  _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                  size: 20,
                                  color: ModernTheme.stone500,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Password Strength Indicator
                        if (_passwordCtrl.text.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          _buildPasswordStrengthIndicator(),
                        ],

                        const SizedBox(height: 20),

                        // Confirm Password Input
                        _buildAnimatedInput(
                          delay: 300,
                          child: AppInput(
                            controller: _confirmCtrl,
                            label: 'Konfirmasi Password',
                            hint: 'Ulangi password',
                            prefixIcon: Icons.lock_outline_rounded,
                            type: AppInputType.password,
                            obscureText: _obscureConfirm,
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Konfirmasi password wajib diisi';
                              if (v != _passwordCtrl.text) return 'Password tidak cocok';
                              return null;
                            },
                            suffixIcon: GestureDetector(
                              onTap: () => setState(() => _obscureConfirm = !_obscureConfirm),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                child: Icon(
                                  _obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                  size: 20,
                                  color: ModernTheme.stone500,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Terms Checkbox
                        _buildAnimatedInput(
                          delay: 400,
                          child: AppCheckbox(
                            label: 'Saya setuju dengan syarat dan ketentuan',
                            value: _agreeToTerms,
                            onChanged: (v) => setState(() => _agreeToTerms = v),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Register Button
                        _buildAnimatedInput(
                          delay: 500,
                          child: AppButton(
                            text: 'Daftar Sekarang',
                            onPressed: _register,
                            isLoading: authState.isLoading,
                            isGradient: true,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Divider
                        _buildAnimatedInput(
                          delay: 600,
                          child: Row(
                            children: [
                              Expanded(child: Divider(color: ModernTheme.stone300)),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  'atau daftar dengan',
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
                          delay: 700,
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildSocialButton(
                                  icon: Icons.g_mobiledata,
                                  label: 'Google',
                                  onTap: () {
                                    // TODO: Implement Google signup
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildSocialButton(
                                  icon: Icons.apple,
                                  label: 'Apple',
                                  onTap: () {
                                    // TODO: Implement Apple signup
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Login Link
                        _buildAnimatedInput(
                          delay: 800,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Sudah punya akun? ',
                                style: GoogleFonts.plusJakartaSans(
                                  color: ModernTheme.stone600,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextButton(
                                onPressed: () => context.pop(),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  minimumSize: const Size(0, 32),
                                ),
                                child: Text(
                                  'Masuk',
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

  Widget _buildHeader() {
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

                // Title
                Text(
                  'Buat Akun Baru',
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: ModernTheme.stone800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Mulai kelola tiket bantuan Anda',
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

  Widget _buildPasswordStrengthIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Kekuatan Password: ',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: ModernTheme.stone500,
              ),
            ),
            Text(
              _passwordStrengthLabel,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _getStrengthColor(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 4,
          decoration: BoxDecoration(
            color: ModernTheme.stone200,
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            widthFactor: _passwordStrength / 5,
            alignment: Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(
                color: _getStrengthColor(),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ],
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

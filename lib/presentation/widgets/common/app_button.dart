import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/modern_theme.dart';

/// Modern Button Types
enum AppButtonType {
  primary,
  secondary,
  outline,
  text,
  danger,
  success,
}

/// Modern Button Widget with gradient and shadow support
class AppButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final Widget? leading;
  final Widget? trailing;
  final double? width;
  final double? height;
  final double borderRadius;
  final bool isGradient;
  final bool isPill;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = AppButtonType.primary,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.leading,
    this.trailing,
    this.width,
    this.height,
    this.borderRadius = 16,
    this.isGradient = false,
    this.isPill = false,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null && !widget.isLoading;

    return GestureDetector(
      onTapDown: enabled ? (_) => _handlePressDown() : null,
      onTapUp: enabled ? (_) => _handlePressUp() : null,
      onTapCancel: _handlePressUp,
      onTap: enabled ? widget.onPressed : null,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: SizedBox(
          width: widget.isFullWidth ? double.infinity : widget.width,
          height: widget.height ?? 56,
          child: _buildButton(context, enabled),
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, bool enabled) {
    final borderRadius = widget.isPill ? 28.0 : widget.borderRadius;

    switch (widget.type) {
      case AppButtonType.primary:
        if (widget.isGradient) {
          return _GradientButton(
            text: widget.text,
            enabled: enabled,
            isLoading: widget.isLoading,
            borderRadius: borderRadius,
            leading: widget.leading,
            trailing: widget.trailing,
            icon: widget.icon,
          );
        }
        return _FilledButton(
          text: widget.text,
          enabled: enabled,
          isLoading: widget.isLoading,
          backgroundColor: ModernTheme.primary,
          borderRadius: borderRadius,
          leading: widget.leading,
          trailing: widget.trailing,
          icon: widget.icon,
        );

      case AppButtonType.secondary:
        return _FilledButton(
          text: widget.text,
          enabled: enabled,
          isLoading: widget.isLoading,
          backgroundColor: ModernTheme.secondary,
          borderRadius: borderRadius,
          leading: widget.leading,
          trailing: widget.trailing,
          icon: widget.icon,
        );

      case AppButtonType.outline:
        return _OutlinedButton(
          text: widget.text,
          enabled: enabled,
          borderColor: ModernTheme.primary,
          borderRadius: borderRadius,
          leading: widget.leading,
          trailing: widget.trailing,
          icon: widget.icon,
        );

      case AppButtonType.text:
        return _TextButton(
          text: widget.text,
          enabled: enabled,
          leading: widget.leading,
          trailing: widget.trailing,
          icon: widget.icon,
        );

      case AppButtonType.danger:
        return _FilledButton(
          text: widget.text,
          enabled: enabled,
          isLoading: widget.isLoading,
          backgroundColor: ModernTheme.error,
          borderRadius: borderRadius,
          leading: widget.leading,
          trailing: widget.trailing,
          icon: widget.icon,
        );

      case AppButtonType.success:
        return _FilledButton(
          text: widget.text,
          enabled: enabled,
          isLoading: widget.isLoading,
          backgroundColor: ModernTheme.success,
          borderRadius: borderRadius,
          leading: widget.leading,
          trailing: widget.trailing,
          icon: widget.icon,
        );
    }
  }

  void _handlePressDown() {
    _scaleController.forward();
  }

  void _handlePressUp() {
    _scaleController.reverse();
  }
}

class _GradientButton extends StatelessWidget {
  final String text;
  final bool enabled;
  final bool isLoading;
  final double borderRadius;
  final Widget? leading;
  final Widget? trailing;
  final IconData? icon;

  const _GradientButton({
    required this.text,
    required this.enabled,
    required this.isLoading,
    required this.borderRadius,
    this.leading,
    this.trailing,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: enabled ? ModernTheme.primaryGradient : null,
        color: enabled ? null : ModernTheme.stone300,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: ModernTheme.primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    List<Widget> children = [];

    if (leading != null) {
      children.add(leading!);
      children.add(const SizedBox(width: 12));
    } else if (icon != null) {
      children.add(Icon(icon, size: 20, color: Colors.white));
      children.add(const SizedBox(width: 12));
    }

    children.add(
      Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
          color: Colors.white,
        ),
      ),
    );

    if (trailing != null) {
      children.add(const SizedBox(width: 12));
      children.add(trailing!);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }
}

class _FilledButton extends StatelessWidget {
  final String text;
  final bool enabled;
  final bool isLoading;
  final Color backgroundColor;
  final double borderRadius;
  final Widget? leading;
  final Widget? trailing;
  final IconData? icon;

  const _FilledButton({
    required this.text,
    required this.enabled,
    required this.isLoading,
    required this.backgroundColor,
    required this.borderRadius,
    this.leading,
    this.trailing,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: enabled ? backgroundColor : ModernTheme.stone300,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: backgroundColor.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    List<Widget> children = [];

    if (leading != null) {
      children.add(leading!);
      children.add(const SizedBox(width: 12));
    } else if (icon != null) {
      children.add(Icon(icon, size: 20, color: Colors.white));
      children.add(const SizedBox(width: 12));
    }

    children.add(
      Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
          color: Colors.white,
        ),
      ),
    );

    if (trailing != null) {
      children.add(const SizedBox(width: 12));
      children.add(trailing!);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }
}

class _OutlinedButton extends StatelessWidget {
  final String text;
  final bool enabled;
  final Color borderColor;
  final double borderRadius;
  final Widget? leading;
  final Widget? trailing;
  final IconData? icon;

  const _OutlinedButton({
    required this.text,
    required this.enabled,
    required this.borderColor,
    required this.borderRadius,
    this.leading,
    this.trailing,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: enabled ? borderColor : ModernTheme.stone300,
          width: 1.5,
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    List<Widget> children = [];

    if (leading != null) {
      children.add(leading!);
      children.add(const SizedBox(width: 12));
    } else if (icon != null) {
      children.add(Icon(icon, size: 20, color: ModernTheme.primary));
      children.add(const SizedBox(width: 12));
    }

    children.add(
      Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
          color: enabled ? ModernTheme.primary : ModernTheme.stone400,
        ),
      ),
    );

    if (trailing != null) {
      children.add(const SizedBox(width: 12));
      children.add(trailing!);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }
}

class _TextButton extends StatelessWidget {
  final String text;
  final bool enabled;
  final Widget? leading;
  final Widget? trailing;
  final IconData? icon;

  const _TextButton({
    required this.text,
    required this.enabled,
    this.leading,
    this.trailing,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];

    if (leading != null) {
      children.add(leading!);
      children.add(const SizedBox(width: 8));
    } else if (icon != null) {
      children.add(Icon(icon, size: 18, color: ModernTheme.primary));
      children.add(const SizedBox(width: 8));
    }

    children.add(
      Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.1,
          color: enabled ? ModernTheme.primary : ModernTheme.stone400,
        ),
      ),
    );

    if (trailing != null) {
      children.add(const SizedBox(width: 8));
      children.add(trailing!);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }
}

/// Icon-only button (floating action button alternative)
class AppIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final String? tooltip;
  final double size;
  final bool isPill;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.tooltip,
    this.size = 56,
    this.isPill = false,
  });

  @override
  State<AppIconButton> createState() => _AppIconButtonState();
}

class _AppIconButtonState extends State<AppIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final bgColor = widget.backgroundColor ?? ModernTheme.primary;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: enabled ? (_) => _controller.forward() : null,
        onTapUp: enabled ? (_) => _controller.reverse() : null,
        onTapCancel: enabled ? () => _controller.reverse() : null,
        onTap: widget.onPressed,
        child: Tooltip(
          message: widget.tooltip ?? '',
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: enabled ? bgColor : ModernTheme.stone300,
              borderRadius: BorderRadius.circular(widget.isPill ? widget.size / 2 : 16),
              boxShadow: enabled
                  ? [
                      BoxShadow(
                        color: bgColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              widget.icon,
              color: widget.foregroundColor ?? Colors.white,
              size: widget.size * 0.4,
            ),
          ),
        ),
      ),
    );
  }
}

/// Social Login Button
class AppSocialButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? iconColor;

  const AppSocialButton({
    super.key,
    required this.text,
    required this.icon,
    this.onPressed,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
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
            Icon(icon, color: iconColor ?? ModernTheme.stone700, size: 22),
            const SizedBox(width: 12),
            Text(
              text,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
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

/// Chip Button for filters and selections
class AppChipButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final IconData? icon;
  final Color? selectedColor;

  const AppChipButton({
    super.key,
    required this.label,
    required this.selected,
    this.onTap,
    this.icon,
    this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = selectedColor ?? ModernTheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? color : ModernTheme.stone100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? color : ModernTheme.stone200,
            width: selected ? 0 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: selected ? Colors.white : ModernTheme.stone500,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : ModernTheme.stone600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

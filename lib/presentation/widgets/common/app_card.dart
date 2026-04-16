import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/modern_theme.dart';
import 'status_badge.dart';

/// Modern Card Types
enum AppCardType {
  elevated,
  outlined,
  filled,
  glass,
}

/// Modern Card Widget with glassmorphic effects and variants
class AppCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final AppCardType type;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? elevation;
  final bool isGradient;
  final LinearGradient? gradient;
  final double? width;
  final double? height;
  final bool animateOnHover;
  final Duration animationDuration;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.type = AppCardType.elevated,
    this.padding,
    this.margin,
    this.borderRadius,
    this.backgroundColor,
    this.borderColor,
    this.elevation,
    this.isGradient = false,
    this.gradient,
    this.width,
    this.height,
    this.animateOnHover = false,
    this.animationDuration = const Duration(milliseconds: 200),
  });

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
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
    final isDark = context.isDarkMode;
    final defaultPadding = widget.padding ?? const EdgeInsets.all(20);
    final defaultMargin = widget.margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
    final defaultBorderRadius = widget.borderRadius ?? 20.0;

    final cardContent = Padding(
      padding: defaultPadding,
      child: widget.child,
    );

    Widget cardChild = cardContent;

    if (widget.isGradient && widget.gradient != null) {
      cardChild = Container(
        decoration: BoxDecoration(
          gradient: widget.gradient,
          borderRadius: BorderRadius.circular(defaultBorderRadius),
        ),
        child: cardContent,
      );
    }

    return Container(
      width: widget.width,
      height: widget.height,
      margin: defaultMargin,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: GestureDetector(
              onTapDown: widget.onTap != null ? (_) => _handlePressDown() : null,
              onTapUp: widget.onTap != null ? (_) => _handlePressUp() : null,
              onTapCancel: _handlePressUp,
              onTap: widget.onTap,
              child: MouseRegion(
                onEnter: widget.animateOnHover ? (_) => _handleHoverEnter() : null,
                onExit: widget.animateOnHover ? (_) => _handleHoverExit() : null,
                child: Container(
                  decoration: _buildDecoration(context, defaultBorderRadius, isDark),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(defaultBorderRadius),
                    child: cardChild,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  BoxDecoration _buildDecoration(BuildContext context, double radius, bool isDark) {
    switch (widget.type) {
      case AppCardType.glass:
        return BoxDecoration(
          color: (widget.backgroundColor ?? ModernTheme.surface).withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: widget.borderColor ?? ModernTheme.stone200.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: ModernTheme.stone900.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        );

      case AppCardType.outlined:
        return BoxDecoration(
          color: widget.backgroundColor ?? Colors.transparent,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: widget.borderColor ?? ModernTheme.stone300,
            width: 1.5,
          ),
        );

      case AppCardType.filled:
        return BoxDecoration(
          color: widget.backgroundColor ??
              (isDark ? ModernTheme.surfaceDarkElevated : ModernTheme.surface),
          borderRadius: BorderRadius.circular(radius),
        );

      case AppCardType.elevated:
        return BoxDecoration(
          color: widget.backgroundColor ??
              (isDark ? ModernTheme.surfaceDarkElevated : ModernTheme.surface),
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: widget.borderColor ??
                (isDark
                    ? ModernTheme.stone700.withValues(alpha: 0.5)
                    : ModernTheme.stone200.withValues(alpha: 0.6)),
            width: 1,
          ),
          boxShadow: ModernTheme.lightShadow,
        );
    }
  }

  void _handlePressDown() {
    _controller.forward();
  }

  void _handlePressUp() {
    _controller.reverse();
  }

  void _handleHoverEnter() {
    // Could add hover effects here
  }

  void _handleHoverExit() {
    // Could remove hover effects here
  }
}

/// Stat Card Widget for Dashboard with animated counter
class StatCard extends StatefulWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final LinearGradient? gradient;
  final VoidCallback? onTap;
  final String? subtitle;
  final bool isBig;
  final String? trend;
  final bool trendUp;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.gradient,
    this.onTap,
    this.subtitle,
    this.isBig = false,
    this.trend,
    this.trendUp = true,
  });

  @override
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return FadeTransition(
      opacity: _fadeInAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(_fadeInAnimation),
        child: AppCard(
          onTap: widget.onTap,
          type: AppCardType.elevated,
          padding: const EdgeInsets.all(20),
          borderRadius: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon Container
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: widget.gradient ??
                      LinearGradient(
                        colors: [widget.color, widget.color.withValues(alpha: 0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  widget.icon,
                  color: Colors.white,
                  size: widget.isBig ? 28 : 24,
                ),
              ),
              const Spacer(),
              // Value
              Text(
                widget.value,
                style: GoogleFonts.outfit(
                  fontSize: widget.isBig ? 32 : 28,
                  fontWeight: FontWeight.w700,
                  color: widget.color,
                  height: 1,
                ),
              ),
              const SizedBox(height: 6),
              // Label
              Text(
                widget.label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: widget.isBig ? 14 : 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? ModernTheme.stone400 : ModernTheme.stone500,
                ),
              ),
              if (widget.subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  widget.subtitle!,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: ModernTheme.stone400,
                  ),
                ),
              ],
              if (widget.trend != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      widget.trendUp ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                      size: 16,
                      color: widget.trendUp ? ModernTheme.success : ModernTheme.error,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.trend!,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: widget.trendUp ? ModernTheme.success : ModernTheme.error,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Menu Item Card Widget with hover animation
class MenuItemCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Widget? trailing;
  final bool showArrow;
  final Color? backgroundColor;

  const MenuItemCard({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.iconColor,
    this.trailing,
    this.showArrow = true,
    this.backgroundColor,
  });

  @override
  State<MenuItemCard> createState() => _MenuItemCardState();
}

class _MenuItemCardState extends State<MenuItemCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final iconColor = widget.iconColor ?? ModernTheme.primary;

    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AppCard(
          onTap: widget.onTap,
          type: AppCardType.filled,
          backgroundColor: widget.backgroundColor,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          borderRadius: 20,
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: _isHovered ? 0.15 : 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  widget.icon,
                  color: iconColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? ModernTheme.stone100 : ModernTheme.stone800,
                      ),
                    ),
                    if (widget.subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        widget.subtitle!,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: ModernTheme.stone500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (widget.trailing != null) widget.trailing!,
              if (widget.showArrow && widget.trailing == null)
                AnimatedRotation(
                  duration: const Duration(milliseconds: 200),
                  turns: _isHovered ? 0.05 : 0,
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: ModernTheme.stone400,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Ticket Card Widget with status animation
class TicketCard extends StatefulWidget {
  final String ticketId;
  final String title;
  final String status;
  final String priority;
  final String? category;
  final DateTime createdAt;
  final VoidCallback? onTap;
  final String? assignee;
  final int? commentCount;

  const TicketCard({
    super.key,
    required this.ticketId,
    required this.title,
    required this.status,
    required this.priority,
    this.category,
    required this.createdAt,
    this.onTap,
    this.assignee,
    this.commentCount,
  });

  @override
  State<TicketCard> createState() => _TicketCardState();
}

class _TicketCardState extends State<TicketCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.05, 0),
        end: Offset.zero,
      ).animate(_slideAnimation),
      child: FadeTransition(
        opacity: _slideAnimation,
        child: AppCard(
          onTap: widget.onTap,
          type: AppCardType.elevated,
          padding: const EdgeInsets.all(20),
          borderRadius: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: ID and Status
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark
                          ? ModernTheme.stone700.withValues(alpha: 0.5)
                          : ModernTheme.stone200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '#${widget.ticketId}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isDark ? ModernTheme.stone400 : ModernTheme.stone600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const Spacer(),
                  StatusBadge(status: widget.status, isSmall: true),
                ],
              ),
              const SizedBox(height: 16),
              // Title
              Text(
                widget.title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? ModernTheme.stone100 : ModernTheme.stone800,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              // Badges
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  PriorityBadge(priority: widget.priority, isSmall: true),
                  if (widget.category != null)
                    CategoryBadge(category: widget.category!, isSmall: true),
                ],
              ),
              const SizedBox(height: 16),
              // Footer: Date, comments, assignee
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isDark
                          ? ModernTheme.stone700.withValues(alpha: 0.3)
                          : ModernTheme.stone200.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.access_time_rounded,
                      size: 14,
                      color: ModernTheme.stone500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatDate(widget.createdAt),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: ModernTheme.stone500,
                    ),
                  ),
                  const Spacer(),
                  if (widget.commentCount != null && widget.commentCount! > 0) ...[
                    Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 16,
                      color: ModernTheme.stone400,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.commentCount}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: ModernTheme.stone400,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  if (widget.assignee != null) ...[
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: ModernTheme.primary.withValues(alpha: 0.1),
                      child: Text(
                        widget.assignee!.isNotEmpty
                            ? widget.assignee![0].toUpperCase()
                            : '?',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: ModernTheme.primary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Today';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

/// Profile Card Widget
class ProfileCard extends StatelessWidget {
  final String name;
  final String? email;
  final String? role;
  final String? avatarUrl;
  final VoidCallback? onTap;
  final String? initials;

  const ProfileCard({
    super.key,
    required this.name,
    this.email,
    this.role,
    this.avatarUrl,
    this.onTap,
    this.initials,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final displayInitials = initials ?? (name.isNotEmpty ? name[0].toUpperCase() : '?');

    return AppCard(
      onTap: onTap,
      type: AppCardType.filled,
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      child: Row(
        children: [
          // Avatar
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ModernTheme.primary,
                  ModernTheme.primaryLight,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: ModernTheme.primaryGlow,
            ),
            child: avatarUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      avatarUrl!,
                      fit: BoxFit.cover,
                    ),
                  )
                : Center(
                    child: Text(
                      displayInitials,
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? ModernTheme.stone100 : ModernTheme.stone800,
                  ),
                ),
                if (email != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    email!,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: ModernTheme.stone500,
                    ),
                  ),
                ],
                if (role != null) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: ModernTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      role!,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: ModernTheme.stone400,
          ),
        ],
      ),
    );
  }
}

/// Info Card Widget with dismiss option
class InfoCard extends StatelessWidget {
  final String title;
  final String? description;
  final IconData? icon;
  final Color? iconColor;
  final Color? backgroundColor;
  final VoidCallback? onClose;
  final bool isDismissible;

  const InfoCard({
    super.key,
    required this.title,
    this.description,
    this.icon,
    this.iconColor,
    this.backgroundColor,
    this.onClose,
    this.isDismissible = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final effectiveIconColor = iconColor ?? ModernTheme.info;
    final effectiveBgColor = backgroundColor ??
        (isDark
            ? ModernTheme.infoDarkBg.withValues(alpha: 0.3)
            : ModernTheme.infoBg);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: effectiveBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: effectiveIconColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: effectiveIconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: effectiveIconColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: effectiveIconColor,
                  ),
                ),
                if (description != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    description!,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: isDark ? ModernTheme.stone400 : ModernTheme.stone600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (isDismissible && onClose != null)
            GestureDetector(
              onTap: onClose,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: effectiveIconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: effectiveIconColor,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Glass Card with blur effect
class GlassCard extends StatelessWidget {
  final Widget child;
  final double? borderRadius;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap;
  final double blur;
  final double opacity;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius,
    this.padding,
    this.margin,
    this.onTap,
    this.blur = 10,
    this.opacity = 0.7,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? 20.0;

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ColorFilter.mode(
            Colors.white.withValues(alpha: opacity),
            BlendMode.srcOver,
          ),
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              padding: padding ?? const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(radius),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

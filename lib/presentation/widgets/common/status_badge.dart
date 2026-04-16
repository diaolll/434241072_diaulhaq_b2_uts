import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/modern_theme.dart';

/// Status Badge Widget
class StatusBadge extends StatelessWidget {
  final String status;
  final double? fontSize;
  final EdgeInsets? padding;
  final bool isSmall;
  final bool useLabel;

  const StatusBadge({
    super.key,
    required this.status,
    this.fontSize,
    this.padding,
    this.isSmall = false,
    this.useLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final label = useLabel ? ModernTheme.getStatusLabel(status) : status;
    final color = ModernTheme.getStatusColor(status);
    final backgroundColor = ModernTheme.getStatusBgColor(
      status,
      isDark: context.isDarkMode,
    );

    return Container(
      padding: padding ??
          EdgeInsets.symmetric(
            horizontal: isSmall ? 10 : 12,
            vertical: isSmall ? 5 : 6,
          ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(isSmall ? 8 : 10),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: fontSize ?? (isSmall ? 11 : 12),
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

/// Priority Badge Widget
class PriorityBadge extends StatelessWidget {
  final String priority;
  final double? fontSize;
  final EdgeInsets? padding;
  final bool isSmall;
  final bool useLabel;

  const PriorityBadge({
    super.key,
    required this.priority,
    this.fontSize,
    this.padding,
    this.isSmall = false,
    this.useLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final label = useLabel ? ModernTheme.getPriorityLabel(priority) : priority;
    final color = ModernTheme.getPriorityColor(priority);
    final backgroundColor = ModernTheme.getPriorityBgColor(
      priority,
      isDark: context.isDarkMode,
    );

    IconData? icon;
    switch (priority.toLowerCase()) {
      case 'low':
        icon = Icons.arrow_downward_rounded;
        break;
      case 'medium':
        icon = Icons.remove_rounded;
        break;
      case 'high':
        icon = Icons.arrow_upward_rounded;
        break;
      case 'critical':
        icon = Icons.priority_high_rounded;
        break;
    }

    return Container(
      padding: padding ??
          EdgeInsets.symmetric(
            horizontal: isSmall ? 10 : 12,
            vertical: isSmall ? 5 : 6,
          ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(isSmall ? 8 : 10),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: (fontSize ?? 12) + 2, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: fontSize ?? (isSmall ? 11 : 12),
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

/// Category Badge Widget
class CategoryBadge extends StatelessWidget {
  final String category;
  final Color? color;
  final IconData? icon;
  final bool isSmall;

  const CategoryBadge({
    super.key,
    required this.category,
    this.color,
    this.icon,
    this.isSmall = false,
  });

  static const _categoryColors = {
    'Hardware': Color(0xFF3B82F6),
    'Software': Color(0xFF8B5CF6),
    'Network': Color(0xFF06B6D4),
    'Security': Color(0xFFEF4444),
    'Access': Color(0xFFF59E0B),
    'Other': Color(0xFF6B7280),
  };

  static const _categoryIcons = {
    'Hardware': Icons.computer_rounded,
    'Software': Icons.apps_rounded,
    'Network': Icons.wifi_rounded,
    'Security': Icons.security_rounded,
    'Access': Icons.key_rounded,
    'Other': Icons.category_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final badgeColor = color ?? _categoryColors[category] ?? _categoryColors['Other']!;
    final badgeIcon = icon ?? _categoryIcons[category] ?? _categoryIcons['Other']!;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 10 : 12,
        vertical: isSmall ? 5 : 6,
      ),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(isSmall ? 8 : 10),
        border: Border.all(
          color: badgeColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            badgeIcon,
            size: isSmall ? 12 : 14,
            color: badgeColor,
          ),
          const SizedBox(width: 4),
          Text(
            category,
            style: GoogleFonts.plusJakartaSans(
              fontSize: isSmall ? 10 : 11,
              fontWeight: FontWeight.w700,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Combined Status and Priority Widget
class TicketBadges extends StatelessWidget {
  final String status;
  final String priority;
  final String? category;
  final bool isSmall;

  const TicketBadges({
    super.key,
    required this.status,
    required this.priority,
    this.category,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        StatusBadge(status: status, isSmall: isSmall),
        PriorityBadge(priority: priority, isSmall: isSmall),
        if (category != null) CategoryBadge(category: category!, isSmall: isSmall),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/elegant_theme.dart';

// ==================== ELEGANT BUTTONS ====================

enum ElegantButtonType { primary, secondary, outline, ghost, danger }

class ElegantButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ElegantButtonType type;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final double? width;
  final double? height;

  const ElegantButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ElegantButtonType.primary,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final enabled = onPressed != null && !isLoading;

    final backgroundColor = _getBackgroundColor(isDark, enabled);
    final foregroundColor = _getForegroundColor(isDark, enabled);
    final borderColor = _getBorderColor(isDark, enabled);

    final button = SizedBox(
      width: isFullWidth ? double.infinity : width,
      height: height ?? 52,
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: borderColor != null
                  ? Border.all(color: borderColor, width: 1.5)
                  : null,
            ),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, size: 20, color: foregroundColor),
                          const SizedBox(width: 10),
                        ],
                        Text(
                          text,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: foregroundColor,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );

    if (type == ElegantButtonType.ghost && enabled) {
      return button;
    }

    return button;
  }

  Color? _getBackgroundColor(bool isDark, bool enabled) {
    if (!enabled) {
      return isDark ? ElegantTheme.gray800 : ElegantTheme.gray200;
    }

    switch (type) {
      case ElegantButtonType.primary:
        return isDark ? ElegantTheme.primaryLight : ElegantTheme.primary;
      case ElegantButtonType.secondary:
        return isDark ? ElegantTheme.gray800 : ElegantTheme.gray100;
      case ElegantButtonType.outline:
      case ElegantButtonType.ghost:
        return Colors.transparent;
      case ElegantButtonType.danger:
        return ElegantTheme.error;
    }
  }

  Color _getForegroundColor(bool isDark, bool enabled) {
    if (!enabled) {
      return ElegantTheme.gray500;
    }

    switch (type) {
      case ElegantButtonType.primary:
      case ElegantButtonType.danger:
        return Colors.white;
      case ElegantButtonType.secondary:
      case ElegantButtonType.outline:
        return isDark ? ElegantTheme.gray100 : ElegantTheme.gray800;
      case ElegantButtonType.ghost:
        return isDark ? ElegantTheme.primaryLight : ElegantTheme.primary;
    }
  }

  Color? _getBorderColor(bool isDark, bool enabled) {
    switch (type) {
      case ElegantButtonType.outline:
        return isDark ? ElegantTheme.gray700 : ElegantTheme.gray300;
      case ElegantButtonType.ghost:
      case ElegantButtonType.primary:
      case ElegantButtonType.secondary:
      case ElegantButtonType.danger:
        return null;
    }
  }
}

// ==================== ELEGANT INPUT ====================

class ElegantInput extends StatefulWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final IconData? prefixIcon;
  final bool obscureText;
  final String? Function(String?)? validator;
  final bool enabled;
  final int? maxLines;
  final TextInputType? keyboardType;
  final Function(String)? onChanged;

  const ElegantInput({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.prefixIcon,
    this.obscureText = false,
    this.validator,
    this.enabled = true,
    this.maxLines = 1,
    this.keyboardType,
    this.onChanged,
  });

  @override
  State<ElegantInput> createState() => _ElegantInputState();
}

class _ElegantInputState extends State<ElegantInput> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? ElegantTheme.gray200 : ElegantTheme.gray700,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          decoration: BoxDecoration(
            color: isDark ? ElegantTheme.gray800 : ElegantTheme.gray100,
            borderRadius: BorderRadius.circular(14),
          ),
          child: TextFormField(
            controller: widget.controller,
            obscureText: _obscureText,
            enabled: widget.enabled,
            maxLines: widget.maxLines,
            keyboardType: widget.keyboardType,
            validator: widget.validator,
            onChanged: widget.onChanged,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: isDark ? ElegantTheme.gray100 : ElegantTheme.gray900,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: GoogleFonts.inter(
                color: ElegantTheme.gray400,
                fontSize: 15,
              ),
              prefixIcon: widget.prefixIcon != null
                  ? Icon(widget.prefixIcon, color: ElegantTheme.gray500)
                  : null,
              suffixIcon: widget.obscureText
                  ? IconButton(
                      icon: Icon(
                        _obscureText
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: ElegantTheme.gray500,
                      ),
                      onPressed: () => setState(() => _obscureText = !_obscureText),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ==================== ELEGANT CARD ====================

class ElegantCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final Color? backgroundColor;

  const ElegantCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor ?? (isDark ? ElegantTheme.surfaceDarkCard : ElegantTheme.white),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? ElegantTheme.gray800 : ElegantTheme.gray200.withOpacity(0.8),
          width: 1,
        ),
      ),
      child: child,
    );
  }
}

// ==================== ELEGANT STAT CARD ====================

class ElegantStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const ElegantStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return ElegantCard(
      padding: const EdgeInsets.all(20),
      backgroundColor: isDark ? ElegantTheme.surfaceDarkCard : ElegantTheme.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: ElegantTheme.gray500,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== ELEGANT TICKET CARD ====================

class ElegantTicketCard extends StatelessWidget {
  final String ticketNo;
  final String title;
  final String status;
  final String priority;
  final String? category;
  final VoidCallback? onTap;

  const ElegantTicketCard({
    super.key,
    required this.ticketNo,
    required this.title,
    required this.status,
    required this.priority,
    this.category,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? ElegantTheme.surfaceDarkCard : ElegantTheme.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? ElegantTheme.gray800 : ElegantTheme.gray200.withOpacity(0.8),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '#$ticketNo',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: ElegantTheme.gray500,
                  ),
                ),
                const Spacer(),
                _StatusPill(status: status),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? ElegantTheme.gray100 : ElegantTheme.gray900,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _PriorityPill(priority: priority),
                if (category != null) ...[
                  const SizedBox(width: 8),
                  _CategoryPill(category: category!),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String status;
  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = ElegantTheme.getStatusColor(status);
    final bg = ElegantTheme.getStatusBg(status);
    final label = ElegantTheme.getStatusLabel(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _PriorityPill extends StatelessWidget {
  final String priority;
  const _PriorityPill({required this.priority});

  @override
  Widget build(BuildContext context) {
    final color = ElegantTheme.getPriorityColor(priority);
    final bg = ElegantTheme.getPriorityBg(priority);
    final label = ElegantTheme.getPriorityLabel(priority);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  final String category;
  const _CategoryPill({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: ElegantTheme.gray100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        category,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: ElegantTheme.gray600,
        ),
      ),
    );
  }
}

// ==================== ELEGANT EMPTY STATE ====================

class ElegantEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const ElegantEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ElegantTheme.gray100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: ElegantTheme.gray400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? ElegantTheme.gray100 : ElegantTheme.gray900,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: ElegantTheme.gray500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElegantButton(
                text: actionLabel!,
                onPressed: onAction,
                isFullWidth: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ==================== ELEGANT APP BAR ====================

class ElegantAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBack;

  const ElegantAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = true,
    this.onBack,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: isDark ? ElegantTheme.surfaceDark : ElegantTheme.white,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
              onPressed: onBack ?? () => Navigator.pop(context),
            )
          : null,
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: isDark ? ElegantTheme.gray100 : ElegantTheme.gray900,
        ),
      ),
      actions: actions,
      centerTitle: true,
    );
  }
}

// ==================== ELEGANT LOADING ====================

class ElegantLoading extends StatelessWidget {
  const ElegantLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation(
                context.isDarkMode ? ElegantTheme.primaryLight : ElegantTheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading...',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: ElegantTheme.gray500,
            ),
          ),
        ],
      ),
    );
  }
}

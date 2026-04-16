import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/modern_theme.dart';
import 'app_button.dart';

/// Empty State Types
enum EmptyStateType {
  noData,
  noTickets,
  noNotifications,
  noSearchResults,
  noInternet,
  error,
  success,
}

/// Empty State Widget
class EmptyState extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EmptyStateType type;
  final Widget? customIllustration;

  const EmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.actionLabel,
    this.onAction,
    this.type = EmptyStateType.noData,
    this.customIllustration,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getConfig();
    final isDark = context.isDarkMode;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (customIllustration != null) ...[
              customIllustration!,
              const SizedBox(height: 24),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: config.color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  config.icon,
                  size: 64,
                  color: config.color,
                ),
              ),
              const SizedBox(height: 24),
            ],
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? ModernTheme.stone100 : ModernTheme.stone800,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: ModernTheme.stone500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              AppButton(
                text: actionLabel!,
                onPressed: onAction,
                isGradient: true,
              ),
            ],
          ],
        ),
      ),
    );
  }

  _EmptyStateConfig _getConfig() {
    switch (type) {
      case EmptyStateType.noData:
        return _EmptyStateConfig(
          icon: Icons.inbox_outlined,
          color: ModernTheme.stone400,
        );
      case EmptyStateType.noTickets:
        return _EmptyStateConfig(
          icon: Icons.confirmation_number_outlined,
          color: ModernTheme.info,
        );
      case EmptyStateType.noNotifications:
        return _EmptyStateConfig(
          icon: Icons.notifications_none_outlined,
          color: ModernTheme.warning,
        );
      case EmptyStateType.noSearchResults:
        return _EmptyStateConfig(
          icon: Icons.search_off,
          color: ModernTheme.stone400,
        );
      case EmptyStateType.noInternet:
        return _EmptyStateConfig(
          icon: Icons.wifi_off,
          color: ModernTheme.error,
        );
      case EmptyStateType.error:
        return _EmptyStateConfig(
          icon: Icons.error_outline,
          color: ModernTheme.error,
        );
      case EmptyStateType.success:
        return _EmptyStateConfig(
          icon: Icons.check_circle_outline,
          color: ModernTheme.success,
        );
    }
  }
}

class _EmptyStateConfig {
  final IconData icon;
  final Color color;

  _EmptyStateConfig({required this.icon, required this.color});
}

/// Empty State with Illustration (SVG-like drawing)
class EmptyStateIllustration extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EmptyStateType type;

  const EmptyStateIllustration({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      title: title,
      subtitle: subtitle,
      actionLabel: actionLabel,
      onAction: onAction,
      type: type,
      customIllustration: _buildIllustration(),
    );
  }

  Widget? _buildIllustration() {
    switch (type) {
      case EmptyStateType.noTickets:
        return _TicketIllustration();
      case EmptyStateType.noNotifications:
        return _NotificationIllustration();
      case EmptyStateType.noSearchResults:
        return _SearchIllustration();
      case EmptyStateType.noInternet:
        return _NetworkIllustration();
      case EmptyStateType.error:
        return _ErrorIllustration();
      case EmptyStateType.success:
        return _SuccessIllustration();
      default:
        return null;
    }
  }
}

/// Ticket Illustration
class _TicketIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        children: [
          Positioned(
            top: 20,
            left: 10,
            child: Container(
              width: 80,
              height: 60,
              decoration: BoxDecoration(
                color: ModernTheme.stone200,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: ModernTheme.stone300),
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 30,
            child: Container(
              width: 80,
              height: 60,
              decoration: BoxDecoration(
                color: ModernTheme.info.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: ModernTheme.info),
              ),
            ),
          ),
          Positioned(
            top: 60,
            left: 50,
            child: Container(
              width: 80,
              height: 60,
              decoration: BoxDecoration(
                color: ModernTheme.stone200,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: ModernTheme.stone300),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Notification Illustration
class _NotificationIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        children: [
          Positioned(
            top: 30,
            left: 30,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: ModernTheme.warning.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: ModernTheme.warning, width: 2),
              ),
              child: Icon(
                Icons.notifications_none,
                size: 32,
                color: ModernTheme.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Search Illustration
class _SearchIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        children: [
          Positioned(
            top: 25,
            left: 25,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: ModernTheme.stone100,
                shape: BoxShape.circle,
                border: Border.all(color: ModernTheme.stone300, width: 2),
              ),
              child: Icon(
                Icons.search,
                size: 36,
                color: ModernTheme.stone400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Network Illustration
class _NetworkIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        children: [
          Positioned(
            top: 30,
            left: 30,
            child: Icon(
              Icons.cloud_off,
              size: 60,
              color: ModernTheme.error.withValues(alpha: 0.3),
            ),
          ),
          Positioned(
            top: 35,
            left: 35,
            child: Icon(
              Icons.wifi_off,
              size: 50,
              color: ModernTheme.error,
            ),
          ),
        ],
      ),
    );
  }
}

/// Error Illustration
class _ErrorIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        children: [
          Positioned(
            top: 30,
            left: 30,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: ModernTheme.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: ModernTheme.error, width: 2),
              ),
              child: Icon(
                Icons.close,
                size: 36,
                color: ModernTheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Success Illustration
class _SuccessIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        children: [
          Positioned(
            top: 30,
            left: 30,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: ModernTheme.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: ModernTheme.success, width: 2),
              ),
              child: Icon(
                Icons.check,
                size: 36,
                color: ModernTheme.success,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Sliver Empty State for CustomScrollView
class SliverEmptyState extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SliverEmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: EmptyState(
        title: title,
        subtitle: subtitle,
        icon: icon,
        actionLabel: actionLabel,
        onAction: onAction,
      ),
    );
  }
}

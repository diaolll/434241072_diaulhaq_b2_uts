import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Toast Types
enum AppToastType {
  success,
  error,
  info,
  warning,
}

/// App Toast Manager
class AppToast {
  /// Show a toast message
  static void show(
    BuildContext context, {
    required String message,
    AppToastType type = AppToastType.success,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _ToastWidget(
        message: message,
        type: type,
        onRemove: () => overlayEntry.remove(),
      ),
    );

    overlay.insert(overlayEntry);

    // Auto remove after duration
    Future.delayed(duration, () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  /// Quick success toast
  static void success(BuildContext context, String message) {
    show(context, message: message, type: AppToastType.success);
  }

  /// Quick error toast
  static void error(BuildContext context, String message) {
    show(context, message: message, type: AppToastType.error, duration: const Duration(seconds: 4));
  }

  /// Quick info toast
  static void info(BuildContext context, String message) {
    show(context, message: message, type: AppToastType.info);
  }

  /// Quick warning toast
  static void warning(BuildContext context, String message) {
    show(context, message: message, type: AppToastType.warning);
  }
}

/// Animated Toast Widget
class _ToastWidget extends StatefulWidget {
  final String message;
  final AppToastType type;
  final VoidCallback onRemove;

  const _ToastWidget({
    required this.message,
    required this.type,
    required this.onRemove,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: _ToastCard(
              message: widget.message,
              type: widget.type,
              isDark: isDark,
              onClose: widget.onRemove,
            ),
          ),
        ),
      ),
    );
  }
}

/// Toast Card Widget
class _ToastCard extends StatelessWidget {
  final String message;
  final AppToastType type;
  final bool isDark;
  final VoidCallback onClose;

  const _ToastCard({
    required this.message,
    required this.type,
    required this.isDark,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getToastConfig();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: config['bg'] as Color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: config['border'] as Color,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (config['bg'] as Color).withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: config['iconBg'] as Color,
              shape: BoxShape.circle,
            ),
            child: Icon(
              config['icon'] as IconData,
              size: 18,
              color: config['iconColor'] as Color,
            ),
          ),
          const SizedBox(width: 12),
          // Message
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: config['textColor'] as Color,
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Close button
          GestureDetector(
            onTap: onClose,
            child: Icon(
              Icons.close_rounded,
              size: 18,
              color: config['iconColor'] as Color,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getToastConfig() {
    switch (type) {
      case AppToastType.success:
        return {
          'bg': isDark ? const Color(0xFF0A3D22) : const Color(0xFFE8F9ED),
          'border': isDark ? const Color(0xFF34C759) : const Color(0xFF34C759),
          'icon': Icons.check_rounded,
          'iconBg': isDark ? const Color(0xFF34C759) : const Color(0xFF34C759),
          'iconColor': Colors.white,
          'textColor': isDark ? Colors.white : const Color(0xFF0A3D22),
        };

      case AppToastType.error:
        return {
          'bg': isDark ? const Color(0xFF3D0A0A) : const Color(0xFFFFEEEE),
          'border': isDark ? const Color(0xFFFF3B30) : const Color(0xFFFF3B30),
          'icon': Icons.close_rounded,
          'iconBg': isDark ? const Color(0xFFFF3B30) : const Color(0xFFFF3B30),
          'iconColor': Colors.white,
          'textColor': isDark ? Colors.white : const Color(0xFF3D0A0A),
        };

      case AppToastType.info:
        return {
          'bg': isDark ? const Color(0xFF0A2A3D) : const Color(0xFFE8F4FF),
          'border': isDark ? const Color(0xFF007AFF) : const Color(0xFF007AFF),
          'icon': Icons.info_rounded,
          'iconBg': isDark ? const Color(0xFF007AFF) : const Color(0xFF007AFF),
          'iconColor': Colors.white,
          'textColor': isDark ? Colors.white : const Color(0xFF0A2A3D),
        };

      case AppToastType.warning:
        return {
          'bg': isDark ? const Color(0xFF3D2E0A) : const Color(0xFFFFF4E8),
          'border': isDark ? const Color(0xFFFF9500) : const Color(0xFFFF9500),
          'icon': Icons.warning_rounded,
          'iconBg': isDark ? const Color(0xFFFF9500) : const Color(0xFFFF9500),
          'iconColor': Colors.white,
          'textColor': isDark ? Colors.white : const Color(0xFF3D2E0A),
        };
    }
  }
}

/// Extension method for quick toast access
extension BuildContextToast on BuildContext {
  void showToast(
    String message, {
    AppToastType type = AppToastType.success,
    Duration duration = const Duration(seconds: 3),
  }) {
    AppToast.show(
      this,
      message: message,
      type: type,
      duration: duration,
    );
  }

  void showSuccess(String message) => AppToast.success(this, message);
  void showError(String message) => AppToast.error(this, message);
  void showInfo(String message) => AppToast.info(this, message);
  void showWarning(String message) => AppToast.warning(this, message);
}

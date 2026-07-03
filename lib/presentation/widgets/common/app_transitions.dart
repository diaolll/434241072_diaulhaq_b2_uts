import 'package:flutter/material.dart';

/// Custom Page Transitions for smooth navigation
class AppTransitions {
  /// Slide from right (iOS style)
  static PageRouteBuilder<T> slideFromRight<T>({
    required Widget child,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder<T>(
      transitionDuration: duration,
      pageBuilder: (context, animation, _) => child,
      transitionsBuilder: (context, animation, _, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }

  /// Fade in/out
  static PageRouteBuilder<T> fadeIn<T>({
    required Widget child,
    Duration duration = const Duration(milliseconds: 250),
  }) {
    return PageRouteBuilder<T>(
      transitionDuration: duration,
      pageBuilder: (context, animation, _) => child,
      transitionsBuilder: (context, animation, _, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  /// Scale in (for dialogs/modals)
  static PageRouteBuilder<T> scaleIn<T>({
    required Widget child,
    Duration duration = const Duration(milliseconds: 200),
  }) {
    return PageRouteBuilder<T>(
      transitionDuration: duration,
      pageBuilder: (context, animation, _) => child,
      transitionsBuilder: (context, animation, _, child) {
        return ScaleTransition(
          scale: animation.drive(Tween<double>(begin: 0.8, end: 1.0).chain(CurveTween(curve: Curves.easeOutBack))),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }

  /// Shared axis transition (Material 3 style)
  static PageRouteBuilder<T> sharedAxis<T>({
    required Widget child,
    Duration duration = const Duration(milliseconds: 400),
    SharedAxisTransitionType type = SharedAxisTransitionType.scaled,
  }) {
    return PageRouteBuilder<T>(
      transitionDuration: duration,
      pageBuilder: (context, animation, _) => child,
      transitionsBuilder: (context, animation, _, child) {
        return SharedAxisTransition(
          animation: animation,
          child: child,
          type: type,
        );
      },
    );
  }
}

/// Shared Axis Transition Types
enum SharedAxisTransitionType {
  scaled,
  forward,
  backward,
}

/// Shared Axis Transition Widget (Material 3 style)
class SharedAxisTransition extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;
  final SharedAxisTransitionType type;

  const SharedAxisTransition({
    super.key,
    required this.animation,
    required this.child,
    this.type = SharedAxisTransitionType.scaled,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final curve = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        switch (type) {
          case SharedAxisTransitionType.scaled:
            return _buildScaled(curve, child);
          case SharedAxisTransitionType.forward:
            return _buildForward(curve, child);
          case SharedAxisTransitionType.backward:
            return _buildBackward(curve, child);
        }
      },
      child: child,
    );
  }

  Widget _buildScaled(Animation<double> animation, Widget? child) {
    // Combine scale and fade
    return Opacity(
      opacity: animation.value,
      child: Transform.scale(
        scale: 0.8 + (0.2 * animation.value),
        child: child,
      ),
    );
  }

  Widget _buildForward(Animation<double> animation, Widget? child) {
    // Z-axis transition (simplified without deprecated methods)
    return Opacity(
      opacity: animation.value,
      child: Transform.scale(
        scale: 0.8 + (0.2 * animation.value),
        child: child,
      ),
    );
  }

  Widget _buildBackward(Animation<double> animation, Widget? child) {
    // Z-axis transition reversed (simplified)
    return Opacity(
      opacity: animation.value,
      child: Transform.scale(
        scale: 1.0 + (0.2 * (1 - animation.value)),
        child: child,
      ),
    );
  }
}

/// Slide transition with fade for list items
class ListItemTransition extends StatelessWidget {
  final Widget child;
  final int index;
  final Duration duration;
  final Duration delay;

  const ListItemTransition({
    super.key,
    required this.child,
    required this.index,
    this.duration = const Duration(milliseconds: 300),
    this.delay = const Duration(milliseconds: 50),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
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

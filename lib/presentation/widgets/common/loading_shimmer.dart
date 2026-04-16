import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/modern_theme.dart';

/// Shimmer Loading Widget
class ShimmerLoader extends StatefulWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerLoader({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
  });

  @override
  State<ShimmerLoader> createState() => _ShimmerLoaderState();
}

class _ShimmerLoaderState extends State<ShimmerLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.centerRight,
              colors: [
                widget.baseColor ?? ModernTheme.stone200,
                widget.highlightColor ?? ModernTheme.stone100,
                widget.baseColor ?? ModernTheme.stone200,
              ],
              stops: const [0.0, 0.5, 1.0],
              transform: _SlidingGradientTransform(
                slidePercent: _animation.value,
              ),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;

  _SlidingGradientTransform({required this.slidePercent});

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}

/// Ticket Card Shimmer
class TicketCardShimmer extends StatelessWidget {
  const TicketCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? ModernTheme.surfaceDarkElevated : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ModernTheme.stone200),
      ),
      child: ShimmerLoader(
        baseColor: ModernTheme.stone200,
        highlightColor: ModernTheme.stone100,
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _ShimmerBox(width: 60, height: 20, borderRadius: 6),
                Spacer(),
                _ShimmerBox(width: 60, height: 20, borderRadius: 6),
              ],
            ),
            SizedBox(height: 12),
            _ShimmerBox(width: double.infinity, height: 16),
            SizedBox(height: 8),
            _ShimmerBox(width: 200, height: 16),
            SizedBox(height: 12),
            Row(
              children: [
                _ShimmerBox(width: 50, height: 20, borderRadius: 6),
                SizedBox(width: 8),
                _ShimmerBox(width: 50, height: 20, borderRadius: 6),
                Spacer(),
                _ShimmerBox(width: 80, height: 14),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Stat Card Shimmer
class StatCardShimmer extends StatelessWidget {
  const StatCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    return ShimmerLoader(
      baseColor: ModernTheme.stone200,
      highlightColor: ModernTheme.stone100,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? ModernTheme.surfaceDarkElevated : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ModernTheme.stone200),
        ),
        padding: const EdgeInsets.all(16),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ShimmerBox(width: 40, height: 40, borderRadius: 12),
            Spacer(),
            _ShimmerBox(width: 60, height: 28),
            SizedBox(height: 4),
            _ShimmerBox(width: 80, height: 14),
          ],
        ),
      ),
    );
  }
}

/// List Tile Shimmer
class ListTileShimmer extends StatelessWidget {
  final bool showLeading;
  final bool showTrailing;

  const ListTileShimmer({
    super.key,
    this.showLeading = true,
    this.showTrailing = true,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerLoader(
      baseColor: ModernTheme.stone200,
      highlightColor: ModernTheme.stone100,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            if (showLeading) ...[
              const _ShimmerBox(width: 48, height: 48, borderRadius: 24),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _ShimmerBox(width: 150, height: 16),
                  const SizedBox(height: 8),
                  const _ShimmerBox(width: 100, height: 14),
                ],
              ),
            ),
            if (showTrailing) ...[
              const SizedBox(width: 16),
              const _ShimmerBox(width: 24, height: 24),
            ],
          ],
        ),
      ),
    );
  }
}

/// Full Screen Shimmer
class FullScreenShimmer extends StatelessWidget {
  final String? message;

  const FullScreenShimmer({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: ModernTheme.primary),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message!,
                style: GoogleFonts.plusJakartaSans(
                  color: ModernTheme.stone500,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Circular Loading Indicator
class AppLoadingIndicator extends StatelessWidget {
  final double? size;
  final Color? color;
  final double strokeWidth;

  const AppLoadingIndicator({
    super.key,
    this.size,
    this.color,
    this.strokeWidth = 3,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation(
          color ?? ModernTheme.primary,
        ),
      ),
    );
  }
}

/// Button Loading Wrapper
class ButtonLoadingWrapper extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? loadingText;

  const ButtonLoadingWrapper({
    super.key,
    required this.isLoading,
    required this.child,
    this.loadingText,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return child;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(Colors.white),
          ),
        ),
        if (loadingText != null) ...[
          const SizedBox(width: 12),
          Text(loadingText!),
        ],
      ],
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const _ShimmerBox({
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: ModernTheme.stone200,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

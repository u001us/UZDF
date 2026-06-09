import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// ═══════════════════════════════════════
// ANIMATION CONSTANTS
// ═══════════════════════════════════════

const Duration kFast = Duration(milliseconds: 150);
const Duration kNormal = Duration(milliseconds: 300);
const Duration kSlow = Duration(milliseconds: 500);
const Duration kVerySlow = Duration(milliseconds: 800);

const Curve kSpring = Curves.easeOutCubic;
const Curve kBounce = Curves.elasticOut;
const Curve kSmooth = Curves.easeInOutCubic;

// ═══════════════════════════════════════
// GLASS SHIMMER EFFECT
// ═══════════════════════════════════════

class _ShimmerEffect extends StatefulWidget {
  final Widget child;
  final bool enabled;

  const _ShimmerEffect({super.key, required this.child, this.enabled = true});

  @override
  State<_ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<_ShimmerEffect> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shimmer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _shimmer = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: kSmooth),
      ),
    );
    if (widget.enabled) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return AnimatedBuilder(
      animation: _shimmer,
      builder: (_, child) {
        final val = _shimmer.value;
        final s1 = (val - 0.3).clamp(0.0, 1.0);
        final s2 = val.clamp(0.0, 1.0);
        final s3 = (val + 0.3).clamp(0.0, 1.0);
        final stops = [s1, s2 < s1 ? s1 : s2, s3 < s2 ? s2 : s3];

        return ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Colors.transparent,
              Colors.white.withOpacity(0.15),
              Colors.transparent,
            ],
            stops: stops,
          ).createShader(bounds),
          blendMode: BlendMode.srcATop,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

// ═══════════════════════════════════════
// LIQUID BORDER PAINTER
// ═══════════════════════════════════════

class LiquidBorderPainter extends CustomPainter {
  final double borderRadius;
  final double strokeWidth;

  LiquidBorderPainter({required this.borderRadius, this.strokeWidth = 1.0});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final RRect rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));
    
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.12),  // top/left subtle edge
          Colors.white.withOpacity(0.10),
          Colors.white.withOpacity(0.06), // bottom/right dim
          Colors.white.withOpacity(0.05),
        ],
        stops: const [0.0, 0.35, 0.7, 1.0],
      ).createShader(rect);

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ═══════════════════════════════════════
// LIQUID GLASS CARD (CORE COMPONENT)
// ═══════════════════════════════════════

class LiquidGlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blur;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final BoxBorder? border;
  final List<BoxShadow>? shadow;
  final Gradient? gradient;
  final AlignmentGeometry? alignment;
  final bool showShimmer;

  const LiquidGlassCard({
    super.key,
    required this.child,
    this.borderRadius = 28.0,
    this.blur = 40.0,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.border,
    this.shadow,
    this.gradient,
    this.alignment,
    this.showShimmer = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget cardContent = Container(
      width: width,
      height: height,
      padding: padding,
      alignment: alignment,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: gradient ?? LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.10),
            Colors.white.withOpacity(0.03),
          ],
        ),
      ),
      child: child,
    );

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: shadow ?? [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 60,
            spreadRadius: -10,
            offset: const Offset(0, 20),
          ),
          BoxShadow(
            color: const Color(0xFF007AFF).withOpacity(0.15),
            blurRadius: 80,
            spreadRadius: -20,
            offset: const Offset(0, 30),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Stack(
            children: [
              // Core gradient content
              cardContent,
              // Top + left border highlight using CustomPaint to avoid Flutter borderRadius exception
              Positioned.fill(
                child: IgnorePointer(
                  child: border != null
                      ? Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(borderRadius),
                            border: border,
                          ),
                        )
                      : CustomPaint(
                          painter: LiquidBorderPainter(borderRadius: borderRadius),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════
// GLASS CONTAINER (BACKWARD COMPATIBILITY)
// ═══════════════════════════════════════

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final double borderRadius;
  final BoxBorder? border;
  final List<BoxShadow>? shadow;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final AlignmentGeometry? alignment;
  final Gradient? gradient;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 40.0,
    this.opacity = -1.0,
    this.borderRadius = 28.0,
    this.border,
    this.shadow,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.alignment,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    // Upgrades directly to the premium LiquidGlassCard
    return LiquidGlassCard(
      borderRadius: borderRadius,
      blur: blur,
      padding: padding,
      margin: margin,
      width: width,
      height: height,
      border: border,
      shadow: shadow,
      gradient: gradient,
      alignment: alignment,
      showShimmer: true,
      child: child,
    );
  }
}

// ═══════════════════════════════════════
// LIQUID BUTTON (PHYSICAL PRESS INTERACTIVE)
// ═══════════════════════════════════════

class LiquidButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double borderRadius;
  final double pressedOpacity;
  final double normalOpacity;

  const LiquidButton({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius = 18.0,
    this.pressedOpacity = 0.22,
    this.normalOpacity = 0.14,
  });

  @override
  State<LiquidButton> createState() => _LiquidButtonState();
}

class _LiquidButtonState extends State<LiquidButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isClickable = widget.onTap != null;
    return GestureDetector(
      onTapDown: (_) {
        if (isClickable) {
          setState(() => _pressed = true);
          HapticFeedback.lightImpact();
        }
      },
      onTapUp: (_) {
        if (isClickable) {
          setState(() => _pressed = false);
          widget.onTap!();
        }
      },
      onTapCancel: () {
        if (isClickable) {
          setState(() => _pressed = false);
        }
      },
      child: AnimatedScale(
        scale: _pressed ? 0.94 : 1.0,
        duration: kFast,
        curve: kSpring,
        child: AnimatedContainer(
          duration: kFast,
          decoration: BoxDecoration(
            color: _pressed
                ? Colors.white.withOpacity(widget.pressedOpacity)
                : Colors.white.withOpacity(widget.normalOpacity),
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(
              color: Colors.white.withOpacity(_pressed ? 0.25 : 0.12),
            ),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════
// GLASS BUTTON (BACKWARD COMPATIBILITY)
// ═══════════════════════════════════════

class GlassButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final double borderRadius;
  final double blur;
  final double opacity;
  final Gradient? gradient;
  final EdgeInsetsGeometry? padding;

  const GlassButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.borderRadius = 18.0,
    this.blur = 40.0,
    this.opacity = -1.0,
    this.gradient,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return LiquidButton(
      onTap: onPressed,
      borderRadius: borderRadius,
      normalOpacity: opacity >= 0 ? opacity : 0.14,
      pressedOpacity: (opacity >= 0 ? opacity + 0.1 : 0.22).clamp(0.0, 1.0),
      child: Container(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: DefaultTextStyle(
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            fontFamily: 'SF Pro Display',
            fontFamilyFallback: [GoogleFonts.sora().fontFamily ?? 'Sora'],
          ),
          child: child,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════
// NOISE/GRAIN BACKGROUND OVERLAY PAINTER
// ═══════════════════════════════════════

class NoisePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 1.0;

    final double width = size.width;
    final double height = size.height;
    if (width <= 0 || height <= 0) return;

    int seed = 42;
    int nextRandom() {
      seed = (seed * 1103515245 + 12345) & 0x7fffffff;
      return seed;
    }

    final List<Offset> points = [];
    for (int i = 0; i < 800; i++) {
      final x = (nextRandom() % 10000) / 10000.0 * width;
      final y = (nextRandom() % 10000) / 10000.0 * height;
      points.add(Offset(x, y));
    }

    canvas.drawPoints(PointMode.points, points, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ═══════════════════════════════════════
// LIQUID BACKGROUND (GRADIENT MESH + NOISE)
// ═══════════════════════════════════════

class LiquidBackground extends StatefulWidget {
  final Widget child;
  const LiquidBackground({super.key, required this.child});

  @override
  State<LiquidBackground> createState() => _LiquidBackgroundState();
}

class _LiquidBackgroundState extends State<LiquidBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
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
        final color = Color.lerp(
          const Color(0xFF0A0A1A),
          const Color(0xFF0D1B3E),
          _animation.value,
        )!;

        return Stack(
          children: [
            // Base background color
            Positioned.fill(
              child: Container(color: color),
            ),
            // Glow mesh blob 1
            Positioned(
              top: -50 + 30 * _animation.value,
              right: -50 + 20 * _animation.value,
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF007AFF).withOpacity(0.15 + 0.05 * _animation.value),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Glow mesh blob 2
            Positioned(
              bottom: -100 - 20 * _animation.value,
              left: -100 + 40 * _animation.value,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF5856D6).withOpacity(0.12 + 0.04 * (1.0 - _animation.value)),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Noise overlay
            Positioned.fill(
              child: CustomPaint(
                painter: NoisePainter(),
              ),
            ),
            if (widget.child != null) widget.child!,
          ],
        );
      },
      child: widget.child,
    );
  }
}

// ═══════════════════════════════════════
// FLOATING HERO PARALLAX WRAPPER
// ═══════════════════════════════════════

class FloatingHero extends StatefulWidget {
  final Widget child;
  const FloatingHero({super.key, required this.child});

  @override
  State<FloatingHero> createState() => _FloatingHeroState();
}

class _FloatingHeroState extends State<FloatingHero> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _float;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _float = Tween<double>(begin: -6.0, end: 6.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
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
      animation: _float,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _float.value),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

// ═══════════════════════════════════════
// GLASS APP BAR (HEIGHT 90 + SAFE AREA)
// ═══════════════════════════════════════

class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;

  const GlassAppBar({
    super.key,
    this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          color: Colors.black.withOpacity(0.15),
          child: SafeArea(
            child: AppBar(
              title: title,
              actions: actions,
              leading: leading,
              automaticallyImplyLeading: automaticallyImplyLeading,
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              titleTextStyle: TextStyle(
                fontFamily: 'SF Pro Display',
                fontFamilyFallback: [GoogleFonts.sora().fontFamily ?? 'Sora'],
                fontWeight: FontWeight.w600,
                fontSize: 17,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
              iconTheme: const IconThemeData(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(90);
}

// ═══════════════════════════════════════
// GLASS ROUTE TRANSITIONS (iOS 26 STANDARD)
// ═══════════════════════════════════════

class GlassRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  GlassRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: kSlow,
          reverseTransitionDuration: kNormal,
          transitionsBuilder: (context, animation, secondary, child) {
            // Forward: slide up + fade in
            final slide = Tween<Offset>(
              begin: const Offset(0, 0.06),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: kSpring,
            ));
            // Back: secondary screen slides slightly left
            final secondarySlide = Tween<Offset>(
              begin: Offset.zero,
              end: const Offset(-0.08, 0),
            ).animate(CurvedAnimation(
              parent: secondary,
              curve: kSmooth,
            ));
            return SlideTransition(
              position: secondarySlide,
              child: FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: slide,
                  child: child,
                ),
              ),
            );
          },
        );
}

// ═══════════════════════════════════════
// INPUT FIELD DECORATION
// ═══════════════════════════════════════

InputDecoration getGlassInputDecoration({
  required String hintText,
  Widget? prefixIcon,
  Widget? suffixIcon,
  required BuildContext context,
}) {
  return InputDecoration(
    hintText: hintText,
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: Colors.white.withOpacity(0.1),
    hintStyle: TextStyle(
      color: Colors.white.withOpacity(0.4),
      fontFamily: 'SF Pro Display',
      fontFamilyFallback: [GoogleFonts.sora().fontFamily ?? 'Sora'],
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(
        color: const Color(0xFF007AFF).withOpacity(0.5),
        width: 1.5,
      ),
    ),
  );
}

import 'dart:ui';
import 'dart:math' as math;
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoinAnimationDialog extends StatefulWidget {
  static const String _logTag = 'CoinAnimationDialog';
  final int coinsAwarded;
  final VoidCallback? onComplete;

  const CoinAnimationDialog({
    super.key,
    required this.coinsAwarded,
    this.onComplete,
  });

  static void show(
    BuildContext context, {
    required int coinsAwarded,
    VoidCallback? onComplete,
  }) {
    developer.log('Showing coin animation dialog', name: _logTag);
    showDialog(
      context: context,
      barrierDismissible: false, // Handled internally by GestureDetector
      barrierColor: Colors.transparent, // We handle the dimming in the dialog itself
      builder: (context) => CoinAnimationDialog(
        coinsAwarded: coinsAwarded,
        onComplete: onComplete,
      ),
    );
  }

  @override
  State<CoinAnimationDialog> createState() => _CoinAnimationDialogState();
}

class _CoinAnimationDialogState extends State<CoinAnimationDialog>
    with TickerProviderStateMixin {
  // Controllers
  late AnimationController _entranceController;
  late AnimationController _breathingController;
  late AnimationController _confettiController;

  // Animations
  late Animation<double> _scaleAnimation;
  late Animation<double> _confettiAnimation;

  bool _isClosing = false;
  late final int _coins;


  @override
  void initState() {
    super.initState();
    _coins = widget.coinsAwarded;
    _setupAnimations();
  }

  void _setupAnimations() {
    // 1. Entrance (Pop) Controller
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

  _scaleAnimation = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(begin: 0.0, end: 1.3),
      weight: 70,
    ),
    TweenSequenceItem(
      tween: Tween(begin: 1.3, end: 1.0),
      weight: 30,
    ),
  ]).animate(
    CurvedAnimation(
      parent: _entranceController,
      curve: Curves.elasticOut,
    ),
  );

    // 2. Breathing Text Controller (Looping)
    _breathingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _breathingController.repeat(reverse: true);

    // 3. Confetti Controller (One shot)
    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _confettiAnimation = CurvedAnimation(
      parent: _confettiController,
      curve: Curves.decelerate,
    );

    // Start Sequence
    _entranceController.forward();
    
    // Trigger confetti slightly after pop starts for impact
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _confettiController.forward();
    });
  }

  void _handleClose() {
    if (_isClosing) return;
    _isClosing = true;

    // immediate stop
    _entranceController.stop();
    _breathingController.stop();
    _confettiController.stop();

    developer.log('Closing coin animation dialog', name: CoinAnimationDialog._logTag);
    Navigator.of(context).pop();
    widget.onComplete?.call();
  }

  @override
  void dispose() {
    developer.log('Disposing coin animation dialog', name: CoinAnimationDialog._logTag);
    _entranceController.dispose();
    _breathingController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Full screen gesture detector to handle "Tap anywhere to skip"
    return GestureDetector(
      onTap: _handleClose,
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // 1. Dimmed Background (Manual implementation to ensure tap works everywhere)
            Container(color: Colors.black.withOpacity(0.65)),

            // 2. Centered Content
            Center(
              child: AnimatedBuilder(
                animation: _entranceController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: child,
                  );
                },
                child: _buildGlassCard(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: CustomPaint(
          painter: _GradientBorderPainter(
            radius: 24.r,
            strokeWidth: 2,
            gradient: const LinearGradient(
              colors: [Color(0xFFFFD700), Color(0xFFB8860B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Container(
            width: 320.w,
            padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 20.w),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black87, Colors.transparent],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Stack for Coin + Confetti
                SizedBox(
                  height: 160.h,
                  width: 300.w,
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      // Confetti Layer (Behind Coin)
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _ConfettiPainter(
                            animation: _confettiAnimation,
                            particleCount: 8,
                          ),
                        ),
                      ),
                      // The Premium Coin
                      _PremiumCoin(animation: _entranceController),
                    ],
                  ),
                ),
                
                SizedBox(height: 24.h),
                
                // Number Ticker
                TweenAnimationBuilder<int>(
                  tween: IntTween(begin: 0, end: _coins),
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeOutQuart,
                  builder: (context, value, child) {
                    return Text(
                      '+$value',
                      style: TextStyle(
                        color: const Color(0xFFFFD700),
                        fontSize: 48.sp,
                        fontWeight: FontWeight.w900,
                        shadows: [
                          BoxShadow(
                            color: Colors.amber.withOpacity(0.5),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                    );
                  },
                ),
                
                SizedBox(height: 8.h),
                
                Text(
                  'COINS EARNED', // Uppercase usually looks more premium
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16.sp,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                SizedBox(height: 40.h),

                // Footer: Breathing "Tap to skip"
                AnimatedBuilder(
                  animation: _breathingController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: 0.5 + (_breathingController.value * 0.5),
                      child: child,
                    );
                  },
                  child: Text(
                    'Tap anywhere to skip',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 1. Premium Coin Widget (Layers: Glow -> Gradient Body -> Highlight)
// ---------------------------------------------------------------------------
class _PremiumCoin extends StatelessWidget {
  final Animation<double> animation;

  const _PremiumCoin({required this.animation});

  @override
  Widget build(BuildContext context) {
    double coinSize = 130.sp;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Layer 1: Glow
        AnimatedBuilder(
          animation: animation, // pass entrance animation in constructor
          builder: (_, __) {
            final pulse = 1 + (math.sin(animation.value * math.pi) * 0.15);
            return Container(
              width: coinSize * pulse,
              height: coinSize * pulse,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.6),
                    blurRadius: 40,
                    spreadRadius: 6,
                  ),
                ],
              ),
            );
          },
        ),
        
        // Layer 2: Coin Body
        Container(
          width: coinSize,
          height: coinSize,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFD700), Color(0xFFB8860B)], // Gold to Dark Gold
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black45,
                offset: Offset(2, 2),
                blurRadius: 4,
                spreadRadius: 0,
              )
            ],
          ),
          child: Center(
            child: Text(
              'C', // Or custom currency symbol
              style: TextStyle(
                color: Colors.black.withOpacity(0.35),
                fontSize: coinSize * 0.6,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        // Layer 3: Highlight (Reflection)
        // Using ClipOval to ensure the highlight stays inside the circle
        ClipOval(
          child: Container(
            width: coinSize,
            height: coinSize,
            alignment: Alignment.topCenter,
            child: Container(
              width: coinSize,
              height: coinSize / 2, // Only top half
              margin: EdgeInsets.only(top: 10.h), // Offset slightly
              decoration: BoxDecoration(
                 gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.5),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 2. Custom Gradient Border Painter
// ---------------------------------------------------------------------------
class _GradientBorderPainter extends CustomPainter {
  final double radius;
  final double strokeWidth;
  final Gradient gradient;

  _GradientBorderPainter({
    required this.radius,
    required this.strokeWidth,
    required this.gradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final RRect rRect = RRect.fromRectAndRadius(rect, Radius.circular(radius));

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = gradient.createShader(rect);

    canvas.drawRRect(rRect, paint);
  }

  @override
  bool shouldRepaint(covariant _GradientBorderPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// 3. Optimized Confetti Painter
// ---------------------------------------------------------------------------
class _ConfettiPainter extends CustomPainter {
  final Animation<double> animation;
  final int particleCount;
  late final List<_Particle> _particles;

  _ConfettiPainter({
    required this.animation,
    required this.particleCount,
  }) : super(repaint: animation) {
    _particles = List.generate(
      particleCount,
      (_) => _Particle.random(),
    );
  }

  // void _initParticles() {
  //   final random = math.Random();
  //   for (int i = 0; i < particleCount; i++) {
  //     // Radial distribution (0 to 360 degrees)
  //     final angle = random.nextDouble() * 2 * math.pi;
  //     // Random speed/distance
  //     final speed = 60.0 + random.nextDouble() * 60.0; 
  //     // Random size
  //     final size = 3.0 + random.nextDouble() * 4.0;
      
  //     _particles.add(_Particle(angle, speed, size));
  //   }
  // }

  @override
  void paint(Canvas canvas, Size size) {
    if (animation.value == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final Paint paint = Paint()..style = PaintingStyle.fill;

    for (var particle in _particles) {
      // Calculate position based on animation progress
      final progress = animation.value;
      
      // Move outward
      final distance = particle.speed * progress;
      final dx = math.cos(particle.angle) * distance;
      final dy = math.sin(particle.angle) * distance;

      // Opacity fade out near the end
      final opacity = (1.0 - progress).clamp(0.0, 1.0);
      paint.color = const Color(0xFFFFD700).withOpacity(opacity);

      canvas.drawCircle(
        center.translate(dx, dy),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => false;
}

class _Particle {
  final double angle;
  final double speed;
  final double size;

  factory _Particle.random() {
    final r = math.Random();
    return _Particle(
      r.nextDouble() * 2 * math.pi,
      60 + r.nextDouble() * 60,
      3 + r.nextDouble() * 4,
    );
  }

  _Particle(this.angle, this.speed, this.size);
}

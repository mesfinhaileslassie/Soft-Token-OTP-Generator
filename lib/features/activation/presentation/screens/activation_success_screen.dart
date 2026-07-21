// lib/features/activation/presentation/screens/activation_success_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:payroll_soft_token_app/app/routes/app_router.dart';
import 'package:payroll_soft_token_app/core/theme/app_theme.dart';

class ActivationSuccessScreen extends StatelessWidget {
  const ActivationSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header with #9E0000 background - Behind status bar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 40, bottom: 16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Soft Token text
                  const Text(
                    'Soft Token',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Shield Icon - Green checkmark
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      size: 32,
                      color: Color(0xFF9E0000),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Title
                  const Text(
                    'Activation Successful',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Subtitle
                  Text(
                    'Your device is ready to use',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.85),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            // Main Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Shield + Sparkles Illustration
                    const _ShieldWithSparkles(),
                    const SizedBox(height: 24),
                    // Congratulations Text
                    const Text(
                      'Congratulations!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your Device is now activated successfully',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    // Continue to Login Button
                    ElevatedButton(
                      onPressed: () {
                        context.go(AppRouter.home);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      child: const Text('Continue to Login'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Green shield-with-checkmark inside a thin circle outline,
/// surrounded by scattered twinkling sparkles - built entirely
/// from Flutter widgets (no image assets required).
class _ShieldWithSparkles extends StatelessWidget {
  const _ShieldWithSparkles();

  // Sparkle layout: (dx, dy) offset from the top-left of a 220x220 box,
  // plus a size for each sparkle. Values are tuned to roughly match
  // the reference design.
  static const List<_SparkleSpec> _sparkles = [
    _SparkleSpec(dx: 14, dy: 18, size: 11),
    _SparkleSpec(dx: 118, dy: 2, size: 15),
    _SparkleSpec(dx: 196, dy: 60, size: 11),
    _SparkleSpec(dx: 0, dy: 96, size: 11),
    _SparkleSpec(dx: 188, dy: 150, size: 16),
    _SparkleSpec(dx: 44, dy: 196, size: 11),
    _SparkleSpec(dx: 120, dy: 210, size: 11),
  ];

  @override
  Widget build(BuildContext context) {
    const double boxSize = 220;
    const double circleSize = 150;

    return SizedBox(
      width: boxSize,
      height: boxSize,
      child: Stack(
        children: [
          // Sparkles
          for (final s in _sparkles)
            Positioned(
              left: s.dx,
              top: s.dy,
              child: _Sparkle(size: s.size, color: Colors.green.shade400),
            ),
          // Center: circle outline + shield
          Center(
            child: Container(
              width: circleSize,
              height: circleSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.green.shade300, width: 1.5),
              ),
              child: Center(
                child: CustomPaint(
                  size: const Size(72, 80),
                  painter: _ShieldCheckPainter(color: Colors.green.shade600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SparkleSpec {
  final double dx;
  final double dy;
  final double size;

  const _SparkleSpec({required this.dx, required this.dy, required this.size});
}

/// A small 4-pointed twinkle/sparkle shape.
class _Sparkle extends StatelessWidget {
  final double size;
  final Color color;

  const _Sparkle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _SparklePainter(color: color),
    );
  }
}

class _SparklePainter extends CustomPainter {
  final Color color;

  _SparklePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final double w = size.width;
    final double h = size.height;
    final double cx = w / 2;
    final double cy = h / 2;

    // 4-pointed star with concave sides (classic "sparkle" glyph).
    final Path path = Path();
    path.moveTo(cx, 0);
    path.quadraticBezierTo(cx, cy * 0.55, w, cy);
    path.quadraticBezierTo(cx * 1.45, cy, cx, h);
    path.quadraticBezierTo(cx, cy * 1.45, 0, cy);
    path.quadraticBezierTo(cx * 0.55, cy, cx, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SparklePainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Draws a filled shield outline with a checkmark inside, matching
/// the green shield-with-check illustration in the reference design.
class _ShieldCheckPainter extends CustomPainter {
  final Color color;

  _ShieldCheckPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final double w = size.width;
    final double h = size.height;

    // Shield outline: rounded top corners, pointed bottom.
    final Path shieldPath = Path();
    shieldPath.moveTo(w * 0.5, 0);
    shieldPath.cubicTo(w * 0.5, 0, w * 0.02, h * 0.10, w * 0.02, h * 0.10);
    shieldPath.lineTo(w * 0.02, h * 0.48);
    shieldPath.cubicTo(w * 0.02, h * 0.78, w * 0.22, h * 0.94, w * 0.5, h);
    shieldPath.cubicTo(
      w * 0.78,
      h * 0.94,
      w * 0.98,
      h * 0.78,
      w * 0.98,
      h * 0.48,
    );
    shieldPath.lineTo(w * 0.98, h * 0.10);
    shieldPath.cubicTo(w * 0.98, h * 0.10, w * 0.5, 0, w * 0.5, 0);
    shieldPath.close();

    canvas.drawPath(shieldPath, fillPaint);

    // Checkmark
    final Paint checkPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.09
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final Path checkPath = Path();
    checkPath.moveTo(w * 0.28, h * 0.50);
    checkPath.lineTo(w * 0.44, h * 0.66);
    checkPath.lineTo(w * 0.74, h * 0.32);

    canvas.drawPath(checkPath, checkPaint);
  }

  @override
  bool shouldRepaint(covariant _ShieldCheckPainter oldDelegate) =>
      oldDelegate.color != color;
}

import 'dart:math' as math;
import 'package:flutter/material.dart';

class KaliwediLogo extends StatelessWidget {
  final double size;
  final bool animate;

  const KaliwediLogo({
    super.key,
    this.size = 120.0,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget logo = SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: KaliwediLogoPainter(),
      ),
    );

    if (animate) {
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 1200),
        curve: Curves.elasticOut,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: child,
          );
        },
        child: logo,
      );
    }

    return logo;
  }
}

class KaliwediLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Paints
    // Left stem gradient (Purple-blue-teal)
    final Paint leftStemPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF3B2A6B), // Deep Purple
          Color(0xFF2E5B9A), // Deep Blue
          Color(0xFF1E3A8A), // App Primary Blue
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;

    // Top-right diagonal gradient (Cyan-Teal-LightBlue)
    final Paint topRightPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
        colors: [
          Color(0xFF0F766E), // Teal Primary
          Color(0xFF0D9488), // Teal
          Color(0xFF22D3EE), // Cyan
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;

    // Bottom-right diagonal gradient (Orange-Red-Yellow)
    final Paint bottomRightPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFF97316), // Primary Orange
          Color(0xFFEA580C), // Dark Orange
          Color(0xFFEF4444), // Danger Red
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;

    // Water drop paint (Light Cyan / Blue Gradient)
    final Paint dropPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFCCFBFC),
          Color(0xFF38BDF8),
        ],
      ).createShader(Rect.fromLTWH(w * 0.1, h * 0.5, w * 0.2, h * 0.4))
      ..style = PaintingStyle.fill;

    // Background drop outline paint
    final Paint dropOutlinePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.025;

    // Outer white glow/outline paint for logo parts
    final Paint borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.015
      ..strokeCap = StrokeCap.round;

    // 1. Draw Left Stem (Vertical bar with rounded ends, and a drop-cutout look)
    final Path leftStemPath = Path();
    final double leftX = w * 0.25;
    final double rightX = w * 0.38;
    final double stemTop = h * 0.12;
    final double stemBottom = h * 0.88;

    leftStemPath.moveTo(leftX + (rightX - leftX) / 2, stemTop);
    // Top rounded cap
    leftStemPath.arcToPoint(
      Offset(rightX, stemTop + (rightX - leftX) / 2),
      radius: Radius.circular((rightX - leftX) / 2),
      clockwise: true,
    );
    // Line down to bottom-right
    leftStemPath.lineTo(rightX, stemBottom - (rightX - leftX) / 2);
    // Bottom rounded cap
    leftStemPath.arcToPoint(
      Offset(leftX, stemBottom - (rightX - leftX) / 2),
      radius: Radius.circular((rightX - leftX) / 2),
      clockwise: true,
    );
    // Line back up to top-left
    leftStemPath.lineTo(leftX, stemTop + (rightX - leftX) / 2);
    leftStemPath.arcToPoint(
      Offset(leftX + (rightX - leftX) / 2, stemTop),
      radius: Radius.circular((rightX - leftX) / 2),
      clockwise: true,
    );
    leftStemPath.close();

    canvas.drawPath(leftStemPath, leftStemPaint);
    canvas.drawPath(leftStemPath, borderPaint);

    // 2. Draw Top-Right Arm of K (Curved brush shape)
    final Path topRightPath = Path();
    topRightPath.moveTo(rightX - 2, h * 0.42);
    topRightPath.cubicTo(
      w * 0.55, h * 0.42,
      w * 0.62, h * 0.12,
      w * 0.82, h * 0.12,
    );
    topRightPath.arcToPoint(
      Offset(w * 0.85, h * 0.26),
      radius: Radius.circular(h * 0.07),
      clockwise: true,
    );
    topRightPath.cubicTo(
      w * 0.70, h * 0.26,
      w * 0.58, h * 0.52,
      rightX - 2, h * 0.55,
    );
    topRightPath.close();

    canvas.drawPath(topRightPath, topRightPaint);
    canvas.drawPath(topRightPath, borderPaint);

    // 3. Draw Bottom-Right Leg of K (Curved leg shape)
    final Path bottomRightPath = Path();
    bottomRightPath.moveTo(rightX - 2, h * 0.54);
    bottomRightPath.cubicTo(
      w * 0.54, h * 0.55,
      w * 0.60, h * 0.78,
      w * 0.85, h * 0.78,
    );
    bottomRightPath.arcToPoint(
      Offset(w * 0.82, h * 0.64),
      radius: Radius.circular(h * 0.07),
      clockwise: false,
    );
    bottomRightPath.cubicTo(
      w * 0.64, h * 0.64,
      w * 0.56, h * 0.46,
      rightX - 2, h * 0.45,
    );
    bottomRightPath.close();

    canvas.drawPath(bottomRightPath, bottomRightPaint);
    canvas.drawPath(bottomRightPath, borderPaint);

    // 4. Draw Water Drop on the bottom left stem
    final Path dropPath = Path();
    final double dropCenterX = w * 0.315;
    final double dropCenterY = h * 0.74;
    final double dropRadius = w * 0.09;

    // A drop shape: curve from a pointed top down to rounded bottom
    dropPath.moveTo(dropCenterX, dropCenterY - dropRadius * 1.5);
    // Curve to right side
    dropPath.cubicTo(
      dropCenterX + dropRadius * 1.1, dropCenterY - dropRadius * 0.8,
      dropCenterX + dropRadius, dropCenterY + dropRadius,
      dropCenterX, dropCenterY + dropRadius * 1.2,
    );
    // Curve to left side
    dropPath.cubicTo(
      dropCenterX - dropRadius, dropCenterY + dropRadius,
      dropCenterX - dropRadius * 1.1, dropCenterY - dropRadius * 0.8,
      dropCenterX, dropCenterY - dropRadius * 1.5,
    );
    dropPath.close();

    // Fill drop background with a darker color for contrast
    final Paint dropBgPaint = Paint()
      ..color = const Color(0xFF1E3A8A)
      ..style = PaintingStyle.fill;
    canvas.drawPath(dropPath, dropBgPaint);

    // Draw drop shape itself
    canvas.drawPath(dropPath, dropPaint);
    canvas.drawPath(dropPath, dropOutlinePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

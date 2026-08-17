import 'dart:math' as math;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sfa/utils/app_style.dart';

class BrandsPromoBanner extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String subtitle;
  final String brandName;
  final VoidCallback? onTap;

  const BrandsPromoBanner({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.brandName,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 500,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── Background image ──
            CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: const Color(0xFF111111)),
              errorWidget: (_, __, ___) =>
                  Container(color: const Color(0xFF111111)),
            ),

            // ── Dark/Tint overlay ──
            Container(color: Colors.black.withOpacity(0.25)),

            // ── Summer / Beach line drawings overlay ──
            Positioned.fill(
              child: CustomPaint(painter: _PromoBannerDecorationPainter()),
            ),

            // ── Text content — Centered ──
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: AppStyle.promoBannerTitle.copyWith(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.2,
                      shadows: [
                        const Shadow(
                          color: Colors.black45,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: AppStyle.promoBannerSubtitle.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.2,
                      shadows: [
                        const Shadow(
                          color: Colors.black45,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.white, width: 1.5),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      'تسوق الآن',
                      style: AppStyle.bodyText.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Summer Line Art Painter ──────────────────────────────────────────────────

class _PromoBannerDecorationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // 1. Starfish on the left bottom (around x: 45, y: size.height - 40)
    final starfishPath = Path();
    final double cx = 45;
    final double cy = size.height - 40;
    final int points = 5;
    final double outerRadius = 24;
    final double innerRadius = 9;
    double angle = -math.pi / 2;
    final double angleStep = math.pi / points;

    for (int i = 0; i < points * 2; i++) {
      final double r = i.isEven ? outerRadius : innerRadius;
      final double x = cx + r * math.cos(angle);
      final double y = cy + r * math.sin(angle);
      if (i == 0) {
        starfishPath.moveTo(x, y);
      } else {
        // Use quadratic bezier to give a organic/rounded starfish feel
        final double prevAngle = angle - angleStep;
        final double prevR = i.isOdd ? outerRadius : innerRadius;
        final double midAngle = angle - angleStep / 2;
        final double midR = (outerRadius + innerRadius) / 2 * 0.9;
        final double ctrlX = cx + midR * math.cos(midAngle);
        final double ctrlY = cy + midR * math.sin(midAngle);
        starfishPath.quadraticBezierTo(ctrlX, ctrlY, x, y);
      }
      angle += angleStep;
    }
    starfishPath.close();
    canvas.drawPath(starfishPath, paint);

    // Minor decorative dots/details inside starfish
    canvas.drawCircle(Offset(cx, cy), 1.5, paint..style = PaintingStyle.fill);
    paint.style = PaintingStyle.stroke;

    // 2. Seashell (Scallop) in the middle-left (around x: 120, y: size.height - 35)
    final shellPath = Path();
    final double sx = 120;
    final double sy = size.height - 35;
    shellPath.moveTo(sx, sy);
    // Draw scallop fans
    shellPath.cubicTo(sx - 20, sy - 28, sx - 15, sy - 38, sx, sy - 35);
    shellPath.cubicTo(sx + 15, sy - 38, sx + 20, sy - 28, sx, sy);
    canvas.drawPath(shellPath, paint);
    // Scallop ribs
    canvas.drawLine(Offset(sx, sy), Offset(sx, sy - 35), paint);
    canvas.drawLine(Offset(sx, sy), Offset(sx - 8, sy - 33), paint);
    canvas.drawLine(Offset(sx, sy), Offset(sx + 8, sy - 33), paint);
    canvas.drawLine(Offset(sx, sy), Offset(sx - 14, sy - 25), paint);
    canvas.drawLine(Offset(sx, sy), Offset(sx + 14, sy - 25), paint);

    // 3. Seaweed/Corals in the middle-right (around x: 190, y: size.height - 35)
    final coralPath = Path();
    final double kx = 190;
    final double ky = size.height - 15;
    coralPath.moveTo(kx, ky);
    coralPath.quadraticBezierTo(kx - 5, ky - 15, kx - 2, ky - 28);
    coralPath.moveTo(kx - 2, ky - 12);
    coralPath.quadraticBezierTo(kx + 8, ky - 22, kx + 12, ky - 30);
    coralPath.moveTo(kx, ky - 6);
    coralPath.quadraticBezierTo(kx - 12, ky - 18, kx - 14, ky - 24);
    canvas.drawPath(coralPath, paint);

    // 4. Beach Umbrella on the far right (around x: size.width - 50, y: size.height - 55)
    final double ux = size.width - 55;
    final double uy = size.height - 50;

    // Pole (tilted)
    canvas.drawLine(Offset(ux, uy + 35), Offset(ux - 12, uy - 12), paint);

    // Canopy (umbrella dome)
    final double radius = 26;
    final double tiltAngle = -0.3; // Radians tilt

    // Draw dome arc
    final umbrellaCanopy = Path();
    // We create a dome centered at (ux - 12, uy - 12)
    final double cxU = ux - 12;
    final double cyU = uy - 12;

    // Dome top arc
    umbrellaCanopy.moveTo(
      cxU - radius * math.cos(tiltAngle),
      cyU - radius * math.sin(tiltAngle),
    );
    umbrellaCanopy.quadraticBezierTo(
      cxU - radius * math.sin(-tiltAngle) * 0.5,
      cyU - radius * 1.3,
      cxU + radius * math.cos(tiltAngle),
      cyU + radius * math.sin(tiltAngle),
    );

    // Dome bottom wave
    final double startX = cxU + radius * math.cos(tiltAngle);
    final double startY = cyU + radius * math.sin(tiltAngle);
    final double endX = cxU - radius * math.cos(tiltAngle);
    final double endY = cyU - radius * math.sin(tiltAngle);
    umbrellaCanopy.lineTo(endX, endY);

    canvas.drawPath(umbrellaCanopy, paint);

    // Draw panels/stripes of the umbrella
    canvas.drawLine(Offset(cxU, cyU - radius * 0.9), Offset(cxU, cyU), paint);
    canvas.drawLine(
      Offset(cxU - radius * 0.5, cyU - radius * 0.6),
      Offset(cxU, cyU),
      paint,
    );
    canvas.drawLine(
      Offset(cxU + radius * 0.5, cyU - radius * 0.6),
      Offset(cxU, cyU),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

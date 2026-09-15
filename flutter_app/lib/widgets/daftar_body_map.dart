import 'package:flutter/material.dart';
import '../core/constants.dart';

class DaftarBodyMap extends StatelessWidget {
  final String? selectedRegion;
  final ValueChanged<String?> onRegionSelected;

  const DaftarBodyMap({
    super.key,
    this.selectedRegion,
    required this.onRegionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 180,
        height: 320,
        child: GestureDetector(
          onTapUp: (details) {
            final local = details.localPosition;
            // Map the tapped point from 180x320 box to 200x360 SVG coordinates
            final x = local.dx * (200 / 180);
            final y = local.dy * (360 / 320);

            String? region;
            // راس: cx=100, cy=32, r=24
            if ((x - 100) * (x - 100) + (y - 32) * (y - 32) <= 24 * 24) {
              region = 'راس';
            }
            // صدر: x=62..138, y=66..116
            else if (x >= 62 && x <= 138 && y >= 66 && y <= 116) {
              region = 'صدر';
            }
            // معدة: x=66..134, y=118..156
            else if (x >= 66 && x <= 134 && y >= 118 && y <= 156) {
              region = 'معدة';
            }
            // بطن: x=68..132, y=158..198
            else if (x >= 68 && x <= 132 && y >= 158 && y <= 198) {
              region = 'بطن';
            }
            // ذراعين: x=38..56 or 144..162, y=70..176
            else if ((x >= 38 && x <= 56 && y >= 70 && y <= 176) ||
                (x >= 144 && x <= 162 && y >= 70 && y <= 176)) {
              region = 'ذراعين';
            }
            // ساقين: x=72..96 or 104..128, y=202..348
            else if ((x >= 72 && x <= 96 && y >= 202 && y <= 348) ||
                (x >= 104 && x <= 128 && y >= 202 && y <= 348)) {
              region = 'ساقين';
            }

            if (region == selectedRegion) {
              onRegionSelected(null);
            } else {
              onRegionSelected(region);
            }
          },
          child: CustomPaint(
            painter: _BodyMapPainter(selectedRegion: selectedRegion),
            size: const Size(180, 320),
          ),
        ),
      ),
    );
  }
}

class _BodyMapPainter extends CustomPainter {
  final String? selectedRegion;

  _BodyMapPainter({this.selectedRegion});

  @override
  void paint(Canvas canvas, Size size) {
    // Scale canvas from 200x360 SVG coordinates to widget size
    final scaleX = size.width / 200.0;
    final scaleY = size.height / 360.0;
    canvas.scale(scaleX, scaleY);

    Paint defaultPaint = Paint()
      ..color = AppColors.paperDeep
      ..style = PaintingStyle.fill;

    Paint strokePaint = Paint()
      ..color = AppColors.hairlineStrong
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    Paint pickedPaint = Paint()
      ..color = AppColors.healthTint
      ..style = PaintingStyle.fill;

    Paint pickedStrokePaint = Paint()
      ..color = AppColors.health
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;

    void drawPart(String region, void Function(Paint fill, Paint stroke) drawCmd) {
      final isPicked = selectedRegion == region;
      final fill = isPicked ? pickedPaint : defaultPaint;
      final stroke = isPicked ? pickedStrokePaint : strokePaint;
      drawCmd(fill, stroke);
    }

    // 1. الرأس: circle cx=100 cy=32 r=24
    drawPart('راس', (fill, stroke) {
      canvas.drawCircle(const Offset(100, 32), 24, fill);
      canvas.drawCircle(const Offset(100, 32), 24, stroke);
    });

    // 2. الرقبة (body-neutral): rect x=92 y=54 w=16 h=12 rx=4
    final neckRRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(92, 54, 16, 12),
      const Radius.circular(4),
    );
    canvas.drawRRect(neckRRect, defaultPaint);
    canvas.drawRRect(neckRRect, strokePaint);

    // 3. الصدر: rect x=62 y=66 w=76 h=50 rx=14
    drawPart('صدر', (fill, stroke) {
      final rrect = RRect.fromRectAndRadius(
        const Rect.fromLTWH(62, 66, 76, 50),
        const Radius.circular(14),
      );
      canvas.drawRRect(rrect, fill);
      canvas.drawRRect(rrect, stroke);
    });

    // 4. المعدة: rect x=66 y=118 w=68 h=38 rx=10
    drawPart('معدة', (fill, stroke) {
      final rrect = RRect.fromRectAndRadius(
        const Rect.fromLTWH(66, 118, 68, 38),
        const Radius.circular(10),
      );
      canvas.drawRRect(rrect, fill);
      canvas.drawRRect(rrect, stroke);
    });

    // 5. البطن: rect x=68 y=158 w=64 h=40 rx=10
    drawPart('بطن', (fill, stroke) {
      final rrect = RRect.fromRectAndRadius(
        const Rect.fromLTWH(68, 158, 64, 40),
        const Radius.circular(10),
      );
      canvas.drawRRect(rrect, fill);
      canvas.drawRRect(rrect, stroke);
    });

    // 6. الذراعين: x=38 y=70 w=18 h=106 rx=9 and x=144 y=70 w=18 h=106 rx=9
    drawPart('ذراعين', (fill, stroke) {
      final leftArm = RRect.fromRectAndRadius(
        const Rect.fromLTWH(38, 70, 18, 106),
        const Radius.circular(9),
      );
      final rightArm = RRect.fromRectAndRadius(
        const Rect.fromLTWH(144, 70, 18, 106),
        const Radius.circular(9),
      );
      canvas.drawRRect(leftArm, fill);
      canvas.drawRRect(leftArm, stroke);
      canvas.drawRRect(rightArm, fill);
      canvas.drawRRect(rightArm, stroke);
    });

    // 7. الساقين: x=72 y=202 w=24 h=146 rx=11 and x=104 y=202 w=24 h=146 rx=11
    drawPart('ساقين', (fill, stroke) {
      final leftLeg = RRect.fromRectAndRadius(
        const Rect.fromLTWH(72, 202, 24, 146),
        const Radius.circular(11),
      );
      final rightLeg = RRect.fromRectAndRadius(
        const Rect.fromLTWH(104, 202, 24, 146),
        const Radius.circular(11),
      );
      canvas.drawRRect(leftLeg, fill);
      canvas.drawRRect(leftLeg, stroke);
      canvas.drawRRect(rightLeg, fill);
      canvas.drawRRect(rightLeg, stroke);
    });
  }

  @override
  bool shouldRepaint(covariant _BodyMapPainter oldDelegate) {
    return oldDelegate.selectedRegion != selectedRegion;
  }
}

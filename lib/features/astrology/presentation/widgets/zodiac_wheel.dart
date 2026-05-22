import 'dart:math';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/natal_chart.dart';

class ZodiacWheel extends StatelessWidget {
  final NatalChart chart;

  const ZodiacWheel({super.key, required this.chart});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: CustomPaint(
        painter: _ZodiacWheelPainter(chart: chart),
      ),
    );
  }
}

class _ZodiacWheelPainter extends CustomPainter {
  final NatalChart chart;

  _ZodiacWheelPainter({required this.chart});

  static const _signs = [
    '♈', '♉', '♊', '♋', '♌', '♍',
    '♎', '♏', '♐', '♑', '♒', '♓',
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;

    final outerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = AppColors.cardBorder
      ..strokeWidth = 1;

    canvas.drawCircle(center, radius, outerPaint);
    canvas.drawCircle(center, radius * 0.7, outerPaint);
    canvas.drawCircle(center, radius * 0.3, outerPaint);

    for (var i = 0; i < 12; i++) {
      final angle = (i * 30 - 90) * pi / 180;
      final start = Offset(
        center.dx + radius * 0.7 * cos(angle),
        center.dy + radius * 0.7 * sin(angle),
      );
      final end = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      canvas.drawLine(start, end, outerPaint);

      final signAngle = ((i * 30 + 15) - 90) * pi / 180;
      final signPos = Offset(
        center.dx + radius * 0.85 * cos(signAngle),
        center.dy + radius * 0.85 * sin(signAngle),
      );

      final textPainter = TextPainter(
        text: TextSpan(
          text: _signs[i],
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        signPos - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }

    final centerGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.accentGlow.withOpacity(0.3),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 0.3));
    canvas.drawCircle(center, radius * 0.3, centerGlow);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

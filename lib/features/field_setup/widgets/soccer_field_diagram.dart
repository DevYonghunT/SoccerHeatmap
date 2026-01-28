import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/typography.dart';

class SoccerFieldDiagram extends StatelessWidget {
  final bool showCorners;
  final bool showTracking;
  final bool showDimensions;
  final double lengthMeters;
  final double widthMeters;

  const SoccerFieldDiagram({
    super.key,
    this.showCorners = false,
    this.showTracking = false,
    this.showDimensions = false,
    this.lengthMeters = 105,
    this.widthMeters = 68,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.6,
      child: CustomPaint(
        painter: _FieldPainter(
          showCorners: showCorners,
          showTracking: showTracking,
          showDimensions: showDimensions,
          lengthMeters: lengthMeters,
          widthMeters: widthMeters,
        ),
      ),
    );
  }
}

class _FieldPainter extends CustomPainter {
  final bool showCorners;
  final bool showTracking;
  final bool showDimensions;
  final double lengthMeters;
  final double widthMeters;

  _FieldPainter({
    required this.showCorners,
    required this.showTracking,
    required this.showDimensions,
    required this.lengthMeters,
    required this.widthMeters,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final fieldRect = Rect.fromLTWH(
      size.width * 0.1,
      size.height * 0.1,
      size.width * 0.8,
      size.height * 0.8,
    );

    final linePaint = Paint()
      ..color = showDimensions ? AppColors.success.withValues(alpha: 0.6) : AppColors.fieldLine
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Field outline
    canvas.drawRect(fieldRect, linePaint);

    // Center line
    canvas.drawLine(
      Offset(fieldRect.center.dx, fieldRect.top),
      Offset(fieldRect.center.dx, fieldRect.bottom),
      linePaint,
    );

    // Center circle
    canvas.drawCircle(
      fieldRect.center,
      fieldRect.height * 0.18,
      linePaint,
    );

    // Center dot
    final dotPaint = Paint()
      ..color = linePaint.color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(fieldRect.center, 3, dotPaint);

    // Penalty areas
    final penaltyWidth = fieldRect.width * 0.15;
    final penaltyHeight = fieldRect.height * 0.44;
    final penaltyY = fieldRect.center.dy - penaltyHeight / 2;

    // Left penalty box
    canvas.drawRect(
      Rect.fromLTWH(fieldRect.left, penaltyY, penaltyWidth, penaltyHeight),
      linePaint,
    );

    // Right penalty box
    canvas.drawRect(
      Rect.fromLTWH(
        fieldRect.right - penaltyWidth,
        penaltyY,
        penaltyWidth,
        penaltyHeight,
      ),
      linePaint,
    );

    // Goal areas
    final goalWidth = fieldRect.width * 0.06;
    final goalHeight = fieldRect.height * 0.22;
    final goalY = fieldRect.center.dy - goalHeight / 2;

    canvas.drawRect(
      Rect.fromLTWH(fieldRect.left, goalY, goalWidth, goalHeight),
      linePaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(fieldRect.right - goalWidth, goalY, goalWidth, goalHeight),
      linePaint,
    );

    // Corner markers
    if (showCorners) {
      final cornerPaint = Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.fill;

      final corners = [
        fieldRect.topLeft,
        fieldRect.topRight,
        fieldRect.bottomRight,
        fieldRect.bottomLeft,
      ];
      for (final corner in corners) {
        canvas.drawCircle(corner, 5, cornerPaint);
      }
    }

    // Tracking dot (for calibrating view)
    if (showTracking) {
      final trackPaint = Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(fieldRect.right * 0.85, fieldRect.center.dy * 0.9),
        8,
        trackPaint,
      );

      // Glow effect
      final glowPaint = Paint()
        ..color = AppColors.primary.withValues(alpha: 0.2)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(fieldRect.right * 0.85, fieldRect.center.dy * 0.9),
        16,
        glowPaint,
      );
    }

    // Dimension labels
    if (showDimensions) {
      final textPainter = TextPainter(
        textDirection: TextDirection.ltr,
      );

      // Top dimension
      textPainter.text = TextSpan(
        text: '${lengthMeters.toInt()}m',
        style: AppTypography.caption.copyWith(
          color: AppColors.textSecondary,
          fontSize: 11,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(fieldRect.center.dx - textPainter.width / 2, fieldRect.top - 18),
      );

      // Side dimension
      textPainter.text = TextSpan(
        text: '${widthMeters.toInt()}m',
        style: AppTypography.caption.copyWith(
          color: AppColors.textSecondary,
          fontSize: 11,
        ),
      );
      textPainter.layout();
      canvas.save();
      canvas.translate(fieldRect.left - 18, fieldRect.center.dy + textPainter.width / 2);
      canvas.rotate(-3.14159 / 2);
      textPainter.paint(canvas, Offset.zero);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

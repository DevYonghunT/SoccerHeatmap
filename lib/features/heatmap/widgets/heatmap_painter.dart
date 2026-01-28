import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../data/models/match_data.dart';

class HeatmapPainter extends CustomPainter {
  final List<LocationPoint> points;
  final bool isSpeedMap;

  HeatmapPainter({
    required this.points,
    this.isSpeedMap = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw field background
    _drawField(canvas, size);

    if (points.isEmpty) return;

    // Calculate density grid
    const gridX = 20;
    const gridY = 13;
    final grid = List.generate(gridY, (_) => List.filled(gridX, 0.0));

    for (final point in points) {
      final gx = (point.x * (gridX - 1)).round().clamp(0, gridX - 1);
      final gy = (point.y * (gridY - 1)).round().clamp(0, gridY - 1);
      final value = isSpeedMap ? point.speedKmh / 30.0 : 1.0;
      grid[gy][gx] += value;
    }

    // Find max for normalization
    double maxVal = 0;
    for (final row in grid) {
      for (final val in row) {
        if (val > maxVal) maxVal = val;
      }
    }
    if (maxVal == 0) return;

    // Apply gaussian-like smoothing
    final smoothed = _smoothGrid(grid, gridX, gridY);
    double smoothMax = 0;
    for (final row in smoothed) {
      for (final val in row) {
        if (val > smoothMax) smoothMax = val;
      }
    }
    if (smoothMax == 0) return;

    // Render heatmap
    final cellW = size.width / gridX;
    final cellH = size.height / gridY;

    for (int y = 0; y < gridY; y++) {
      for (int x = 0; x < gridX; x++) {
        final intensity = smoothed[y][x] / smoothMax;
        if (intensity < 0.05) continue;

        final color = _getHeatColor(intensity);
        final paint = Paint()
          ..color = color.withValues(alpha: intensity.clamp(0.0, 0.85))
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

        final center = Offset(
          (x + 0.5) * cellW,
          (y + 0.5) * cellH,
        );

        canvas.drawCircle(center, cellW * 1.2, paint);
      }
    }
  }

  List<List<double>> _smoothGrid(List<List<double>> grid, int gx, int gy) {
    final result = List.generate(gy, (_) => List.filled(gx, 0.0));
    const kernel = [
      [0.05, 0.1, 0.05],
      [0.1, 0.4, 0.1],
      [0.05, 0.1, 0.05],
    ];

    for (int y = 0; y < gy; y++) {
      for (int x = 0; x < gx; x++) {
        double sum = 0;
        for (int ky = -1; ky <= 1; ky++) {
          for (int kx = -1; kx <= 1; kx++) {
            final ny = (y + ky).clamp(0, gy - 1);
            final nx = (x + kx).clamp(0, gx - 1);
            sum += grid[ny][nx] * kernel[ky + 1][kx + 1];
          }
        }
        result[y][x] = sum;
      }
    }
    return result;
  }

  Color _getHeatColor(double intensity) {
    if (isSpeedMap) {
      // Blue to orange to red for speed
      if (intensity < 0.5) {
        return Color.lerp(
          const Color(0xFF1E3A5F),
          AppColors.warning,
          intensity * 2,
        )!;
      } else {
        return Color.lerp(
          AppColors.warning,
          AppColors.primary,
          (intensity - 0.5) * 2,
        )!;
      }
    } else {
      // Position heatmap: blue -> yellow -> red
      if (intensity < 0.4) {
        return Color.lerp(
          const Color(0xFF1E3A5F),
          const Color(0xFFFF9500),
          intensity / 0.4,
        )!;
      } else {
        return Color.lerp(
          const Color(0xFFFF9500),
          AppColors.primary,
          (intensity - 0.4) / 0.6,
        )!;
      }
    }
  }

  void _drawField(Canvas canvas, Size size) {
    final fieldPaint = Paint()
      ..color = AppColors.fieldLine.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Outline
    canvas.drawRect(rect, fieldPaint);

    // Center line
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      fieldPaint,
    );

    // Center circle
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.height * 0.18,
      fieldPaint,
    );

    // Penalty areas
    final penW = size.width * 0.15;
    final penH = size.height * 0.44;
    final penY = (size.height - penH) / 2;

    canvas.drawRect(Rect.fromLTWH(0, penY, penW, penH), fieldPaint);
    canvas.drawRect(Rect.fromLTWH(size.width - penW, penY, penW, penH), fieldPaint);
  }

  @override
  bool shouldRepaint(covariant HeatmapPainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.isSpeedMap != isSpeedMap;
  }
}

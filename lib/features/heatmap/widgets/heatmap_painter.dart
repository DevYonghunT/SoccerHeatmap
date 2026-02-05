import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../data/models/match_data.dart';

/// 히트맵 계산 결과를 캐싱하는 클래스
class _HeatmapCache {
  final List<LocationPoint> points;
  final bool isSpeedMap;
  final List<List<double>> smoothedGrid;
  final double maxValue;

  static const int gridX = 20;
  static const int gridY = 13;

  _HeatmapCache._({
    required this.points,
    required this.isSpeedMap,
    required this.smoothedGrid,
    required this.maxValue,
  });

  /// points와 isSpeedMap으로부터 캐시를 생성
  factory _HeatmapCache.compute(List<LocationPoint> points, bool isSpeedMap) {
    if (points.isEmpty) {
      return _HeatmapCache._(
        points: points,
        isSpeedMap: isSpeedMap,
        smoothedGrid: [],
        maxValue: 0,
      );
    }

    // Calculate density grid
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

    if (maxVal == 0) {
      return _HeatmapCache._(
        points: points,
        isSpeedMap: isSpeedMap,
        smoothedGrid: [],
        maxValue: 0,
      );
    }

    // Apply gaussian-like smoothing
    final smoothed = _smoothGrid(grid);
    double smoothMax = 0;
    for (final row in smoothed) {
      for (final val in row) {
        if (val > smoothMax) smoothMax = val;
      }
    }

    return _HeatmapCache._(
      points: points,
      isSpeedMap: isSpeedMap,
      smoothedGrid: smoothed,
      maxValue: smoothMax,
    );
  }

  static List<List<double>> _smoothGrid(List<List<double>> grid) {
    final result = List.generate(gridY, (_) => List.filled(gridX, 0.0));
    const kernel = [
      [0.05, 0.1, 0.05],
      [0.1, 0.4, 0.1],
      [0.05, 0.1, 0.05],
    ];

    for (int y = 0; y < gridY; y++) {
      for (int x = 0; x < gridX; x++) {
        double sum = 0;
        for (int ky = -1; ky <= 1; ky++) {
          for (int kx = -1; kx <= 1; kx++) {
            final ny = (y + ky).clamp(0, gridY - 1);
            final nx = (x + kx).clamp(0, gridX - 1);
            sum += grid[ny][nx] * kernel[ky + 1][kx + 1];
          }
        }
        result[y][x] = sum;
      }
    }
    return result;
  }
}

class HeatmapPainter extends CustomPainter {
  final List<LocationPoint> points;
  final bool isSpeedMap;

  // 캐싱된 계산 결과
  _HeatmapCache? _cache;

  // 필드 라인용 재사용 Paint 객체
  static final Paint _fieldPaint = Paint()
    ..color = AppColors.fieldLine.withValues(alpha: 0.4)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;

  HeatmapPainter({
    required this.points,
    this.isSpeedMap = false,
  });

  _HeatmapCache _getCache() {
    // 캐시가 없거나 데이터가 변경되었으면 재계산
    if (_cache == null ||
        !identical(_cache!.points, points) ||
        _cache!.isSpeedMap != isSpeedMap ||
        _cache!.points.length != points.length) {
      _cache = _HeatmapCache.compute(points, isSpeedMap);
    }
    return _cache!;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Draw field background
    _drawField(canvas, size);

    final cache = _getCache();
    if (cache.smoothedGrid.isEmpty || cache.maxValue == 0) return;

    // Render heatmap using cached data
    final cellW = size.width / _HeatmapCache.gridX;
    final cellH = size.height / _HeatmapCache.gridY;

    for (int y = 0; y < _HeatmapCache.gridY; y++) {
      for (int x = 0; x < _HeatmapCache.gridX; x++) {
        final intensity = cache.smoothedGrid[y][x] / cache.maxValue;
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
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Outline
    canvas.drawRect(rect, _fieldPaint);

    // Center line
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      _fieldPaint,
    );

    // Center circle
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.height * 0.18,
      _fieldPaint,
    );

    // Penalty areas
    final penW = size.width * 0.15;
    final penH = size.height * 0.44;
    final penY = (size.height - penH) / 2;

    canvas.drawRect(Rect.fromLTWH(0, penY, penW, penH), _fieldPaint);
    canvas.drawRect(Rect.fromLTWH(size.width - penW, penY, penW, penH), _fieldPaint);
  }

  @override
  bool shouldRepaint(covariant HeatmapPainter oldDelegate) {
    // Compare length first for quick check, then compare references
    // This handles in-place list modifications better
    if (oldDelegate.isSpeedMap != isSpeedMap) return true;
    if (oldDelegate.points.length != points.length) return true;
    if (!identical(oldDelegate.points, points)) return true;
    return false;
  }
}

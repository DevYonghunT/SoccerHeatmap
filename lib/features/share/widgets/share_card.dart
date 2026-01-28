import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/typography.dart';
import '../../../data/models/match_data.dart';
import '../../../features/heatmap/widgets/heatmap_painter.dart';

class ShareCard extends StatelessWidget {
  final MatchData match;
  final bool isCompact;

  const ShareCard({
    super.key,
    required this.match,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isCompact ? 360 : 360,
      height: isCompact ? 360 : 640,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A1A1A),
            Color(0xFF0C0C0C),
            Color(0xFF0A0A0A),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Brand
            Text('KICKOFF', style: AppTypography.brandSmall),
            const SizedBox(height: 16),
            // Date
            Text(
              'January 25, 2026',
              style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
            ),
            Text(
              '${match.durationMinutes} minutes',
              style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            // Score
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: AppColors.cardInner,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    match.scoreText,
                    style: GoogleFonts.sora(
                      fontSize: isCompact ? 36 : 48,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: _resultGlowColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      match.resultText,
                      style: AppTypography.captionBold.copyWith(color: _resultGlowColor),
                    ),
                  ),
                ],
              ),
            ),
            if (!isCompact) ...[
              const SizedBox(height: 20),
              // Mini heatmap
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.cardInner,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(LucideIcons.mapPin, size: 12, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          'MY HEATMAP',
                          style: AppTypography.label.copyWith(fontSize: 9),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 100,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CustomPaint(
                          painter: HeatmapPainter(points: match.locationHistory),
                          size: Size.infinite,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            // Stats row
            Row(
              children: [
                _buildMiniStat(LucideIcons.footprints, '${match.stats.totalDistanceKm}', 'km'),
                const SizedBox(width: 8),
                _buildMiniStat(LucideIcons.heartPulse, '${match.stats.averageHeartRate}', 'bpm'),
                const SizedBox(width: 8),
                _buildMiniStat(LucideIcons.zap, '${match.stats.maxSpeedKmh}', 'km/h'),
              ],
            ),
            const Spacer(),
            // CTA
            Center(
              child: Text(
                '나의 축구를 기록하세요',
                style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                '📱 Download KICKOFF',
                style: AppTypography.captionBold.copyWith(color: AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(IconData icon, String value, String unit) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.cardInner,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 14, color: AppColors.primary),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.sora(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              unit,
              style: AppTypography.caption.copyWith(fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Color get _resultGlowColor {
    switch (match.result) {
      case MatchResult.win:
        return AppColors.success;
      case MatchResult.lose:
        return AppColors.primary;
      case MatchResult.draw:
        return AppColors.warning;
    }
  }
}

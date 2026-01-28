import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/typography.dart';
import '../../../data/models/match_data.dart';
import 'package:intl/intl.dart';

class LastMatchCard extends StatelessWidget {
  final MatchData match;

  const LastMatchCard({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildBody(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 24,
              height: 2,
              color: AppColors.primary,
            ),
            const SizedBox(width: 12),
            Text('LAST MATCH', style: AppTypography.label),
          ],
        ),
        Text(
          DateFormat('MMM dd, yyyy').format(match.date),
          style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Score section
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardInner,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  match.scoreText,
                  style: AppTypography.statNumberLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  match.resultText,
                  style: AppTypography.captionBold.copyWith(
                    color: _resultColor,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Mini stats
        Expanded(
          child: Column(
            children: [
              _buildMiniStat(
                LucideIcons.footprints,
                '이동거리',
                '${match.stats.totalDistanceKm}km',
              ),
              const SizedBox(height: 8),
              _buildMiniStat(
                LucideIcons.heartPulse,
                '평균 심박수',
                '${match.stats.averageHeartRate}bpm',
              ),
              const SizedBox(height: 8),
              _buildMiniStat(
                LucideIcons.zap,
                '최고속도',
                '${match.stats.maxSpeedKmh}km/h',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMiniStat(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardInner,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(label, style: AppTypography.caption, overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: AppTypography.captionBold.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Color get _resultColor {
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

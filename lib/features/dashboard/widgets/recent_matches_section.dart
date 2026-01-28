import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/typography.dart';
import '../../../data/models/match_data.dart';
import '../../../shared/widgets/accent_label.dart';

class RecentMatchesSection extends StatelessWidget {
  final List<MatchData> matches;

  const RecentMatchesSection({super.key, required this.matches});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const AccentLabel(text: 'RECENT MATCHES'),
            Text(
              'View all',
              style: AppTypography.caption.copyWith(color: AppColors.primary),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: List.generate(matches.length, (index) {
              return _buildMatchRow(matches[index], index < matches.length - 1);
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildMatchRow(MatchData match, bool showDivider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(
                bottom: BorderSide(color: AppColors.divider, width: 1),
              )
            : null,
      ),
      child: Row(
        children: [
          // Date
          SizedBox(
            width: 44,
            child: Column(
              children: [
                Text(
                  DateFormat('dd').format(match.date),
                  style: AppTypography.statNumber.copyWith(fontSize: 20),
                ),
                Text(
                  DateFormat('MMM').format(match.date).toUpperCase(),
                  style: AppTypography.caption.copyWith(fontSize: 10),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Divider line
          Container(
            width: 3,
            height: 36,
            decoration: BoxDecoration(
              color: match.result == MatchResult.win
                  ? AppColors.success
                  : AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  match.matchName ?? '경기',
                  style: AppTypography.bodyBold,
                ),
                const SizedBox(height: 2),
                Text(
                  '${match.durationMinutes}분 · ${match.stats.totalDistanceKm}km · ${match.stats.averageHeartRate}bpm',
                  style: AppTypography.caption.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          // Result badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _badgeColor(match.result),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              _badgeText(match.result),
              style: AppTypography.small.copyWith(
                color: _badgeTextColor(match.result),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _badgeColor(MatchResult result) {
    switch (result) {
      case MatchResult.win:
        return const Color(0x3332D74B);
      case MatchResult.lose:
        return const Color(0x33FF3B30);
      case MatchResult.draw:
        return const Color(0x33FF9500);
    }
  }

  Color _badgeTextColor(MatchResult result) {
    switch (result) {
      case MatchResult.win:
        return AppColors.success;
      case MatchResult.lose:
        return AppColors.primary;
      case MatchResult.draw:
        return AppColors.warning;
    }
  }

  String _badgeText(MatchResult result) {
    switch (result) {
      case MatchResult.win:
        return 'W';
      case MatchResult.lose:
        return 'L';
      case MatchResult.draw:
        return 'D';
    }
  }
}

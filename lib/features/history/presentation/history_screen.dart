import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/typography.dart';
import '../../../data/models/match_data.dart';
import '../../../data/providers/match_providers.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _HistoryContent();
  }
}

class _HistoryContent extends ConsumerWidget {
  const _HistoryContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchesAsync = ref.watch(matchListProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('기록', style: AppTypography.heading2),
              Icon(LucideIcons.filter, size: 20, color: AppColors.textSecondary),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Stats summary bar
        _buildStatsSummary(ref),
        const SizedBox(height: 16),
        // Match list
        Expanded(
          child: matchesAsync.when(
            data: (matches) => _buildMatchList(context, matches),
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
            error: (e, _) => Center(
              child: Text('오류가 발생했습니다', style: AppTypography.body),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSummary(WidgetRef ref) {
    final matchesAsync = ref.watch(matchListProvider);
    final matches = matchesAsync.valueOrNull ?? [];

    int wins = matches.where((m) => m.result == MatchResult.win).length;
    int draws = matches.where((m) => m.result == MatchResult.draw).length;
    int losses = matches.where((m) => m.result == MatchResult.lose).length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            _buildSummaryItem('$wins', '승', AppColors.success),
            _buildSummaryDivider(),
            _buildSummaryItem('$draws', '무', AppColors.warning),
            _buildSummaryDivider(),
            _buildSummaryItem('$losses', '패', AppColors.primary),
            _buildSummaryDivider(),
            _buildSummaryItem('${matches.length}', '총', AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String value, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.sora(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: AppTypography.caption),
        ],
      ),
    );
  }

  Widget _buildSummaryDivider() {
    return Container(
      width: 1,
      height: 36,
      color: AppColors.divider,
    );
  }

  Widget _buildMatchList(BuildContext context, List<MatchData> matches) {
    if (matches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.inbox, size: 48, color: AppColors.textTertiary),
            const SizedBox(height: 12),
            Text(
              '아직 기록된 경기가 없습니다',
              style: AppTypography.body.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    // Group matches by month
    final grouped = <String, List<MatchData>>{};
    for (final match in matches) {
      final key = '${match.date.year}년 ${match.date.month}월';
      grouped.putIfAbsent(key, () => []).add(match);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final entry = grouped.entries.elementAt(index);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 12),
              child: Text(
                entry.key,
                style: AppTypography.label,
              ),
            ),
            ...entry.value.map((match) => _buildMatchTile(context, match)),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  Widget _buildMatchTile(BuildContext context, MatchData match) {
    final resultColor = switch (match.result) {
      MatchResult.win => AppColors.success,
      MatchResult.lose => AppColors.primary,
      MatchResult.draw => AppColors.warning,
    };

    return GestureDetector(
      onTap: () => context.push('/match-summary', extra: match),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Result indicator
            Container(
              width: 4,
              height: 48,
              decoration: BoxDecoration(
                color: resultColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 14),
            // Match info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    match.matchName ?? '경기',
                    style: AppTypography.bodyBold,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${match.date.month}/${match.date.day} · ${match.durationMinutes}분 · ${match.stats.totalDistanceKm}km',
                    style: AppTypography.caption,
                  ),
                ],
              ),
            ),
            // Score
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  match.scoreText,
                  style: GoogleFonts.sora(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: resultColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    match.resultText,
                    style: AppTypography.small.copyWith(
                      color: resultColor,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

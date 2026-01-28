import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/typography.dart';
import '../../../data/providers/match_providers.dart';
import '../../../shared/widgets/accent_label.dart';

class WeeklyStatsSection extends ConsumerWidget {
  const WeeklyStatsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(weeklyStatsProvider);
    final stats = statsAsync.valueOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AccentLabel(text: 'THIS WEEK'),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildCard(LucideIcons.flame, '${stats?.totalCalories ?? 0}', '칼로리'),
            const SizedBox(width: 12),
            _buildCard(LucideIcons.mapPin, '${stats?.totalDistanceKm ?? 0}', '총 거리 (km)'),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildCard(LucideIcons.timer, '${stats?.matchCount ?? 0}', '경기 수'),
            const SizedBox(width: 12),
            _buildCard(LucideIcons.gauge, '${stats?.maxSpeedKmh ?? 0}', '최고속도 (km/h)'),
          ],
        ),
      ],
    );
  }

  Widget _buildCard(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(value, style: AppTypography.statNumber),
            const SizedBox(height: 8),
            Text(label, style: AppTypography.caption),
          ],
        ),
      ),
    );
  }
}

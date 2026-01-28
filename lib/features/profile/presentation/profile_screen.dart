import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/typography.dart';
import '../../../data/models/match_data.dart';
import '../../../data/providers/match_providers.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ProfileContent();
  }
}

class _ProfileContent extends ConsumerWidget {
  const _ProfileContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchesAsync = ref.watch(matchListProvider);
    final matches = matchesAsync.valueOrNull ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('프로필', style: AppTypography.heading2),
              Icon(LucideIcons.settings, size: 20, color: AppColors.textSecondary),
            ],
          ),
          const SizedBox(height: 24),
          // Avatar & Name
          Center(
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.cardInner,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                  child: const Icon(
                    LucideIcons.user,
                    size: 36,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Text('Player', style: AppTypography.heading2),
                const SizedBox(height: 4),
                Text(
                  'KICKOFF 사용자',
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          // All-time Stats
          _buildSectionLabel('ALL-TIME STATS'),
          const SizedBox(height: 12),
          _buildAllTimeStats(matches),
          const SizedBox(height: 24),
          // Record
          _buildSectionLabel('RECORD'),
          const SizedBox(height: 12),
          _buildRecordCard(matches),
          const SizedBox(height: 24),
          // Settings
          _buildSectionLabel('SETTINGS'),
          const SizedBox(height: 12),
          _buildSettingsTile(LucideIcons.bell, '알림', '경기 알림 설정'),
          const SizedBox(height: 8),
          _buildSettingsTile(LucideIcons.watch, 'Apple Watch', '연결 상태 확인'),
          const SizedBox(height: 8),
          _buildSettingsTile(LucideIcons.database, '데이터 관리', '데이터 백업 및 초기화'),
          const SizedBox(height: 8),
          _buildSettingsTile(LucideIcons.info, '앱 정보', 'v1.0.0'),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: AppTypography.label,
        ),
      ],
    );
  }

  Widget _buildAllTimeStats(List<MatchData> matches) {
    double totalDistance = 0;
    int totalCalories = 0;
    int totalMinutes = 0;
    double maxSpeed = 0;

    for (final m in matches) {
      totalDistance += m.stats.totalDistanceKm;
      totalCalories += m.stats.caloriesBurned;
      totalMinutes += m.durationMinutes;
      if (m.stats.maxSpeedKmh > maxSpeed) maxSpeed = m.stats.maxSpeedKmh;
    }

    return Row(
      children: [
        _buildStatCard(totalDistance.toStringAsFixed(1), 'km\n총 거리'),
        const SizedBox(width: 8),
        _buildStatCard(totalCalories.toString(), 'kcal\n총 칼로리'),
        const SizedBox(width: 8),
        _buildStatCard((totalMinutes / 60).toStringAsFixed(0), '시간\n총 활동'),
        const SizedBox(width: 8),
        _buildStatCard(maxSpeed.toStringAsFixed(1), 'km/h\n최고 속도'),
      ],
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.sora(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.caption.copyWith(fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordCard(List<MatchData> matches) {
    int wins = matches.where((m) => m.result == MatchResult.win).length;
    int draws = matches.where((m) => m.result == MatchResult.draw).length;
    int losses = matches.where((m) => m.result == MatchResult.lose).length;
    double winRate = matches.isEmpty ? 0 : (wins / matches.length) * 100;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Win rate circle
          SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CircularProgressIndicator(
                    value: winRate / 100,
                    strokeWidth: 8,
                    backgroundColor: AppColors.cardInner,
                    valueColor: const AlwaysStoppedAnimation(AppColors.success),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${winRate.toStringAsFixed(0)}%',
                      style: GoogleFonts.sora(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text('승률', style: AppTypography.caption.copyWith(fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildRecordItem(wins.toString(), '승', AppColors.success),
              _buildRecordItem(draws.toString(), '무', AppColors.warning),
              _buildRecordItem(losses.toString(), '패', AppColors.primary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecordItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.sora(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(label, style: AppTypography.caption),
      ],
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.bodyBold),
                Text(subtitle, style: AppTypography.caption.copyWith(fontSize: 11)),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            size: 20,
            color: AppColors.textTertiary,
          ),
        ],
      ),
    );
  }
}

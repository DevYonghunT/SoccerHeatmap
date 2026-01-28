import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/typography.dart';
import '../../../data/models/dummy_data.dart';
import '../../../shared/widgets/accent_label.dart';

class MatchSummaryScreen extends StatelessWidget {
  const MatchSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final match = DummyData.lastMatch;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => context.go('/dashboard'),
                    child: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary, size: 20),
                  ),
                  Text('경기 요약', style: AppTypography.bodyBold),
                  GestureDetector(
                    onTap: () => context.push('/share'),
                    child: const Icon(LucideIcons.share2, color: AppColors.textPrimary, size: 20),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    // Match overview card
                    _buildOverviewCard(match),
                    const SizedBox(height: 24),
                    // Heart Rate Zones
                    _buildHeartRateZones(),
                    const SizedBox(height: 24),
                    // Performance
                    _buildPerformanceSection(match),
                    const SizedBox(height: 24),
                    // Half Comparison
                    const AccentLabel(text: 'HALF COMPARISON'),
                    const SizedBox(height: 16),
                    _buildHalfComparison(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard(match) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(match.matchName ?? '경기', style: AppTypography.bodyBold),
              Text(
                '2026.01.25',
                style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildOverviewStat('90', '시간 (분)'),
              _buildOverviewStat('8.7', '거리 (km)'),
              _buildOverviewStat('623', '칼로리'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewStat(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.sora(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: AppTypography.caption),
        ],
      ),
    );
  }

  Widget _buildHeartRateZones() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const AccentLabel(text: 'HEART RATE ZONES'),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.favorite, size: 14, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text('평균 심박수', style: AppTypography.caption),
                    ],
                  ),
                  Text(
                    '156 bpm',
                    style: AppTypography.bodyBold,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildZoneBar('Zone 5', 0.08, AppColors.primary),
              const SizedBox(height: 8),
              _buildZoneBar('Zone 4', 0.34, const Color(0xFFFF5C33)),
              const SizedBox(height: 8),
              _buildZoneBar('Zone 3', 0.28, AppColors.warning),
              const SizedBox(height: 8),
              _buildZoneBar('Zone 2', 0.20, const Color(0xFFFFCC00)),
              const SizedBox(height: 8),
              _buildZoneBar('Zone 1', 0.10, AppColors.success),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildZoneBar(String label, double percentage, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 50,
          child: Text(label, style: AppTypography.caption.copyWith(fontSize: 11)),
        ),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.cardInner,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: percentage,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 36,
          child: Text(
            '${(percentage * 100).toInt()}%',
            style: AppTypography.caption.copyWith(fontSize: 11),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceSection(match) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AccentLabel(text: 'PERFORMANCE'),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildPerfCard(LucideIcons.gauge, '${match.stats.maxSpeedKmh}', '최고속도 (km/h)'),
            const SizedBox(width: 12),
            _buildPerfCard(LucideIcons.activity, '${match.stats.averageSpeedKmh}', '평균속도 (km/h)'),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildPerfCard(LucideIcons.zap, '${match.stats.sprintCount}', '스프린트 횟수'),
            const SizedBox(width: 12),
            _buildPerfCard(LucideIcons.mapPin, '1,247', '스프린트 거리 (m)'),
          ],
        ),
      ],
    );
  }

  Widget _buildPerfCard(IconData icon, String value, String label) {
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
            Text(
              value,
              style: GoogleFonts.sora(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(label, style: AppTypography.caption),
          ],
        ),
      ),
    );
  }

  Widget _buildHalfComparison() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildComparisonRow('이동거리', '4.5 km', '4.2 km'),
          const SizedBox(height: 12),
          _buildComparisonRow('평균 심박수', '152 bpm', '160 bpm'),
          const SizedBox(height: 12),
          _buildComparisonRow('스프린트', '22', '25'),
          const SizedBox(height: 12),
          _buildComparisonRow('최고속도', '26.1 km/h', '28.3 km/h'),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(String label, String first, String second) {
    return Row(
      children: [
        Expanded(
          child: Text(first, style: AppTypography.body, textAlign: TextAlign.center),
        ),
        Expanded(
          child: Text(
            label,
            style: AppTypography.caption,
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: Text(second, style: AppTypography.body, textAlign: TextAlign.center),
        ),
      ],
    );
  }
}

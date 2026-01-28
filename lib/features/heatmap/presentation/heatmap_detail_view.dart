import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/typography.dart';
import '../../../data/models/dummy_data.dart';
import '../../../shared/widgets/accent_label.dart';
import '../widgets/heatmap_painter.dart';

class HeatmapDetailView extends StatelessWidget {
  const HeatmapDetailView({super.key});

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
                    onTap: () => context.pop(),
                    child: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary, size: 20),
                  ),
                  Text('상세 분석', style: AppTypography.bodyBold),
                  const SizedBox(width: 20),
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
                    // Speed Heatmap
                    const AccentLabel(text: 'SPEED HEATMAP'),
                    const SizedBox(height: 16),
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A0A1A),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.divider),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: CustomPaint(
                        painter: HeatmapPainter(
                          points: match.locationHistory,
                          isSpeedMap: true,
                        ),
                        size: Size.infinite,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Speed legend
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('속도 빈도', style: AppTypography.caption.copyWith(fontSize: 11)),
                        Row(
                          children: [
                            Text('걷기', style: AppTypography.caption.copyWith(fontSize: 11)),
                            const SizedBox(width: 4),
                            _buildSpeedGradient(),
                            const SizedBox(width: 4),
                            Text('스프린트', style: AppTypography.caption.copyWith(fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Sprint Analysis
                    const AccentLabel(text: 'SPRINT ANALYSIS'),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildBigStat('47', '스프린트 횟수'),
                        const SizedBox(width: 12),
                        _buildBigStat('28.3', '최고속도 (km/h)'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Sprint breakdown bars
                    _buildSprintBreakdown(),
                    const SizedBox(height: 24),
                    // Position Coverage
                    const AccentLabel(text: 'POSITION COVERAGE'),
                    const SizedBox(height: 16),
                    _buildPositionCoverage(),
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

  Widget _buildSpeedGradient() {
    return Container(
      width: 60,
      height: 6,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1E3A5F),
            Color(0xFFFF8400),
            AppColors.primary,
          ],
        ),
      ),
    );
  }

  Widget _buildBigStat(String value, String label) {
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
      ),
    );
  }

  Widget _buildSprintBreakdown() {
    final items = [
      {'label': '걷기', 'pct': 0.32, 'color': AppColors.success},
      {'label': '조깅', 'pct': 0.38, 'color': const Color(0xFFFFCC00)},
      {'label': '달리기', 'pct': 0.18, 'color': AppColors.warning},
      {'label': '스프린트', 'pct': 0.12, 'color': AppColors.primary},
    ];

    return Column(
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              SizedBox(
                width: 56,
                child: Text(
                  item['label'] as String,
                  style: AppTypography.caption.copyWith(fontSize: 11),
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppColors.cardInner,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: item['pct'] as double,
                      child: Container(
                        height: 10,
                        decoration: BoxDecoration(
                          color: item['color'] as Color,
                          borderRadius: BorderRadius.circular(5),
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
                  '${((item['pct'] as double) * 100).toInt()}%',
                  style: AppTypography.caption.copyWith(fontSize: 11),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPositionCoverage() {
    final positions = [
      {'label': '공격 진영 (상대 하프)', 'pct': '38%', 'icon': LucideIcons.swords},
      {'label': '미드필드 (중앙)', 'pct': '45%', 'icon': LucideIcons.arrowLeftRight},
      {'label': '수비 진영 (우리 하프)', 'pct': '17%', 'icon': LucideIcons.shield},
    ];

    return Column(
      children: positions.map((pos) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(pos['icon'] as IconData, size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  pos['label'] as String,
                  style: AppTypography.body,
                ),
              ),
              Text(
                pos['pct'] as String,
                style: AppTypography.bodyBold,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

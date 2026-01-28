import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/typography.dart';
import '../../../data/models/dummy_data.dart';
import '../../../shared/widgets/accent_label.dart';
import '../widgets/heatmap_painter.dart';

class HeatmapMatchView extends StatefulWidget {
  final bool embedded;

  const HeatmapMatchView({super.key, this.embedded = false});

  @override
  State<HeatmapMatchView> createState() => _HeatmapMatchViewState();
}

class _HeatmapMatchViewState extends State<HeatmapMatchView> {
  int _selectedTab = 0; // 0: 전체, 1: 전반, 2: 후반

  @override
  Widget build(BuildContext context) {
    final match = DummyData.lastMatch;
    final content = Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (!widget.embedded)
                GestureDetector(
                  onTap: () => context.go('/dashboard'),
                  child: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary, size: 20),
                )
              else
                const SizedBox(width: 20),
              Text(widget.embedded ? '통계' : '히트맵', style: widget.embedded ? AppTypography.heading2 : AppTypography.bodyBold),
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
                // Match info & tabs
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(match.matchName ?? '경기', style: AppTypography.bodyBold, overflow: TextOverflow.ellipsis),
                          Text(
                            '2026.01.25 · 90분 · 8.7km',
                            style: AppTypography.caption.copyWith(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildTabs(),
                  ],
                ),
                const SizedBox(height: 16),
                // Heatmap
                Container(
                  height: 260,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.fieldGreen,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.divider),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: CustomPaint(
                    painter: HeatmapPainter(
                      points: match.locationHistory,
                    ),
                    size: Size.infinite,
                  ),
                ),
                const SizedBox(height: 12),
                // Legend
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('활동 빈도', style: AppTypography.caption.copyWith(fontSize: 11)),
                    Row(
                      children: [
                        _buildLegendGradient(),
                        const SizedBox(width: 8),
                        Text('높음', style: AppTypography.caption.copyWith(fontSize: 11)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Zone Analysis
                const AccentLabel(text: 'ZONE ANALYSIS'),
                const SizedBox(height: 16),
                _buildZoneCards(),
                const SizedBox(height: 24),
                // Movement Stats
                const AccentLabel(text: 'MOVEMENT STATS'),
                const SizedBox(height: 16),
                _buildMovementStats(match),
                const SizedBox(height: 16),
                // Detail analysis button
                GestureDetector(
                  onTap: () => context.push('/heatmap-detail'),
                  child: Container(
                    width: double.infinity,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Center(
                      child: Text(
                        '상세 분석 보기 →',
                        style: AppTypography.body.copyWith(color: AppColors.primary),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );

    if (widget.embedded) return content;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: content),
    );
  }

  Widget _buildTabs() {
    final labels = ['전체', '전반', '후반'];
    return Row(
      children: List.generate(3, (i) {
        final isSelected = _selectedTab == i;
        return GestureDetector(
          onTap: () => setState(() => _selectedTab = i),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              labels[i],
              style: AppTypography.small.copyWith(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildLegendGradient() {
    return Container(
      width: 80,
      height: 6,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1E3A5F),
            AppColors.warning,
            AppColors.primary,
          ],
        ),
      ),
    );
  }

  Widget _buildZoneCards() {
    final zones = [
      {'label': '좌측 에어', 'value': '42%', 'color': AppColors.primary},
      {'label': '중심', 'value': '31%', 'color': AppColors.warning},
      {'label': '우측', 'value': '18%', 'color': const Color(0xFFFF8400)},
      {'label': '수비', 'value': '9%', 'color': AppColors.success},
    ];

    return Row(
      children: zones.map((zone) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: zone != zones.last ? 8 : 0),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  zone['value'] as String,
                  style: GoogleFonts.sora(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: zone['color'] as Color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  zone['label'] as String,
                  style: AppTypography.caption.copyWith(fontSize: 10),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMovementStats(match) {
    return Column(
      children: [
        _buildMovRow(LucideIcons.footprints, '총 이동거리', '${match.stats.totalDistanceKm} km'),
        const SizedBox(height: 12),
        _buildMovRow(LucideIcons.zap, '스프린트 거리', '${match.stats.sprintDistanceKm} km'),
        const SizedBox(height: 12),
        _buildMovRow(LucideIcons.gauge, '최고 속도', '${match.stats.maxSpeedKmh} km/h'),
      ],
    );
  }

  Widget _buildMovRow(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 12),
          Text(label, style: AppTypography.body),
          const Spacer(),
          Text(value, style: AppTypography.bodyBold),
        ],
      ),
    );
  }
}

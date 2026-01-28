import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/typography.dart';

class LiveStatsGrid extends StatelessWidget {
  const LiveStatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _buildMetricCard(LucideIcons.footprints, '4.2', '이동거리 (km)'),
            const SizedBox(width: 12),
            _buildMetricCard(LucideIcons.zap, '24.6', '최고속도 (km/h)'),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildMetricCard(LucideIcons.flame, '386', '칼로리 (kcal)'),
            const SizedBox(width: 12),
            _buildMetricCard(LucideIcons.activity, '847', '스프린트 (m)'),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(IconData icon, String value, String label) {
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
            const SizedBox(height: 12),
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
}

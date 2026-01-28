import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/typography.dart';

class HeartRateCard extends StatelessWidget {
  final int currentBpm;
  final int zone;

  const HeartRateCard({
    super.key,
    required this.currentBpm,
    required this.zone,
  });

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
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.favorite, size: 16, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    '심박수',
                    style: AppTypography.bodyBold.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'ZONE $zone',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // BPM value
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$currentBpm',
                style: GoogleFonts.sora(
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'bpm',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Heart rate chart bars
          _buildChartBars(),
        ],
      ),
    );
  }

  Widget _buildChartBars() {
    final barHeights = <double>[8, 14, 18, 28, 36, 34, 30, 32, 28, 26, 22, 16];
    final barColors = <Color>[
      AppColors.watchBarGrey,
      AppColors.watchBarGrey,
      AppColors.warning,
      const Color(0xFFFF5C33),
      AppColors.primary,
      AppColors.primary,
      const Color(0xFFFF5C33),
      AppColors.primary,
      AppColors.primary,
      const Color(0xFFFF5C33),
      AppColors.warning,
      AppColors.warning,
    ];

    return SizedBox(
      height: 40,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(barHeights.length, (i) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1.5),
              child: Container(
                height: barHeights[i],
                decoration: BoxDecoration(
                  color: barColors[i],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

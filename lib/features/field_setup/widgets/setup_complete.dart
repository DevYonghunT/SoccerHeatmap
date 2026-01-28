import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/typography.dart';
import '../../../shared/widgets/primary_button.dart';
import 'soccer_field_diagram.dart';

class SetupComplete extends StatelessWidget {
  final VoidCallback onSaveAndStart;
  final VoidCallback onRetry;

  const SetupComplete({
    super.key,
    required this.onSaveAndStart,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const Spacer(),
          // Success icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, size: 32, color: AppColors.success),
          ),
          const SizedBox(height: 20),
          Text('운동장 측정 완료!', style: AppTypography.heading2),
          const SizedBox(height: 8),
          Text(
            'GPS 기반으로 운동장 크기가\n정확하게 측정되었습니다.',
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          // Field diagram with dimensions
          const SoccerFieldDiagram(
            showDimensions: true,
            lengthMeters: 105,
            widthMeters: 68,
          ),
          const SizedBox(height: 28),
          // Dimension stats
          Row(
            children: [
              _buildDimStat('105m', '가로 길이'),
              const SizedBox(width: 12),
              _buildDimStat('68m', '세로 길이'),
              const SizedBox(width: 12),
              _buildDimStat('7,140', '면적 (m²)'),
            ],
          ),
          const Spacer(),
          PrimaryButton(
            text: '저장하고 시작하기',
            icon: Icons.check,
            color: AppColors.success,
            onPressed: onSaveAndStart,
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.refreshCw, size: 18, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    '다시 측정하기',
                    style: AppTypography.body.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildDimStat(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.sora(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(label, style: AppTypography.caption.copyWith(fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

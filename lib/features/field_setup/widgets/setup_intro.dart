import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/typography.dart';
import '../../../shared/widgets/primary_button.dart';
import 'soccer_field_diagram.dart';

class SetupIntro extends StatelessWidget {
  final VoidCallback onStart;

  const SetupIntro({super.key, required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const Spacer(),
          // Field diagram
          const SoccerFieldDiagram(showCorners: true),
          const SizedBox(height: 32),
          // Title
          Text(
            '운동장 크기 측정',
            style: AppTypography.heading2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Apple Watch GPS를 이용해 운동장이\n나 모서리를 걸어서 크기를 측정합니다.',
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          // Steps
          _buildStep(1, '첫 번째 코너에서 시작', '운동장 모퉁이에 서서 시작 버튼을 누르세요', true),
          const SizedBox(height: 16),
          _buildStep(2, '경계선을 따라 걷기', '운동장 라인을 따라 한 바퀴 걸으세요', false),
          const SizedBox(height: 16),
          _buildStep(3, '자동으로 크기 계산', 'GPS 데이터로 운동장 크기를 자동 산출합니다', false),
          const SizedBox(height: 24),
          // Watch connection badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.watch, size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  'Apple Watch 연결됨',
                  style: AppTypography.caption.copyWith(color: AppColors.primary),
                ),
              ],
            ),
          ),
          const Spacer(),
          PrimaryButton(
            text: '측정 시작',
            icon: LucideIcons.locate,
            onPressed: onStart,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStep(int number, String title, String subtitle, bool isActive) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.cardInner,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              '$number',
              style: AppTypography.small.copyWith(
                color: isActive ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.bodyBold),
              Text(
                subtitle,
                style: AppTypography.caption.copyWith(fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

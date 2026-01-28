import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/typography.dart';
import '../../../shared/widgets/primary_button.dart';

class ScoreInputScreen extends StatefulWidget {
  const ScoreInputScreen({super.key});

  @override
  State<ScoreInputScreen> createState() => _ScoreInputScreenState();
}

class _ScoreInputScreenState extends State<ScoreInputScreen> {
  int _myScore = 0;
  int _opponentScore = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary, size: 20),
                    ),
                    Text('스코어 입력', style: AppTypography.bodyBold),
                    const SizedBox(width: 20),
                  ],
                ),
              ),
              const Spacer(),
              // Score display
              Text(
                '경기 결과를 입력하세요',
                style: AppTypography.caption,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildScoreColumn('우리팀', _myScore, (v) => setState(() => _myScore = v)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      ':',
                      style: GoogleFonts.sora(
                        fontSize: 48,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ),
                  _buildScoreColumn('상대팀', _opponentScore, (v) => setState(() => _opponentScore = v)),
                ],
              ),
              const Spacer(),
              // Confirm button
              PrimaryButton(
                text: '확인',
                onPressed: () {
                  context.go('/match-summary');
                },
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => context.go('/match-summary'),
                child: Text(
                  '건너뛰기',
                  style: AppTypography.body.copyWith(color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreColumn(String label, int score, ValueChanged<int> onChanged) {
    return Column(
      children: [
        Text(label, style: AppTypography.caption),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () {
            if (score < 99) onChanged(score + 1);
          },
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.add, color: AppColors.textPrimary, size: 24),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          score.toString(),
          style: GoogleFonts.sora(
            fontSize: 64,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () {
            if (score > 0) onChanged(score - 1);
          },
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.remove, color: AppColors.textPrimary, size: 24),
          ),
        ),
      ],
    );
  }
}

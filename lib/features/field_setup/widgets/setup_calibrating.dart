import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/typography.dart';
import 'soccer_field_diagram.dart';

class SetupCalibrating extends StatefulWidget {
  final VoidCallback onComplete;

  const SetupCalibrating({super.key, required this.onComplete});

  @override
  State<SetupCalibrating> createState() => _SetupCalibratingState();
}

class _SetupCalibratingState extends State<SetupCalibrating> {
  final int _currentCorner = 2; // C corner (0-indexed: A=0, B=1, C=2, D=3)
  final int _totalCorners = 4;

  @override
  void initState() {
    super.initState();
    // Simulate calibration after delay
    Timer(const Duration(seconds: 5), () {
      if (mounted) widget.onComplete();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // GPS tracking badge
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'GPS 추적 중',
                style: AppTypography.caption.copyWith(color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Live field map
          Container(
            height: 240,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider),
            ),
            child: const SoccerFieldDiagram(showCorners: true, showTracking: true),
          ),
          const SizedBox(height: 20),
          // Progress section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('코너 진행률', style: AppTypography.caption),
              Text(
                '${_currentCorner + 1} / $_totalCorners',
                style: AppTypography.bodyBold,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Corner indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) {
              final labels = ['A', 'B', 'C', 'D'];
              final isCompleted = index < _currentCorner;
              final isCurrent = index == _currentCorner;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? Colors.transparent
                        : isCompleted
                            ? AppColors.success.withValues(alpha: 0.15)
                            : AppColors.cardInner,
                    borderRadius: BorderRadius.circular(8),
                    border: isCurrent
                        ? Border.all(color: AppColors.primary, width: 2)
                        : null,
                  ),
                  child: Center(
                    child: isCompleted
                        ? Icon(Icons.check, size: 18, color: AppColors.success)
                        : Text(
                            labels[index],
                            style: AppTypography.bodyBold.copyWith(
                              color: isCurrent
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            ),
                          ),
                  ),
                ),
              );
            }),
          ),
          const Spacer(),
          // Instruction
          Icon(Icons.directions_walk_rounded, size: 32, color: AppColors.textSecondary),
          const SizedBox(height: 12),
          Text(
            '다음 코너(C)를 향해 걸어가세요',
            style: AppTypography.body,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            '도착하면 자동으로 인식합니다',
            style: AppTypography.caption,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

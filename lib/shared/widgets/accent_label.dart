import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../core/constants/dimensions.dart';

class AccentLabel extends StatelessWidget {
  final String text;
  final Color accentColor;

  const AccentLabel({
    super.key,
    required this.text,
    this.accentColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: AppDimensions.accentLineWidth,
          height: AppDimensions.accentLineHeight,
          color: accentColor,
        ),
        const SizedBox(width: 12),
        Text(text, style: AppTypography.label),
      ],
    );
  }
}

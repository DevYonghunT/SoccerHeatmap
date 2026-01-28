import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/colors.dart';

class LiveTimer extends StatelessWidget {
  final String formattedTime;
  final String halfLabel;

  const LiveTimer({
    super.key,
    required this.formattedTime,
    required this.halfLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          formattedTime,
          style: GoogleFonts.sora(
            fontSize: 56,
            fontWeight: FontWeight.w700,
            letterSpacing: -2,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          halfLabel,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }
}

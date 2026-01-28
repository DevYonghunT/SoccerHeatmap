import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../../core/constants/colors.dart';
import '../../../core/constants/typography.dart';
import '../../../data/models/dummy_data.dart';
import '../../../shared/widgets/primary_button.dart';
import '../widgets/share_card.dart';

class ShareScreen extends StatefulWidget {
  const ShareScreen({super.key});

  @override
  State<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();
  int _selectedCard = 0; // 0: full, 1: compact

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
                    child: const Icon(Icons.close, color: AppColors.textPrimary, size: 24),
                  ),
                  Text('공유 카드', style: AppTypography.bodyBold),
                  const SizedBox(width: 24),
                ],
              ),
            ),
            // Card type selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                children: [
                  _buildCardTypeTab('전체', 0),
                  const SizedBox(width: 8),
                  _buildCardTypeTab('미니', 1),
                ],
              ),
            ),
            // Card preview
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Screenshot(
                    controller: _screenshotController,
                    child: ShareCard(
                      match: match,
                      isCompact: _selectedCard == 1,
                    ),
                  ),
                ),
              ),
            ),
            // Action buttons
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  PrimaryButton(
                    text: '공유하기',
                    icon: Icons.share,
                    onPressed: _shareCard,
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _saveToGallery,
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          '갤러리에 저장',
                          style: AppTypography.body.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardTypeTab(String label, int index) {
    final isSelected = _selectedCard == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedCard = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: AppTypography.small.copyWith(
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Future<void> _shareCard() async {
    try {
      final image = await _screenshotController.capture();
      if (image == null) return;

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/kickoff_share.png');
      await file.writeAsBytes(image);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'KICKOFF로 나의 축구를 기록하세요!',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('공유에 실패했습니다')),
        );
      }
    }
  }

  Future<void> _saveToGallery() async {
    try {
      final image = await _screenshotController.capture();
      if (image == null) return;

      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/kickoff_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(image);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이미지가 저장되었습니다')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('저장에 실패했습니다')),
        );
      }
    }
  }
}

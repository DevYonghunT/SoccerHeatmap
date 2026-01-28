import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/typography.dart';
import '../widgets/setup_intro.dart';
import '../widgets/setup_calibrating.dart';
import '../widgets/setup_complete.dart';

class FieldSetupScreen extends StatefulWidget {
  const FieldSetupScreen({super.key});

  @override
  State<FieldSetupScreen> createState() => _FieldSetupScreenState();
}

class _FieldSetupScreenState extends State<FieldSetupScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    onTap: () {
                      if (_currentPage > 0) {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        context.pop();
                      }
                    },
                    child: _currentPage == 0
                        ? const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary, size: 20)
                        : Text('취소', style: AppTypography.body.copyWith(color: AppColors.primary)),
                  ),
                  Text(
                    _getTitle(),
                    style: AppTypography.bodyBold,
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) => setState(() => _currentPage = index),
                children: [
                  SetupIntro(onStart: _nextPage),
                  SetupCalibrating(onComplete: _nextPage),
                  SetupComplete(
                    onSaveAndStart: () => context.go('/live-match'),
                    onRetry: () {
                      _pageController.jumpToPage(1);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTitle() {
    switch (_currentPage) {
      case 0:
        return '운동장 설정';
      case 1:
        return '측정 중';
      case 2:
        return '측정 완료';
      default:
        return '';
    }
  }
}

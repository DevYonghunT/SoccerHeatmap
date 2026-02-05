import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/typography.dart';
import '../widgets/live_timer.dart';
import '../widgets/live_stats_grid.dart';
import '../widgets/heart_rate_card.dart';
import '../../../shared/widgets/fade_slide_in.dart';

class LiveMatchScreen extends StatefulWidget {
  const LiveMatchScreen({super.key});

  @override
  State<LiveMatchScreen> createState() => _LiveMatchScreenState();
}

class _LiveMatchScreenState extends State<LiveMatchScreen> {
  bool _isRunning = true;
  Timer? _timer;

  // ValueNotifier로 타이머 영역만 리빌드
  final ValueNotifier<int> _elapsedSeconds = ValueNotifier<int>(1938); // 32:18

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isRunning) {
        _elapsedSeconds.value++;
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _elapsedSeconds.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

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
                    Semantics(
                      button: true,
                      label: '뒤로 가기',
                      child: IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: AppColors.textPrimary,
                          size: 20,
                        ),
                        tooltip: '뒤로 가기',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                    _buildLiveBadge(),
                    const SizedBox(width: 20),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      // Timer - ValueListenableBuilder로 타이머 영역만 리빌드
                      ValueListenableBuilder<int>(
                        valueListenable: _elapsedSeconds,
                        builder: (context, seconds, _) => LiveTimer(
                          formattedTime: _formatTime(seconds),
                          halfLabel: '전반전',
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Heart Rate Card
                      const HeartRateCard(
                        currentBpm: 162,
                        zone: 4,
                      ),
                      const SizedBox(height: 24),
                      // Live Metrics
                      const LiveStatsGrid(),
                    ],
                  ),
                ),
              ),

              // Controls
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Pause/Play button - 접근성 개선
                    Semantics(
                      button: true,
                      label: _isRunning ? '일시정지' : '재생',
                      child: Tooltip(
                        message: _isRunning ? '일시정지' : '재생',
                        child: Material(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(32),
                          child: InkWell(
                            onTap: () {
                              setState(() => _isRunning = !_isRunning);
                            },
                            borderRadius: BorderRadius.circular(32),
                            child: SizedBox(
                              width: 64,
                              height: 64,
                              child: Icon(
                                _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                color: AppColors.textPrimary,
                                size: 32,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Stop button - 접근성 개선
                    Semantics(
                      button: true,
                      label: '경기 종료',
                      child: Tooltip(
                        message: '경기 종료',
                        child: Material(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(32),
                          child: InkWell(
                            onTap: () => _showEndDialog(),
                            borderRadius: BorderRadius.circular(32),
                            child: const SizedBox(
                              width: 64,
                              height: 64,
                              child: Icon(
                                Icons.stop_rounded,
                                color: AppColors.textPrimary,
                                size: 32,
                              ),
                            ),
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
      ),
    );
  }

  Widget _buildLiveBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const PulsingDot(size: 6, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            'LIVE',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  void _showEndDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text('경기 종료', style: AppTypography.bodyBold),
        content: Text('경기를 종료하시겠습니까?', style: AppTypography.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('취소', style: AppTypography.body),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.go('/score-input');
            },
            child: Text(
              '종료',
              style: AppTypography.body.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

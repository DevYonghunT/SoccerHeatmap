import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/typography.dart';
import '../../../data/providers/match_providers.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/last_match_card.dart';
import '../widgets/weekly_stats_section.dart';
import '../widgets/recent_matches_section.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../history/presentation/history_screen.dart';
import '../../heatmap/presentation/heatmap_match_view.dart';
import '../../profile/presentation/profile_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(child: _buildTabContent()),
            _buildTabBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_currentTab) {
      case 1:
        return const HistoryScreen();
      case 2:
        return const HeatmapMatchView(embedded: true);
      case 3:
        return const ProfileScreen();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    final matchesAsync = ref.watch(matchListProvider);
    final matches = matchesAsync.valueOrNull ?? [];
    final lastMatch = matches.isNotEmpty ? matches.first : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const DashboardHeader(),
          const SizedBox(height: 28),
          if (lastMatch != null) LastMatchCard(match: lastMatch),
          const SizedBox(height: 28),
          const WeeklyStatsSection(),
          const SizedBox(height: 28),
          RecentMatchesSection(matches: matches),
          const SizedBox(height: 28),
          PrimaryButton(
            text: '경기 시작',
            icon: LucideIcons.play,
            onPressed: () => context.push('/field-setup'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.only(top: 10, bottom: 28),
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        border: Border(
          top: BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildTab(Icons.home_rounded, '홈', 0),
          _buildTab(LucideIcons.activity, '기록', 1),
          _buildTab(Icons.bar_chart_rounded, '통계', 2),
          _buildTab(LucideIcons.user, '프로필', 3),
        ],
      ),
    );
  }

  Widget _buildTab(IconData icon, String label, int index) {
    final isActive = _currentTab == index;
    final color = isActive ? AppColors.primary : AppColors.textTertiary;
    return GestureDetector(
      onTap: () => setState(() => _currentTab = index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: isActive
                  ? AppTypography.tabLabelActive
                  : AppTypography.tabLabel,
            ),
          ],
        ),
      ),
    );
  }
}

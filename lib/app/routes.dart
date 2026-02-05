import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/models/match_data.dart';
import '../features/splash/presentation/splash_screen.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/live_match/presentation/live_match_screen.dart';
import '../features/match_summary/presentation/match_summary_screen.dart';
import '../features/field_setup/presentation/field_setup_screen.dart';
import '../features/heatmap/presentation/heatmap_match_view.dart';
import '../features/heatmap/presentation/heatmap_detail_view.dart';
import '../features/share/presentation/share_screen.dart';
import '../features/score_input/presentation/score_input_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

CustomTransitionPage<void> _fadeTransitionPage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

CustomTransitionPage<void> _slideUpPage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final tween = Tween(begin: const Offset(0, 0.15), end: Offset.zero)
          .chain(CurveTween(curve: Curves.easeOutCubic));
      return SlideTransition(
        position: animation.drive(tween),
        child: FadeTransition(opacity: animation, child: child),
      );
    },
  );
}

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      pageBuilder: (context, state) =>
          _fadeTransitionPage(state: state, child: const DashboardScreen()),
    ),
    GoRoute(
      path: '/field-setup',
      pageBuilder: (context, state) =>
          _slideUpPage(state: state, child: const FieldSetupScreen()),
    ),
    GoRoute(
      path: '/live-match',
      pageBuilder: (context, state) =>
          _fadeTransitionPage(state: state, child: const LiveMatchScreen()),
    ),
    GoRoute(
      path: '/score-input',
      pageBuilder: (context, state) =>
          _slideUpPage(state: state, child: const ScoreInputScreen()),
    ),
    GoRoute(
      path: '/match-summary',
      pageBuilder: (context, state) {
        final match = state.extra as MatchData?;
        return _fadeTransitionPage(
          state: state,
          child: MatchSummaryScreen(match: match),
        );
      },
    ),
    GoRoute(
      path: '/heatmap',
      pageBuilder: (context, state) =>
          _fadeTransitionPage(state: state, child: const HeatmapMatchView()),
    ),
    GoRoute(
      path: '/heatmap-detail',
      pageBuilder: (context, state) =>
          _slideUpPage(state: state, child: const HeatmapDetailView()),
    ),
    GoRoute(
      path: '/share',
      pageBuilder: (context, state) =>
          _slideUpPage(state: state, child: const ShareScreen()),
    ),
  ],
);

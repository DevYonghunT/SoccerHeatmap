import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../local/match_repository.dart';
import '../models/match_data.dart';
import '../models/dummy_data.dart';

final matchRepositoryProvider = Provider<MatchRepository>((ref) {
  return MatchRepository();
});

final matchListProvider =
    AsyncNotifierProvider<MatchListNotifier, List<MatchData>>(
  MatchListNotifier.new,
);

class MatchListNotifier extends AsyncNotifier<List<MatchData>> {
  @override
  Future<List<MatchData>> build() async {
    final repo = ref.watch(matchRepositoryProvider);
    final matches = await repo.getAllMatches();
    // Seed with dummy data if empty (first launch)
    if (matches.isEmpty) {
      for (final m in DummyData.recentMatches) {
        await repo.saveMatch(m);
      }
      return DummyData.recentMatches;
    }
    return matches;
  }

  Future<void> addMatch(MatchData match) async {
    final repo = ref.read(matchRepositoryProvider);
    await repo.saveMatch(match);
    ref.invalidateSelf();
  }

  Future<void> deleteMatch(String id) async {
    final repo = ref.read(matchRepositoryProvider);
    await repo.deleteMatch(id);
    ref.invalidateSelf();
  }
}

final weeklyStatsProvider = FutureProvider<WeeklyStats>((ref) async {
  // Depend on match list so it refreshes when matches change
  final matches = ref.watch(matchListProvider);
  return matches.when(
    data: (matchList) {
      if (matchList.isEmpty) return const WeeklyStats();
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weekMatches = matchList
          .where((m) =>
              m.date.isAfter(weekStart.subtract(const Duration(days: 1))))
          .toList();
      if (weekMatches.isEmpty) return const WeeklyStats();

      double totalDistance = 0;
      int totalCalories = 0;
      int totalSprints = 0;
      double maxSpeed = 0;

      for (final m in weekMatches) {
        totalDistance += m.stats.totalDistanceKm;
        totalCalories += m.stats.caloriesBurned;
        totalSprints += m.stats.sprintCount;
        if (m.stats.maxSpeedKmh > maxSpeed) maxSpeed = m.stats.maxSpeedKmh;
      }

      return WeeklyStats(
        totalCalories: totalCalories,
        totalDistanceKm: totalDistance,
        matchCount: weekMatches.length,
        totalSprints: totalSprints,
        maxSpeedKmh: maxSpeed,
      );
    },
    loading: () => const WeeklyStats(),
    error: (_, __) => const WeeklyStats(),
  );
});

final selectedMatchProvider = StateProvider<MatchData?>((ref) => null);

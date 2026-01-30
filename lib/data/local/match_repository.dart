import 'package:hive_flutter/hive_flutter.dart';
import '../models/match_data.dart';

class MatchRepository {
  static const String _boxName = 'matches';

  Future<Box<MatchData>> _getBox() async {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box<MatchData>(_boxName);
    }
    return Hive.openBox<MatchData>(_boxName);
  }

  Future<List<MatchData>> getAllMatches() async {
    final box = await _getBox();
    final matches = box.values.toList();
    matches.sort((a, b) => b.date.compareTo(a.date));
    return matches;
  }

  Future<void> saveMatch(MatchData match) async {
    final box = await _getBox();
    await box.put(match.id, match);
  }

  /// 기존 매치 데이터를 업데이트합니다. (Hive에서는 키가 같으면 덮어쓰므로 saveMatch와 동일)
  Future<void> updateMatch(MatchData match) async {
    await saveMatch(match);
  }

  Future<void> deleteMatch(String id) async {
    final box = await _getBox();
    await box.delete(id);
  }

  Future<MatchData?> getMatch(String id) async {
    final box = await _getBox();
    return box.get(id);
  }

  Future<void> clearAll() async {
    final box = await _getBox();
    await box.clear();
  }

  Future<WeeklyStats> getWeeklyStats() async {
    final matches = await getAllMatches();
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekMatches = matches.where((m) =>
        m.date.isAfter(weekStart.subtract(const Duration(days: 1)))).toList();

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
  }
}

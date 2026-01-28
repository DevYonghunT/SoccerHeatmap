import 'dart:math';
import 'match_data.dart';

class DummyData {
  DummyData._();

  static final MatchData lastMatch = MatchData(
    id: '1',
    date: DateTime(2026, 1, 25),
    durationMinutes: 90,
    myScore: 3,
    opponentScore: 1,
    result: MatchResult.win,
    matchName: '주말 리그전',
    stats: const MatchStats(
      totalDistanceKm: 8.7,
      averageHeartRate: 156,
      maxHeartRate: 178,
      maxSpeedKmh: 28.3,
      averageSpeedKmh: 5.8,
      sprintCount: 47,
      caloriesBurned: 623,
      sprintDistanceKm: 1.2,
    ),
    fieldSize: const FieldSize(lengthMeters: 105, widthMeters: 68),
    locationHistory: _generateLocationHistory(),
  );

  static final List<MatchData> recentMatches = [
    lastMatch,
    MatchData(
      id: '2',
      date: DateTime(2026, 1, 22),
      durationMinutes: 60,
      myScore: 2,
      opponentScore: 2,
      result: MatchResult.draw,
      matchName: '연습 경기',
      stats: const MatchStats(
        totalDistanceKm: 6.2,
        averageHeartRate: 142,
        maxHeartRate: 168,
        maxSpeedKmh: 24.5,
        averageSpeedKmh: 5.2,
        sprintCount: 32,
        caloriesBurned: 480,
        sprintDistanceKm: 0.9,
      ),
      locationHistory: _generateLocationHistory(),
    ),
    MatchData(
      id: '3',
      date: DateTime(2026, 1, 19),
      durationMinutes: 90,
      myScore: 1,
      opponentScore: 3,
      result: MatchResult.lose,
      matchName: '리그전',
      stats: const MatchStats(
        totalDistanceKm: 9.1,
        averageHeartRate: 162,
        maxHeartRate: 182,
        maxSpeedKmh: 29.1,
        averageSpeedKmh: 6.1,
        sprintCount: 52,
        caloriesBurned: 710,
        sprintDistanceKm: 1.4,
      ),
      locationHistory: _generateLocationHistory(),
    ),
  ];

  static const WeeklyStats weeklyStats = WeeklyStats(
    totalCalories: 2450,
    totalDistanceKm: 32.4,
    matchCount: 4,
    totalSprints: 42,
    maxSpeedKmh: 26.1,
  );

  static List<LocationPoint> _generateLocationHistory() {
    final random = Random(42);
    final points = <LocationPoint>[];
    final now = DateTime.now();

    for (int i = 0; i < 200; i++) {
      // Midfield-left bias pattern
      double x = 0.3 + random.nextDouble() * 0.5;
      double y = 0.2 + random.nextDouble() * 0.6;

      // Cluster more on left side midfield
      if (random.nextDouble() > 0.5) {
        x = 0.2 + random.nextDouble() * 0.3;
        y = 0.3 + random.nextDouble() * 0.4;
      }

      // Occasional attack runs
      if (random.nextDouble() > 0.85) {
        x = 0.6 + random.nextDouble() * 0.35;
        y = 0.2 + random.nextDouble() * 0.6;
      }

      points.add(LocationPoint(
        x: x.clamp(0.0, 1.0),
        y: y.clamp(0.0, 1.0),
        timestamp: now.subtract(Duration(seconds: (200 - i) * 27)),
        speedKmh: 3 + random.nextDouble() * 25,
      ));
    }
    return points;
  }
}

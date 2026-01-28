enum MatchResult { win, lose, draw }

class LocationPoint {
  final double x;
  final double y;
  final DateTime timestamp;
  final double speedKmh;

  const LocationPoint({
    required this.x,
    required this.y,
    required this.timestamp,
    this.speedKmh = 0,
  });
}

class MatchStats {
  final double totalDistanceKm;
  final int averageHeartRate;
  final int maxHeartRate;
  final double maxSpeedKmh;
  final double averageSpeedKmh;
  final int sprintCount;
  final int caloriesBurned;
  final double sprintDistanceKm;

  const MatchStats({
    this.totalDistanceKm = 0,
    this.averageHeartRate = 0,
    this.maxHeartRate = 0,
    this.maxSpeedKmh = 0,
    this.averageSpeedKmh = 0,
    this.sprintCount = 0,
    this.caloriesBurned = 0,
    this.sprintDistanceKm = 0,
  });
}

class FieldSize {
  final double lengthMeters;
  final double widthMeters;

  const FieldSize({
    this.lengthMeters = 105,
    this.widthMeters = 68,
  });

  double get area => lengthMeters * widthMeters;
}

class MatchData {
  final String id;
  final DateTime date;
  final int durationMinutes;
  final int myScore;
  final int opponentScore;
  final MatchResult result;
  final MatchStats stats;
  final List<LocationPoint> locationHistory;
  final FieldSize? fieldSize;
  final String? matchName;

  const MatchData({
    required this.id,
    required this.date,
    required this.durationMinutes,
    required this.myScore,
    required this.opponentScore,
    required this.result,
    required this.stats,
    this.locationHistory = const [],
    this.fieldSize,
    this.matchName,
  });

  String get resultText {
    switch (result) {
      case MatchResult.win:
        return '승리';
      case MatchResult.lose:
        return '패배';
      case MatchResult.draw:
        return '무승부';
    }
  }

  String get scoreText => '$myScore : $opponentScore';
}

class WeeklyStats {
  final int totalCalories;
  final double totalDistanceKm;
  final int matchCount;
  final int totalSprints;
  final double maxSpeedKmh;

  const WeeklyStats({
    this.totalCalories = 0,
    this.totalDistanceKm = 0,
    this.matchCount = 0,
    this.totalSprints = 0,
    this.maxSpeedKmh = 0,
  });
}

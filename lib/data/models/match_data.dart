import 'dart:collection';
import 'dart:math';

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
  final List<LocationPoint> _locationHistory;
  final FieldSize? fieldSize;
  final String? matchName;

  /// 외부 수정 불가능한 locationHistory 반환
  List<LocationPoint> get locationHistory =>
      UnmodifiableListView(_locationHistory);

  MatchData({
    required this.id,
    required this.date,
    required this.durationMinutes,
    required this.myScore,
    required this.opponentScore,
    required this.result,
    required this.stats,
    List<LocationPoint> locationHistory = const [],
    this.fieldSize,
    this.matchName,
  }) : _locationHistory = List.unmodifiable(locationHistory);

  /// 지정된 시간 범위로 경기 데이터를 자르고 통계를 재계산합니다.
  MatchData trim({required DateTime start, required DateTime end}) {
    // 1. 유효성 검사: 날짜 순서 확인
    if (start.isAfter(end)) {
      throw ArgumentError('Start time must be before end time');
    }

    // 2. 데이터 필터링
    final filteredLocations = locationHistory.where((p) {
      return (p.timestamp.isAfter(start) || p.timestamp.isAtSameMomentAs(start)) &&
             (p.timestamp.isBefore(end) || p.timestamp.isAtSameMomentAs(end));
    }).toList();

    // 3. 데이터 무결성 검사 (점이 너무 적으면 원본 반환 또는 에러)
    if (filteredLocations.length < 2) {
      // 데이터가 너무 적어 통계 계산이 불가능할 경우 원본을 반환하거나 예외 처리
      // 여기서는 안전하게 기존 데이터를 유지합니다.
      return this;
    }

    // 4. 통계 재계산
    double newTotalDistMeters = 0;
    double maxSpeed = 0;
    
    // 거리 및 속도 계산
    for (int i = 0; i < filteredLocations.length; i++) {
      final p = filteredLocations[i];

      // Max Speed
      if (p.speedKmh > maxSpeed) {
        maxSpeed = p.speedKmh;
      }

      // Total Distance
      if (i > 0) {
        final prev = filteredLocations[i - 1];
        // 유클리드 거리 계산 (미터 단위 가정)
        final dist = sqrt(pow(p.x - prev.x, 2) + pow(p.y - prev.y, 2));
        newTotalDistMeters += dist;
      }
    }

    // 새 지속 시간 (분)
    final newDurationMinutes = filteredLocations.last.timestamp
        .difference(filteredLocations.first.timestamp)
        .inMinutes;

    // 평균 속도 (km/h) = 거리(km) / 시간(h)
    double newAvgSpeed = 0;
    if (newDurationMinutes > 0) {
      newAvgSpeed = (newTotalDistMeters / 1000) / (newDurationMinutes / 60);
    } else if (filteredLocations.isNotEmpty) {
      // 시간이 0분으로 잡힐 정도로 짧은 경우, 점들의 평균 속도로 대체
      double sumSpeed = filteredLocations.fold(0, (sum, p) => sum + p.speedKmh);
      newAvgSpeed = sumSpeed / filteredLocations.length;
    }

    // 새 통계 객체 생성
    // 참고: sprintCount, caloriesBurned 등은 단순 계산이 어려우므로 
    // 시간 비율로 줄이거나 기존 값을 유지해야 함. 여기서는 보수적으로 비율 감소 적용.
    double ratio = 1.0;
    if (durationMinutes > 0) {
      ratio = newDurationMinutes / durationMinutes;
    }
    
    final newStats = MatchStats(
      totalDistanceKm: newTotalDistMeters / 1000,
      averageHeartRate: stats.averageHeartRate, // 유지
      maxHeartRate: stats.maxHeartRate, // 유지
      maxSpeedKmh: maxSpeed,
      averageSpeedKmh: newAvgSpeed,
      sprintCount: (stats.sprintCount * ratio).round(), // 비율로 감소
      caloriesBurned: (stats.caloriesBurned * ratio).round(), // 비율로 감소
      sprintDistanceKm: stats.sprintDistanceKm * ratio, // 비율로 감소
    );

    // 5. 새 MatchData 객체 반환
    return MatchData(
      id: id,
      date: filteredLocations.first.timestamp, // 시작 시간 변경
      durationMinutes: newDurationMinutes,
      myScore: myScore,
      opponentScore: opponentScore,
      result: result,
      stats: newStats,
      locationHistory: filteredLocations,
      fieldSize: fieldSize,
      matchName: matchName,
    );
  }

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

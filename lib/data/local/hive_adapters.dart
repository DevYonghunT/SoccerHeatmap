import 'package:hive/hive.dart';
import '../models/match_data.dart';

// Type IDs - 절대 변경하지 말 것
const int matchResultTypeId = 0;
const int locationPointTypeId = 1;
const int matchStatsTypeId = 2;
const int fieldSizeTypeId = 3;
const int matchDataTypeId = 4;

/// MatchResult enum을 문자열로 저장하여 순서 변경에 안전
class MatchResultAdapter extends TypeAdapter<MatchResult> {
  @override
  final int typeId = matchResultTypeId;

  // enum 값을 문자열 키로 매핑 (순서 변경에 안전)
  static const Map<String, MatchResult> _fromString = {
    'win': MatchResult.win,
    'lose': MatchResult.lose,
    'draw': MatchResult.draw,
  };

  static String _toStringKey(MatchResult result) {
    switch (result) {
      case MatchResult.win:
        return 'win';
      case MatchResult.lose:
        return 'lose';
      case MatchResult.draw:
        return 'draw';
    }
  }

  @override
  MatchResult read(BinaryReader reader) {
    final key = reader.readString();
    // 알 수 없는 값은 draw로 폴백 (데이터 손실 방지)
    return _fromString[key] ?? MatchResult.draw;
  }

  @override
  void write(BinaryWriter writer, MatchResult obj) {
    writer.writeString(_toStringKey(obj));
  }
}

class LocationPointAdapter extends TypeAdapter<LocationPoint> {
  @override
  final int typeId = locationPointTypeId;

  @override
  LocationPoint read(BinaryReader reader) {
    return LocationPoint(
      x: reader.readDouble(),
      y: reader.readDouble(),
      timestamp: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      speedKmh: reader.readDouble(),
    );
  }

  @override
  void write(BinaryWriter writer, LocationPoint obj) {
    writer.writeDouble(obj.x);
    writer.writeDouble(obj.y);
    writer.writeInt(obj.timestamp.millisecondsSinceEpoch);
    writer.writeDouble(obj.speedKmh);
  }
}

class MatchStatsAdapter extends TypeAdapter<MatchStats> {
  @override
  final int typeId = matchStatsTypeId;

  @override
  MatchStats read(BinaryReader reader) {
    return MatchStats(
      totalDistanceKm: reader.readDouble(),
      averageHeartRate: reader.readInt(),
      maxHeartRate: reader.readInt(),
      maxSpeedKmh: reader.readDouble(),
      averageSpeedKmh: reader.readDouble(),
      sprintCount: reader.readInt(),
      caloriesBurned: reader.readInt(),
      sprintDistanceKm: reader.readDouble(),
    );
  }

  @override
  void write(BinaryWriter writer, MatchStats obj) {
    writer.writeDouble(obj.totalDistanceKm);
    writer.writeInt(obj.averageHeartRate);
    writer.writeInt(obj.maxHeartRate);
    writer.writeDouble(obj.maxSpeedKmh);
    writer.writeDouble(obj.averageSpeedKmh);
    writer.writeInt(obj.sprintCount);
    writer.writeInt(obj.caloriesBurned);
    writer.writeDouble(obj.sprintDistanceKm);
  }
}

class FieldSizeAdapter extends TypeAdapter<FieldSize> {
  @override
  final int typeId = fieldSizeTypeId;

  @override
  FieldSize read(BinaryReader reader) {
    return FieldSize(
      lengthMeters: reader.readDouble(),
      widthMeters: reader.readDouble(),
    );
  }

  @override
  void write(BinaryWriter writer, FieldSize obj) {
    writer.writeDouble(obj.lengthMeters);
    writer.writeDouble(obj.widthMeters);
  }
}

class MatchDataAdapter extends TypeAdapter<MatchData> {
  @override
  final int typeId = matchDataTypeId;

  @override
  MatchData read(BinaryReader reader) {
    final id = reader.readString();
    final date = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
    final durationMinutes = reader.readInt();
    final myScore = reader.readInt();
    final opponentScore = reader.readInt();
    final result = reader.read() as MatchResult; // TypeAdapter가 처리
    final stats = reader.read() as MatchStats;
    final locationCount = reader.readInt();
    final locationHistory = <LocationPoint>[];
    for (int i = 0; i < locationCount; i++) {
      locationHistory.add(reader.read() as LocationPoint);
    }
    final hasFieldSize = reader.readBool();
    final fieldSize = hasFieldSize ? reader.read() as FieldSize : null;
    final hasMatchName = reader.readBool();
    final matchName = hasMatchName ? reader.readString() : null;

    return MatchData(
      id: id,
      date: date,
      durationMinutes: durationMinutes,
      myScore: myScore,
      opponentScore: opponentScore,
      result: result,
      stats: stats,
      locationHistory: locationHistory,
      fieldSize: fieldSize,
      matchName: matchName,
    );
  }

  @override
  void write(BinaryWriter writer, MatchData obj) {
    writer.writeString(obj.id);
    writer.writeInt(obj.date.millisecondsSinceEpoch);
    writer.writeInt(obj.durationMinutes);
    writer.writeInt(obj.myScore);
    writer.writeInt(obj.opponentScore);
    writer.write(obj.result); // TypeAdapter가 처리
    writer.write(obj.stats);
    writer.writeInt(obj.locationHistory.length);
    for (final point in obj.locationHistory) {
      writer.write(point);
    }
    writer.writeBool(obj.fieldSize != null);
    if (obj.fieldSize != null) writer.write(obj.fieldSize!);
    writer.writeBool(obj.matchName != null);
    if (obj.matchName != null) writer.writeString(obj.matchName!);
  }
}

/// Hive 어댑터 등록 (중복 등록 방지)
void registerHiveAdapters() {
  // 이미 등록된 어댑터는 건너뜀
  if (!Hive.isAdapterRegistered(matchResultTypeId)) {
    Hive.registerAdapter(MatchResultAdapter());
  }
  if (!Hive.isAdapterRegistered(locationPointTypeId)) {
    Hive.registerAdapter(LocationPointAdapter());
  }
  if (!Hive.isAdapterRegistered(matchStatsTypeId)) {
    Hive.registerAdapter(MatchStatsAdapter());
  }
  if (!Hive.isAdapterRegistered(fieldSizeTypeId)) {
    Hive.registerAdapter(FieldSizeAdapter());
  }
  if (!Hive.isAdapterRegistered(matchDataTypeId)) {
    Hive.registerAdapter(MatchDataAdapter());
  }
}

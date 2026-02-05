import 'dart:io';
import '../../data/models/match_data.dart';

class ExportService {
  /// XML 특수 문자 이스케이프
  /// XSS 및 XML 파싱 오류 방지
  static String _escapeXml(String input) {
    return input
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }

  /// Converts MatchData to CSV string (메모리 내 처리).
  /// 소규모 데이터용. 대용량은 toCsvStream 사용 권장.
  String toCsv(MatchData data) {
    final buffer = StringBuffer();
    buffer.writeln('timestamp,latitude,longitude,speed_kmh');

    for (final point in data.locationHistory) {
      final timeStr = point.timestamp.toIso8601String();
      final lat = point.x;
      final lon = point.y;
      final speed = point.speedKmh;

      buffer.writeln('$timeStr,$lat,$lon,$speed');
    }

    return buffer.toString();
  }

  /// Converts MatchData to GPX 1.1 XML string (메모리 내 처리).
  /// 소규모 데이터용. 대용량은 toGpxStream 사용 권장.
  String toGpx(MatchData data) {
    final buffer = StringBuffer();

    buffer.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    buffer.writeln('<gpx version="1.1" creator="SoccerHeatmap" '
        'xmlns="http://www.topografix.com/GPX/1/1" '
        'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" '
        'xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd">');

    buffer.writeln('  <trk>');
    // XML 이스케이프 적용
    final safeName = _escapeXml(data.matchName ?? 'Match ${data.id}');
    buffer.writeln('    <name>$safeName</name>');
    buffer.writeln('    <trkseg>');

    for (final point in data.locationHistory) {
      final lat = point.x;
      final lon = point.y;
      final timeStr = point.timestamp.toIso8601String();

      buffer.writeln('      <trkpt lat="$lat" lon="$lon">');
      buffer.writeln('        <time>$timeStr</time>');
      buffer.writeln('      </trkpt>');
    }

    buffer.writeln('    </trkseg>');
    buffer.writeln('  </trk>');
    buffer.writeln('</gpx>');

    return buffer.toString();
  }

  // ============================================================
  // 대용량 데이터용 스트리밍 메서드
  // ============================================================

  /// 청크 크기 (한 번에 처리할 포인트 수)
  static const int _chunkSize = 1000;

  /// CSV를 파일에 스트리밍 방식으로 쓰기 (대용량 처리).
  /// 메모리 효율적: 청크 단위로 파일에 쓰고 버퍼 비움.
  Future<void> toCsvStream(MatchData data, File outputFile) async {
    final sink = outputFile.openWrite();

    try {
      // Header
      sink.writeln('timestamp,latitude,longitude,speed_kmh');

      final points = data.locationHistory;
      final totalPoints = points.length;

      // 청크 단위로 처리
      for (int i = 0; i < totalPoints; i += _chunkSize) {
        final end = (i + _chunkSize < totalPoints) ? i + _chunkSize : totalPoints;
        final buffer = StringBuffer();

        for (int j = i; j < end; j++) {
          final point = points[j];
          final timeStr = point.timestamp.toIso8601String();
          buffer.writeln('$timeStr,${point.x},${point.y},${point.speedKmh}');
        }

        sink.write(buffer.toString());
        // 버퍼 플러시로 메모리 해제
        await sink.flush();
      }
    } finally {
      await sink.close();
    }
  }

  /// GPX를 파일에 스트리밍 방식으로 쓰기 (대용량 처리).
  /// 메모리 효율적: 청크 단위로 파일에 쓰고 버퍼 비움.
  Future<void> toGpxStream(MatchData data, File outputFile) async {
    final sink = outputFile.openWrite();

    try {
      // XML Header
      sink.writeln('<?xml version="1.0" encoding="UTF-8"?>');
      sink.writeln('<gpx version="1.1" creator="SoccerHeatmap" '
          'xmlns="http://www.topografix.com/GPX/1/1" '
          'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" '
          'xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd">');

      sink.writeln('  <trk>');
      final safeName = _escapeXml(data.matchName ?? 'Match ${data.id}');
      sink.writeln('    <name>$safeName</name>');
      sink.writeln('    <trkseg>');
      await sink.flush();

      final points = data.locationHistory;
      final totalPoints = points.length;

      // 청크 단위로 처리
      for (int i = 0; i < totalPoints; i += _chunkSize) {
        final end = (i + _chunkSize < totalPoints) ? i + _chunkSize : totalPoints;
        final buffer = StringBuffer();

        for (int j = i; j < end; j++) {
          final point = points[j];
          final timeStr = point.timestamp.toIso8601String();
          buffer.writeln('      <trkpt lat="${point.x}" lon="${point.y}">');
          buffer.writeln('        <time>$timeStr</time>');
          buffer.writeln('      </trkpt>');
        }

        sink.write(buffer.toString());
        await sink.flush();
      }

      // XML Footer
      sink.writeln('    </trkseg>');
      sink.writeln('  </trk>');
      sink.writeln('</gpx>');
    } finally {
      await sink.close();
    }
  }

  /// 데이터 크기에 따라 적절한 방식 자동 선택
  /// [threshold]: 스트리밍 방식으로 전환할 포인트 수 임계값 (기본 5000)
  Future<void> exportCsv(
    MatchData data,
    File outputFile, {
    int threshold = 5000,
  }) async {
    if (data.locationHistory.length > threshold) {
      await toCsvStream(data, outputFile);
    } else {
      await outputFile.writeAsString(toCsv(data));
    }
  }

  /// 데이터 크기에 따라 적절한 방식 자동 선택
  Future<void> exportGpx(
    MatchData data,
    File outputFile, {
    int threshold = 5000,
  }) async {
    if (data.locationHistory.length > threshold) {
      await toGpxStream(data, outputFile);
    } else {
      await outputFile.writeAsString(toGpx(data));
    }
  }
}

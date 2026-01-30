import '../../data/models/match_data.dart';

class ExportService {
  /// Converts MatchData to CSV string.
  /// Format: timestamp,latitude,longitude,speed_kmh
  /// Note: HeartRate is not available in individual LocationPoints currently.
  String toCsv(MatchData data) {
    final buffer = StringBuffer();
    // Header
    buffer.writeln('timestamp,latitude,longitude,speed_kmh');

    for (final point in data.locationHistory) {
      // Use ISO-8601 for timestamp
      final timeStr = point.timestamp.toIso8601String();
      
      // Mapping x -> latitude, y -> longitude.
      // Note: If x/y are normalized field coordinates (0.0-1.0), 
      // they will appear as such in the CSV.
      final lat = point.x;
      final lon = point.y;
      final speed = point.speedKmh;

      buffer.writeln('$timeStr,$lat,$lon,$speed');
    }

    return buffer.toString();
  }

  /// Converts MatchData to GPX 1.1 XML string.
  String toGpx(MatchData data) {
    final buffer = StringBuffer();
    
    // XML Declaration and GPX Root
    buffer.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    buffer.writeln('<gpx version="1.1" creator="SoccerHeatmap" '
        'xmlns="http://www.topografix.com/GPX/1/1" '
        'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" '
        'xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd">');
    
    // Track
    buffer.writeln('  <trk>');
    buffer.writeln('    <name>${data.matchName ?? "Match ${data.id}"}</name>');
    buffer.writeln('    <trkseg>');

    for (final point in data.locationHistory) {
      // Mapping x -> latitude, y -> longitude
      final lat = point.x;
      final lon = point.y;
      final timeStr = point.timestamp.toIso8601String();

      buffer.writeln('      <trkpt lat="$lat" lon="$lon">');
      buffer.writeln('        <time>$timeStr</time>');
      // Note: Speed is not a standard GPX 1.1 field in trkpt, 
      // often handled via extensions, so we omit it to ensure strict validation.
      buffer.writeln('      </trkpt>');
    }

    buffer.writeln('    </trkseg>');
    buffer.writeln('  </trk>');
    buffer.writeln('</gpx>');

    return buffer.toString();
  }
}

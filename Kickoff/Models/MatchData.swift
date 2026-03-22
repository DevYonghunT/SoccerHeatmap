import Foundation

enum MatchResult: String, Codable {
    case win, lose, draw

    var text: String {
        switch self {
        case .win: return "승리"
        case .lose: return "패배"
        case .draw: return "무승부"
        }
    }

    var emoji: String {
        switch self {
        case .win: return "W"
        case .lose: return "L"
        case .draw: return "D"
        }
    }
}

struct FieldSize: Codable {
    var lengthMeters: Double
    var widthMeters: Double

    init(lengthMeters: Double = 105, widthMeters: Double = 68) {
        self.lengthMeters = lengthMeters
        self.widthMeters = widthMeters
    }

    var area: Double { lengthMeters * widthMeters }
}

struct MatchData: Codable, Identifiable {
    let id: String
    let date: Date
    var durationMinutes: Int
    var myScore: Int
    var opponentScore: Int
    var result: MatchResult
    var stats: MatchStats
    var locationHistory: [LocationPoint]
    var fieldSize: FieldSize?
    var matchName: String?

    init(
        id: String = UUID().uuidString,
        date: Date = Date(),
        durationMinutes: Int = 0,
        myScore: Int = 0,
        opponentScore: Int = 0,
        result: MatchResult = .draw,
        stats: MatchStats = .empty,
        locationHistory: [LocationPoint] = [],
        fieldSize: FieldSize? = nil,
        matchName: String? = nil
    ) {
        self.id = id
        self.date = date
        self.durationMinutes = durationMinutes
        self.myScore = myScore
        self.opponentScore = opponentScore
        self.result = result
        self.stats = stats
        self.locationHistory = locationHistory
        self.fieldSize = fieldSize
        self.matchName = matchName
    }

    var resultText: String { result.text }
    var scoreText: String { "\(myScore) : \(opponentScore)" }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일 (E)"
        return formatter.string(from: date)
    }

    var formattedDuration: String {
        let hours = durationMinutes / 60
        let minutes = durationMinutes % 60
        if hours > 0 {
            return "\(hours)시간 \(minutes)분"
        }
        return "\(minutes)분"
    }

    static let sample = MatchData(
        id: "sample-1",
        date: Date(),
        durationMinutes: 90,
        myScore: 3,
        opponentScore: 1,
        result: .win,
        stats: MatchStats(
            totalDistanceKm: 8.5,
            averageHeartRate: 145,
            maxHeartRate: 185,
            maxSpeedKmh: 28.3,
            averageSpeedKmh: 6.2,
            sprintCount: 24,
            caloriesBurned: 720,
            sprintDistanceKm: 1.8
        ),
        locationHistory: LocationPoint.samplePoints,
        fieldSize: FieldSize(),
        matchName: "주말 리그"
    )
}

extension LocationPoint {
    static var samplePoints: [LocationPoint] {
        var points: [LocationPoint] = []
        let now = Date()
        for i in 0..<200 {
            let t = Double(i) / 200.0
            let x = 0.3 + 0.4 * sin(t * .pi * 4) * 0.5 + Double.random(in: -0.1...0.1)
            let y = 0.2 + 0.6 * t + Double.random(in: -0.1...0.1)
            let speed = Double.random(in: 2...25)
            points.append(LocationPoint(
                x: min(max(x, 0), 1),
                y: min(max(y, 0), 1),
                timestamp: now.addingTimeInterval(TimeInterval(i) * 27),
                speedKmh: speed
            ))
        }
        return points
    }
}

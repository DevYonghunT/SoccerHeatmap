import Foundation

struct MatchStats: Codable {
    var totalDistanceKm: Double
    var averageHeartRate: Int
    var maxHeartRate: Int
    var maxSpeedKmh: Double
    var averageSpeedKmh: Double
    var sprintCount: Int
    var caloriesBurned: Int
    var sprintDistanceKm: Double

    init(
        totalDistanceKm: Double = 0,
        averageHeartRate: Int = 0,
        maxHeartRate: Int = 0,
        maxSpeedKmh: Double = 0,
        averageSpeedKmh: Double = 0,
        sprintCount: Int = 0,
        caloriesBurned: Int = 0,
        sprintDistanceKm: Double = 0
    ) {
        self.totalDistanceKm = totalDistanceKm
        self.averageHeartRate = averageHeartRate
        self.maxHeartRate = maxHeartRate
        self.maxSpeedKmh = maxSpeedKmh
        self.averageSpeedKmh = averageSpeedKmh
        self.sprintCount = sprintCount
        self.caloriesBurned = caloriesBurned
        self.sprintDistanceKm = sprintDistanceKm
    }

    static let empty = MatchStats()
}

struct WeeklyStats {
    var totalCalories: Int
    var totalDistanceKm: Double
    var matchCount: Int
    var totalSprints: Int
    var maxSpeedKmh: Double

    init(
        totalCalories: Int = 0,
        totalDistanceKm: Double = 0,
        matchCount: Int = 0,
        totalSprints: Int = 0,
        maxSpeedKmh: Double = 0
    ) {
        self.totalCalories = totalCalories
        self.totalDistanceKm = totalDistanceKm
        self.matchCount = matchCount
        self.totalSprints = totalSprints
        self.maxSpeedKmh = maxSpeedKmh
    }

    static let empty = WeeklyStats()
}

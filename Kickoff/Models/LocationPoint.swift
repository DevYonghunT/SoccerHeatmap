import Foundation

struct LocationPoint: Codable, Identifiable {
    let id: UUID
    let x: Double // 0-1 normalized field position
    let y: Double // 0-1 normalized field position
    let timestamp: Date
    let speedKmh: Double

    init(x: Double, y: Double, timestamp: Date = Date(), speedKmh: Double = 0) {
        self.id = UUID()
        self.x = x
        self.y = y
        self.timestamp = timestamp
        self.speedKmh = speedKmh
    }
}

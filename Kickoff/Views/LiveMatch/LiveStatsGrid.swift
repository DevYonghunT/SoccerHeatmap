import SwiftUI

struct LiveStatsGrid: View {
    let distanceKm: Double
    let maxSpeedKmh: Double
    let calories: Int
    let sprintDistanceKm: Double

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            liveStatCell(
                icon: "figure.run",
                title: "거리",
                value: String(format: "%.2f", distanceKm),
                unit: "km",
                color: .primaryAccent
            )

            liveStatCell(
                icon: "bolt.fill",
                title: "최고 속도",
                value: String(format: "%.1f", maxSpeedKmh),
                unit: "km/h",
                color: .warning
            )

            liveStatCell(
                icon: "flame.fill",
                title: "칼로리",
                value: "\(calories)",
                unit: "kcal",
                color: .zone4
            )

            liveStatCell(
                icon: "hare.fill",
                title: "스프린트 거리",
                value: String(format: "%.2f", sprintDistanceKm),
                unit: "km",
                color: .success
            )
        }
    }

    private func liveStatCell(icon: String, title: String, value: String, unit: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(color)
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.textSecondary)
            }

            HStack(alignment: .lastTextBaseline, spacing: 3) {
                Text(value)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.textPrimary)
                    .monospacedDigit()
                Text(unit)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.cardBackground)
        .cornerRadius(16)
    }
}

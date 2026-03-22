import SwiftUI

struct LastMatchCard: View {
    let match: MatchData

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text("최근 경기")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.textSecondary)
                Spacer()
                ResultBadge(result: match.result)
            }

            // Score
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(match.matchName ?? "경기")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.textPrimary)
                    Text(match.formattedDate)
                        .font(.system(size: 12))
                        .foregroundColor(.textSecondary)
                }
                Spacer()
                Text(match.scoreText)
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundColor(.textPrimary)
            }

            // Heatmap Preview
            HeatmapView(points: match.locationHistory)
                .frame(height: 120)
                .cornerRadius(10)

            // Quick Stats
            HStack(spacing: 8) {
                MiniStatCard(
                    title: "거리",
                    value: String(format: "%.1f", match.stats.totalDistanceKm),
                    unit: "km"
                )
                MiniStatCard(
                    title: "최고 속도",
                    value: String(format: "%.0f", match.stats.maxSpeedKmh),
                    unit: "km/h"
                )
                MiniStatCard(
                    title: "칼로리",
                    value: "\(match.stats.caloriesBurned)",
                    unit: "kcal"
                )
            }
        }
        .padding(18)
        .background(Color.cardBackground)
        .cornerRadius(20)
    }
}

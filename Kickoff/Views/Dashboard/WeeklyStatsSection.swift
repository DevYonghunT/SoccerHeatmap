import SwiftUI

struct WeeklyStatsSection: View {
    let stats: WeeklyStats

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("이번 주 활동")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.textPrimary)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                weeklyStatItem(icon: "flame.fill", title: "칼로리", value: "\(stats.totalCalories)", unit: "kcal", color: .warning)
                weeklyStatItem(icon: "figure.run", title: "총 거리", value: String(format: "%.1f", stats.totalDistanceKm), unit: "km", color: .primaryAccent)
                weeklyStatItem(icon: "sportscourt.fill", title: "경기 수", value: "\(stats.matchCount)", unit: "경기", color: .secondaryAccent)
                weeklyStatItem(icon: "bolt.fill", title: "스프린트", value: "\(stats.totalSprints)", unit: "회", color: .success)
            }
        }
    }

    private func weeklyStatItem(icon: String, title: String, value: String, unit: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
                .frame(width: 36, height: 36)
                .background(color.opacity(0.15))
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.textSecondary)
                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Text(value)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.textPrimary)
                    Text(unit)
                        .font(.system(size: 10))
                        .foregroundColor(.textSecondary)
                }
            }

            Spacer()
        }
        .padding(12)
        .background(Color.cardBackground)
        .cornerRadius(14)
    }
}

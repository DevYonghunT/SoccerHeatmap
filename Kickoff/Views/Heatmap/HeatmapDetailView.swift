import SwiftUI

struct HeatmapDetailView: View {
    let match: MatchData
    @State private var mode: HeatmapMode = .position

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Mode Toggle
                HStack(spacing: 0) {
                    modeButton(title: "위치 히트맵", isSelected: mode == .position) {
                        mode = .position
                    }
                    modeButton(title: "속도 히트맵", isSelected: mode == .speed) {
                        mode = .speed
                    }
                }
                .background(Color.cardInner)
                .cornerRadius(12)
                .padding(.horizontal, 24)

                // Heatmap
                HeatmapView(points: match.locationHistory, mode: mode)
                    .padding(.horizontal, 24)

                // Stats
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        StatCard(
                            title: "총 거리",
                            value: String(format: "%.1f", match.stats.totalDistanceKm),
                            unit: "km",
                            icon: "figure.run",
                            accentColor: .primaryAccent
                        )
                        StatCard(
                            title: "최고 속도",
                            value: String(format: "%.1f", match.stats.maxSpeedKmh),
                            unit: "km/h",
                            icon: "bolt.fill",
                            accentColor: .warning
                        )
                    }

                    HStack(spacing: 12) {
                        StatCard(
                            title: "평균 심박수",
                            value: "\(match.stats.averageHeartRate)",
                            unit: "bpm",
                            icon: "heart.fill",
                            accentColor: .primaryAccent
                        )
                        StatCard(
                            title: "스프린트",
                            value: "\(match.stats.sprintCount)",
                            unit: "회",
                            icon: "flame.fill",
                            accentColor: .warning
                        )
                    }
                }
                .padding(.horizontal, 24)
            }
            .padding(.vertical, 20)
        }
        .background(Color.appBackground)
        .navigationTitle("히트맵 분석")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func modeButton(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(isSelected ? .textPrimary : .textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(isSelected ? Color.cardBackground : Color.clear)
                .cornerRadius(10)
        }
        .padding(2)
    }
}

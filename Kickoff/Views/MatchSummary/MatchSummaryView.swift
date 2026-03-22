import SwiftUI

struct MatchSummaryView: View {
    let match: MatchData
    let isPostMatch: Bool
    @Environment(\.dismiss) private var dismiss
    @State private var showShare = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Result Header
                VStack(spacing: 12) {
                    ResultBadge(result: match.result)

                    Text(match.scoreText)
                        .font(.system(size: 48, weight: .black, design: .rounded))
                        .foregroundColor(.textPrimary)

                    if let name = match.matchName {
                        Text(name)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.textSecondary)
                    }

                    Text(match.formattedDate)
                        .font(.system(size: 13))
                        .foregroundColor(.textTertiary)

                    Text(match.formattedDuration)
                        .font(.system(size: 13))
                        .foregroundColor(.textTertiary)
                }
                .padding(.top, 16)

                // Heatmap
                VStack(alignment: .leading, spacing: 12) {
                    Text("히트맵")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.textPrimary)

                    NavigationLink(destination: HeatmapDetailView(match: match)) {
                        HeatmapView(points: match.locationHistory)
                            .frame(height: 180)
                    }
                }
                .padding(.horizontal, 24)

                // Stats Grid
                VStack(alignment: .leading, spacing: 12) {
                    Text("경기 통계")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.textPrimary)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
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
                        StatCard(
                            title: "평균 속도",
                            value: String(format: "%.1f", match.stats.averageSpeedKmh),
                            unit: "km/h",
                            icon: "speedometer",
                            accentColor: .secondaryAccent
                        )
                        StatCard(
                            title: "칼로리",
                            value: "\(match.stats.caloriesBurned)",
                            unit: "kcal",
                            icon: "flame.fill",
                            accentColor: .zone4
                        )
                        StatCard(
                            title: "평균 심박수",
                            value: "\(match.stats.averageHeartRate)",
                            unit: "bpm",
                            icon: "heart.fill",
                            accentColor: .primaryAccent
                        )
                        StatCard(
                            title: "최대 심박수",
                            value: "\(match.stats.maxHeartRate)",
                            unit: "bpm",
                            icon: "heart.fill",
                            accentColor: .zone5
                        )
                        StatCard(
                            title: "스프린트",
                            value: "\(match.stats.sprintCount)",
                            unit: "회",
                            icon: "hare.fill",
                            accentColor: .success
                        )
                        StatCard(
                            title: "스프린트 거리",
                            value: String(format: "%.2f", match.stats.sprintDistanceKm),
                            unit: "km",
                            icon: "hare.fill",
                            accentColor: .success
                        )
                    }
                }
                .padding(.horizontal, 24)

                // Action Buttons
                VStack(spacing: 12) {
                    PrimaryButton(text: "공유하기", icon: "square.and.arrow.up") {
                        showShare = true
                    }

                    if isPostMatch {
                        SecondaryButton(text: "홈으로", icon: "house.fill") {
                            // Pop to root
                            dismiss()
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .background(Color.appBackground)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showShare) {
            ShareView(match: match)
        }
    }
}

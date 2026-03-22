import SwiftUI

struct ShareView: View {
    let match: MatchData
    @Environment(\.dismiss) private var dismiss
    @State private var shareImage: UIImage?
    @State private var isGenerating = false

    private var playerName: String {
        UserDefaults.standard.string(forKey: "playerName") ?? ""
    }
    private var backNumber: String {
        UserDefaults.standard.string(forKey: "backNumber") ?? ""
    }
    private var position: String {
        UserDefaults.standard.string(forKey: "position") ?? "MF"
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Preview
                sharePreview
                    .padding(.horizontal, 24)

                // Share Buttons
                VStack(spacing: 12) {
                    PrimaryButton(text: "인스타그램 스토리 공유", icon: "camera.fill") {
                        generateAndShare()
                    }

                    SecondaryButton(text: "이미지 저장", icon: "square.and.arrow.down") {
                        generateAndSave()
                    }
                }
                .padding(.horizontal, 24)

                Spacer()
            }
            .background(Color.appBackground)
            .navigationTitle("공유하기")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("닫기") { dismiss() }
                        .foregroundColor(.textSecondary)
                }
            }
        }
    }

    // MARK: - Share Preview (9:16 Story Format)

    private var sharePreview: some View {
        VStack(spacing: 0) {
            storyContent
                .aspectRatio(9.0 / 16.0, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    @ViewBuilder
    private var storyContent: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color(hex: 0x0D0F14), Color(hex: 0x1A0A1A), Color(hex: 0x0D0F14)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(spacing: 16) {
                Spacer()
                    .frame(height: 20)

                // Jersey-style player info
                jerseyHeader

                // Logo
                Text("KICKOFF")
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundColor(.primaryAccent)

                // Result
                VStack(spacing: 6) {
                    Text(match.resultText)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.primaryAccent)

                    Text(match.scoreText)
                        .font(.system(size: 48, weight: .black, design: .rounded))
                        .foregroundColor(.white)

                    if let name = match.matchName {
                        Text(name)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.textSecondary)
                    }

                    Text(match.formattedDate)
                        .font(.system(size: 11))
                        .foregroundColor(.textTertiary)
                }

                // Heatmap
                HeatmapView(points: match.locationHistory)
                    .frame(height: 130)
                    .padding(.horizontal, 20)

                // Stats
                HStack(spacing: 12) {
                    shareStatItem(value: String(format: "%.1f", match.stats.totalDistanceKm), unit: "km", label: "거리")
                    shareStatItem(value: String(format: "%.0f", match.stats.maxSpeedKmh), unit: "km/h", label: "최고 속도")
                    shareStatItem(value: "\(match.stats.caloriesBurned)", unit: "kcal", label: "칼로리")
                }
                .padding(.horizontal, 20)

                HStack(spacing: 12) {
                    shareStatItem(value: "\(match.stats.averageHeartRate)", unit: "bpm", label: "심박수")
                    shareStatItem(value: "\(match.stats.sprintCount)", unit: "회", label: "스프린트")
                    shareStatItem(value: match.formattedDuration, unit: "", label: "경기 시간")
                }
                .padding(.horizontal, 20)

                Spacer()

                // Footer
                Text("KICKOFF - Soccer Heatmap Tracker")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.textTertiary)
                    .padding(.bottom, 20)
            }
        }
    }

    // MARK: - Jersey-style Header

    @ViewBuilder
    private var jerseyHeader: some View {
        if !backNumber.isEmpty || !playerName.isEmpty {
            VStack(spacing: 4) {
                // Back number - large, like a jersey
                if !backNumber.isEmpty {
                    Text(backNumber)
                        .font(.system(size: 64, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: Color.primaryAccent.opacity(0.4), radius: 8, x: 0, y: 0)
                }

                // Player name - jersey style
                if !playerName.isEmpty {
                    Text(playerName.uppercased())
                        .font(.system(size: 18, weight: .black))
                        .foregroundColor(.white)
                        .tracking(4)
                }

                // Position badge
                Text(position)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.primaryAccent)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.primaryAccent.opacity(0.15))
                    .cornerRadius(8)

                // Divider line
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color.clear, Color.primaryAccent.opacity(0.4), Color.clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 1)
                    .padding(.horizontal, 40)
                    .padding(.top, 8)
            }
            .padding(.vertical, 8)
        }
    }

    private func shareStatItem(value: String, unit: String, label: String) -> some View {
        VStack(spacing: 4) {
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                if !unit.isEmpty {
                    Text(unit)
                        .font(.system(size: 10))
                        .foregroundColor(.textSecondary)
                }
            }
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color.cardBackground.opacity(0.6))
        .cornerRadius(10)
    }

    // MARK: - Actions

    @MainActor
    private func generateAndShare() {
        let renderer = ImageRenderer(content: storyContent.frame(width: 1080, height: 1920))
        renderer.scale = UIScreen.main.scale

        guard let image = renderer.uiImage else { return }

        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }

    @MainActor
    private func generateAndSave() {
        let renderer = ImageRenderer(content: storyContent.frame(width: 1080, height: 1920))
        renderer.scale = UIScreen.main.scale

        guard let image = renderer.uiImage else { return }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)

        dismiss()
    }
}

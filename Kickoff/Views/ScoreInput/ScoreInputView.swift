import SwiftUI

struct ScoreInputView: View {
    @EnvironmentObject var storageService: MatchStorageService
    @State var match: MatchData
    @State private var myScore: Int = 0
    @State private var opponentScore: Int = 0
    @State private var matchName: String = ""
    @State private var navigateToSummary = false

    init(match: MatchData) {
        _match = State(initialValue: match)
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "flag.checkered")
                            .font(.system(size: 48))
                            .foregroundColor(.primaryAccent)

                        Text("경기 종료!")
                            .font(.system(size: 28, weight: .black))
                            .foregroundColor(.textPrimary)

                        Text(match.formattedDuration)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.textSecondary)
                    }
                    .padding(.top, 32)

                    // Match Name
                    VStack(alignment: .leading, spacing: 8) {
                        Text("경기 이름")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.textSecondary)

                        TextField("예: 주말 리그", text: $matchName)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.textPrimary)
                            .padding(14)
                            .background(Color.cardBackground)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 24)

                    // Score Input
                    VStack(spacing: 20) {
                        Text("스코어 입력")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.textSecondary)

                        HStack(spacing: 24) {
                            scoreColumn(title: "우리 팀", score: $myScore)
                            Text(":")
                                .font(.system(size: 40, weight: .black, design: .rounded))
                                .foregroundColor(.textTertiary)
                            scoreColumn(title: "상대 팀", score: $opponentScore)
                        }
                    }
                    .padding(.horizontal, 24)

                    // Quick Stats Preview
                    HStack(spacing: 10) {
                        MiniStatCard(
                            title: "거리",
                            value: String(format: "%.1f", match.stats.totalDistanceKm),
                            unit: "km"
                        )
                        MiniStatCard(
                            title: "칼로리",
                            value: "\(match.stats.caloriesBurned)",
                            unit: "kcal"
                        )
                        MiniStatCard(
                            title: "스프린트",
                            value: "\(match.stats.sprintCount)",
                            unit: "회"
                        )
                    }
                    .padding(.horizontal, 24)
                }
            }

            // Save Button
            PrimaryButton(text: "저장하기", icon: "checkmark") {
                saveMatch()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .background(Color.appBackground)
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $navigateToSummary) {
            MatchSummaryView(match: match, isPostMatch: true)
        }
    }

    private func scoreColumn(title: String, score: Binding<Int>) -> some View {
        VStack(spacing: 12) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.textSecondary)

            VStack(spacing: 8) {
                Button {
                    score.wrappedValue += 1
                } label: {
                    Image(systemName: "chevron.up")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.textSecondary)
                }

                Text("\(score.wrappedValue)")
                    .font(.system(size: 48, weight: .black, design: .rounded))
                    .foregroundColor(.textPrimary)
                    .monospacedDigit()

                Button {
                    if score.wrappedValue > 0 {
                        score.wrappedValue -= 1
                    }
                } label: {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.textSecondary)
                }
            }
            .frame(width: 100)
            .padding(.vertical, 16)
            .background(Color.cardBackground)
            .cornerRadius(16)
        }
    }

    private func saveMatch() {
        let result: MatchResult = {
            if myScore > opponentScore { return .win }
            if myScore < opponentScore { return .lose }
            return .draw
        }()

        match.myScore = myScore
        match.opponentScore = opponentScore
        match.result = result
        match.matchName = matchName.isEmpty ? nil : matchName

        storageService.saveMatch(match)
        navigateToSummary = true
    }
}

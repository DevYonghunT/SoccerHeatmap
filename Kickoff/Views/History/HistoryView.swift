import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var storageService: MatchStorageService

    var body: some View {
        NavigationStack {
            Group {
                if storageService.matches.isEmpty {
                    emptyState
                } else {
                    matchList
                }
            }
            .background(Color.appBackground)
            .navigationTitle("경기 기록")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "sportscourt")
                .font(.system(size: 60))
                .foregroundColor(.textTertiary)
            Text("아직 경기 기록이 없습니다")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.textSecondary)
            Text("첫 경기를 시작해보세요!")
                .font(.system(size: 14))
                .foregroundColor(.textTertiary)
            Spacer()
        }
    }

    private var matchList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // Summary Bar
                HStack(spacing: 16) {
                    summaryItem(value: "\(storageService.totalMatches)", label: "경기")
                    summaryItem(value: "\(storageService.totalWins)", label: "승리")
                    summaryItem(value: String(format: "%.0f%%", storageService.winRate), label: "승률")
                    summaryItem(value: String(format: "%.0f", storageService.totalDistance), label: "km")
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)

                // Grouped by month
                let grouped = Dictionary(grouping: storageService.matches) { match -> String in
                    let formatter = DateFormatter()
                    formatter.locale = Locale(identifier: "ko_KR")
                    formatter.dateFormat = "yyyy년 M월"
                    return formatter.string(from: match.date)
                }.sorted { $0.key > $1.key }

                ForEach(grouped, id: \.key) { month, matches in
                    Section {
                        ForEach(matches) { match in
                            NavigationLink(destination: MatchSummaryView(match: match, isPostMatch: false)) {
                                matchRow(match)
                            }
                        }
                    } header: {
                        HStack {
                            Text(month)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.textPrimary)
                            Spacer()
                            Text("\(matches.count)경기")
                                .font(.system(size: 13))
                                .foregroundColor(.textSecondary)
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 8)
                    }
                }
            }
            .padding(.bottom, 24)
        }
    }

    private func summaryItem(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.textPrimary)
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color.cardBackground)
        .cornerRadius(12)
    }

    private func matchRow(_ match: MatchData) -> some View {
        HStack(spacing: 14) {
            // Result indicator
            RoundedRectangle(cornerRadius: 2)
                .fill(resultColor(match.result))
                .frame(width: 4, height: 44)

            VStack(alignment: .leading, spacing: 3) {
                Text(match.matchName ?? "경기")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.textPrimary)

                HStack(spacing: 8) {
                    Text(match.formattedDate)
                        .font(.system(size: 12))
                        .foregroundColor(.textSecondary)
                    Text("\(match.formattedDuration)")
                        .font(.system(size: 12))
                        .foregroundColor(.textTertiary)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                Text(match.scoreText)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.textPrimary)

                Text(match.resultText)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(resultColor(match.result))
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.textTertiary)
        }
        .padding(16)
        .background(Color.cardBackground)
        .cornerRadius(14)
        .padding(.horizontal, 24)
    }

    private func resultColor(_ result: MatchResult) -> Color {
        switch result {
        case .win: return .primaryAccent
        case .lose: return .secondaryAccent
        case .draw: return .textSecondary
        }
    }
}

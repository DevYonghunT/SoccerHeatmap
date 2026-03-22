import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var storageService: MatchStorageService
    @StateObject private var viewModel: DashboardViewModel
    @State private var selectedTab = 0
    @State private var navigateToFieldSetup = false
    @State private var showFieldSetup = false

    init(storageService: MatchStorageService) {
        _viewModel = StateObject(wrappedValue: DashboardViewModel(storageService: storageService))
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                homeTab
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("홈")
                    }
                    .tag(0)

                HistoryView()
                    .tabItem {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                        Text("기록")
                    }
                    .tag(1)

                // Placeholder tab for FAB spacing
                Color.clear
                    .tabItem {
                        Text("")
                    }
                    .tag(99)

                statsTab
                    .tabItem {
                        Image(systemName: "chart.bar.fill")
                        Text("통계")
                    }
                    .tag(2)

                ProfileView()
                    .tabItem {
                        Image(systemName: "person.fill")
                        Text("프로필")
                    }
                    .tag(3)
            }
            .tint(.primaryAccent)

            // Floating Action Button
            fabButton
        }
        .fullScreenCover(isPresented: $showFieldSetup) {
            NavigationStack {
                FieldSetupView()
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button {
                                showFieldSetup = false
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.textSecondary)
                            }
                        }
                    }
            }
        }
    }

    // MARK: - Floating Action Button

    private var fabButton: some View {
        Button {
            showFieldSetup = true
        } label: {
            ZStack {
                Circle()
                    .fill(Color.primaryAccent)
                    .frame(width: 64, height: 64)
                    .shadow(color: Color.primaryAccent.opacity(0.45), radius: 12, x: 0, y: 4)

                Image(systemName: "play.fill")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .offset(y: -28)
    }

    // MARK: - Home Tab

    private var homeTab: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    dashboardHeader

                    // Last Match Card
                    if let match = viewModel.lastMatch {
                        LastMatchCard(match: match)
                    }

                    // Weekly Stats
                    WeeklyStatsSection(stats: viewModel.weeklyStats)

                    // Recent Matches
                    recentMatchesSection
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 100)
            }
            .background(Color.appBackground)
        }
    }

    private var dashboardHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("KICKOFF")
                .font(.system(size: 28, weight: .black, design: .rounded))
                .foregroundColor(.primaryAccent)

            Text("오늘도 그라운드를 달려볼까요?")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.textSecondary)
        }
        .padding(.top, 8)
    }

    private var recentMatchesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("최근 경기")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.textPrimary)
                Spacer()
                Button("전체 보기") {
                    selectedTab = 1
                }
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.textSecondary)
            }

            if viewModel.recentMatches.isEmpty {
                Text("아직 경기 기록이 없습니다")
                    .font(.system(size: 14))
                    .foregroundColor(.textTertiary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 32)
            } else {
                ForEach(viewModel.recentMatches) { match in
                    NavigationLink(destination: MatchSummaryView(match: match, isPostMatch: false)) {
                        recentMatchRow(match)
                    }
                }
            }
        }
    }

    private func recentMatchRow(_ match: MatchData) -> some View {
        HStack(spacing: 14) {
            ResultBadge(result: match.result)

            VStack(alignment: .leading, spacing: 3) {
                Text(match.matchName ?? "경기")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.textPrimary)
                Text(match.formattedDate)
                    .font(.system(size: 12))
                    .foregroundColor(.textSecondary)
            }

            Spacer()

            Text(match.scoreText)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.textPrimary)
        }
        .padding(14)
        .background(Color.cardBackground)
        .cornerRadius(12)
    }

    // MARK: - Stats Tab

    private var statsTab: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("전체 통계")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.textPrimary)
                        .padding(.top, 8)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        StatCard(
                            title: "총 경기",
                            value: "\(storageService.totalMatches)",
                            unit: "경기",
                            icon: "sportscourt.fill",
                            accentColor: .secondaryAccent
                        )
                        StatCard(
                            title: "승률",
                            value: String(format: "%.0f", storageService.winRate),
                            unit: "%",
                            icon: "trophy.fill",
                            accentColor: .warning
                        )
                        StatCard(
                            title: "총 거리",
                            value: String(format: "%.1f", storageService.totalDistance),
                            unit: "km",
                            icon: "figure.run",
                            accentColor: .primaryAccent
                        )
                        StatCard(
                            title: "승리",
                            value: "\(storageService.totalWins)",
                            unit: "승",
                            icon: "star.fill",
                            accentColor: .success
                        )
                    }

                    if let lastMatch = viewModel.lastMatch {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("마지막 경기 히트맵")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.textPrimary)

                            NavigationLink(destination: HeatmapDetailView(match: lastMatch)) {
                                HeatmapView(points: lastMatch.locationHistory)
                                    .frame(height: 180)
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 100)
            }
            .background(Color.appBackground)
        }
    }
}

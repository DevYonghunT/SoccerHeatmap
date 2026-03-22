import SwiftUI

struct LiveMatchView: View {
    @EnvironmentObject var storageService: MatchStorageService
    @StateObject private var viewModel: LiveMatchViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showEndDialog = false
    @State private var showExitDialog = false
    @State private var navigateToScoreInput = false
    @State private var completedMatch: MatchData?

    init(healthService: HealthKitService, locationService: LocationService, storageService: MatchStorageService) {
        _viewModel = StateObject(wrappedValue: LiveMatchViewModel(
            healthService: healthService,
            locationService: locationService,
            storageService: storageService
        ))
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button {
                    if viewModel.isActive {
                        showExitDialog = true
                    } else {
                        dismiss()
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.textPrimary)
                }

                Spacer()

                LiveBadge(isRunning: viewModel.status == .running)

                Spacer()

                // Spacer for symmetry
                Color.clear.frame(width: 20, height: 20)
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)

            ScrollView {
                VStack(spacing: 24) {
                    // Timer
                    LiveTimerView(
                        formattedTime: viewModel.formattedTime,
                        halfLabel: viewModel.halfLabel
                    )

                    // Heart Rate Card
                    HeartRateCard(
                        currentBpm: viewModel.currentHeartRate,
                        zone: viewModel.heartRateZone,
                        history: viewModel.healthService.heartRateHistory
                    )

                    // Stats Grid
                    LiveStatsGrid(
                        distanceKm: viewModel.totalDistanceKm,
                        maxSpeedKmh: viewModel.maxSpeedKmh,
                        calories: viewModel.caloriesBurned,
                        sprintDistanceKm: viewModel.sprintDistanceKm
                    )
                }
                .padding(.horizontal, 24)
            }

            Spacer()

            // Controls
            HStack(spacing: 16) {
                // Pause/Resume
                Button {
                    if viewModel.status == .running {
                        viewModel.pauseMatch()
                    } else if viewModel.status == .paused {
                        viewModel.resumeMatch()
                    }
                } label: {
                    Image(systemName: viewModel.status == .running ? "pause.fill" : "play.fill")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.textPrimary)
                        .frame(width: 64, height: 64)
                        .background(Color.cardBackground)
                        .clipShape(Circle())
                }

                // Stop
                Button {
                    showEndDialog = true
                } label: {
                    Image(systemName: "stop.fill")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 64, height: 64)
                        .background(Color.primaryAccent)
                        .clipShape(Circle())
                }
            }
            .padding(.bottom, 32)
        }
        .background(Color.appBackground)
        .navigationBarHidden(true)
        .onAppear {
            Task {
                await viewModel.startMatch()
            }
        }
        .alert("경기 종료", isPresented: $showEndDialog) {
            Button("취소", role: .cancel) { }
            Button("종료", role: .destructive) {
                Task {
                    let match = await viewModel.stopMatch()
                    completedMatch = match
                    navigateToScoreInput = true
                }
            }
        } message: {
            Text("경기를 종료하시겠습니까?")
        }
        .alert("경기 중단", isPresented: $showExitDialog) {
            Button("계속하기", role: .cancel) { }
            Button("나가기", role: .destructive) {
                Task {
                    _ = await viewModel.stopMatch()
                    dismiss()
                }
            }
        } message: {
            Text("경기가 진행 중입니다. 나가면 데이터가 손실됩니다.")
        }
        .navigationDestination(isPresented: $navigateToScoreInput) {
            if let match = completedMatch {
                ScoreInputView(match: match)
            }
        }
    }
}

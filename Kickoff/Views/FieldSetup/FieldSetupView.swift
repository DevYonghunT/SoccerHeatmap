import SwiftUI
import MapKit

struct FieldSetupView: View {
    @EnvironmentObject var storageService: MatchStorageService
    @StateObject private var locationService = LocationService()
    @StateObject private var favoriteStore = FavoriteFieldStore()
    @State private var navigateToLiveMatch = false
    @State private var skipCalibration = false
    @State private var showSaveSheet = false
    @State private var saveName = ""
    @State private var showFavorites = false

    private let cornerLabels = ["왼쪽 위 코너", "오른쪽 위 코너", "오른쪽 아래 코너", "왼쪽 아래 코너"]

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 28) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "sportscourt.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.primaryAccent)

                        Text("필드 설정")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.textPrimary)

                        Text("정확한 히트맵을 위해 필드의\n네 꼭짓점을 설정해주세요")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 24)

                    // Quick Start Button
                    quickStartButton
                        .padding(.horizontal, 24)

                    // Favorite Fields Section
                    if !favoriteStore.fields.isEmpty {
                        favoriteFieldsSection
                            .padding(.horizontal, 24)
                    }

                    // Calibration Progress
                    VStack(spacing: 16) {
                        ForEach(0..<4, id: \.self) { index in
                            cornerRow(index: index)
                        }
                    }
                    .padding(.horizontal, 24)

                    // Current Location Info
                    if let location = locationService.currentLocation {
                        VStack(spacing: 6) {
                            Text("현재 위치")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.textSecondary)
                            Text(String(format: "%.6f, %.6f", location.coordinate.latitude, location.coordinate.longitude))
                                .font(.system(size: 13, weight: .medium, design: .monospaced))
                                .foregroundColor(.textPrimary)
                            Text(String(format: "정확도: %.1f m", location.horizontalAccuracy))
                                .font(.system(size: 11))
                                .foregroundColor(location.horizontalAccuracy < 10 ? .success : .warning)
                        }
                        .padding(14)
                        .background(Color.cardBackground)
                        .cornerRadius(12)
                    }

                    // Capture Button
                    if locationService.calibration.corners.count < 4 {
                        VStack(spacing: 12) {
                            PrimaryButton(
                                text: "\(locationService.calibrationCornerLabel) 캡처",
                                icon: "mappin.and.ellipse"
                            ) {
                                locationService.addCalibrationCorner()
                            }
                            .padding(.horizontal, 24)

                            Button {
                                locationService.resetCalibration()
                            } label: {
                                Text("초기화")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.textSecondary)
                            }
                        }
                    }
                }
            }

            // Bottom buttons
            VStack(spacing: 12) {
                if locationService.calibration.isComplete {
                    HStack(spacing: 12) {
                        PrimaryButton(text: "경기 시작", icon: "play.fill") {
                            navigateToLiveMatch = true
                        }

                        // Save to favorites button
                        Button {
                            showSaveSheet = true
                        } label: {
                            Image(systemName: "star.fill")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.warning)
                                .frame(width: 56, height: 56)
                                .background(Color.cardBackground)
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.warning.opacity(0.3), lineWidth: 1)
                                )
                        }
                    }
                    .padding(.horizontal, 24)
                }

                SecondaryButton(text: "캘리브레이션 건너뛰기", icon: "forward.fill") {
                    skipCalibration = true
                    navigateToLiveMatch = true
                }
                .padding(.horizontal, 24)
            }
            .padding(.bottom, 24)
        }
        .background(Color.appBackground)
        .navigationTitle("필드 설정")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            locationService.requestAuthorization()
            locationService.startTracking()
        }
        .onDisappear {
            if !navigateToLiveMatch {
                locationService.stopTracking()
            }
        }
        .navigationDestination(isPresented: $navigateToLiveMatch) {
            LiveMatchView(
                healthService: HealthKitService(),
                locationService: skipCalibration ? LocationService() : locationService,
                storageService: storageService
            )
        }
        .alert("즐겨찾기 구장 저장", isPresented: $showSaveSheet) {
            TextField("구장 이름", text: $saveName)
            Button("저장") {
                guard !saveName.isEmpty else { return }
                let field = FavoriteField(name: saveName, calibration: locationService.calibration)
                favoriteStore.save(field: field)
                saveName = ""
            }
            Button("취소", role: .cancel) {
                saveName = ""
            }
        } message: {
            Text("이 구장의 이름을 입력해주세요")
        }
    }

    // MARK: - Quick Start Button

    private var quickStartButton: some View {
        Button {
            skipCalibration = true
            navigateToLiveMatch = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.warning)

                VStack(alignment: .leading, spacing: 2) {
                    Text("빠른 시작")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.textPrimary)
                    Text("기본 크기 (105x68m) 로 바로 시작")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.textTertiary)
            }
            .padding(16)
            .background(Color.warning.opacity(0.1))
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.warning.opacity(0.25), lineWidth: 1)
            )
        }
    }

    // MARK: - Favorite Fields Section

    private var favoriteFieldsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "star.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.warning)
                Text("즐겨찾기 구장")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.textPrimary)
                Spacer()
            }

            ForEach(favoriteStore.fields) { field in
                Button {
                    locationService.calibration = field.toCalibration()
                    navigateToLiveMatch = true
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "sportscourt.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.primaryAccent)
                            .frame(width: 36, height: 36)
                            .background(Color.primaryAccent.opacity(0.12))
                            .cornerRadius(10)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(field.name)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.textPrimary)
                            Text(String(format: "%.0f x %.0f m", field.lengthMeters, field.widthMeters))
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.textSecondary)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.textTertiary)
                    }
                    .padding(12)
                    .background(Color.cardBackground)
                    .cornerRadius(12)
                }
                .contextMenu {
                    Button(role: .destructive) {
                        favoriteStore.delete(id: field.id)
                    } label: {
                        Label("삭제", systemImage: "trash")
                    }
                }
            }
        }
    }

    private func cornerRow(index: Int) -> some View {
        let isSet = index < locationService.calibration.corners.count
        let isCurrent = index == locationService.calibration.corners.count

        return HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(isSet ? Color.success.opacity(0.15) : Color.cardInner)
                    .frame(width: 36, height: 36)

                if isSet {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.success)
                } else {
                    Text("\(index + 1)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(isCurrent ? .primaryAccent : .textTertiary)
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(cornerLabels[index])
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(isSet ? .textPrimary : (isCurrent ? .textPrimary : .textTertiary))

                if isSet {
                    let corner = locationService.calibration.corners[index]
                    Text(String(format: "%.5f, %.5f", corner.latitude, corner.longitude))
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(.textSecondary)
                } else if isCurrent {
                    Text("해당 위치로 이동 후 캡처해주세요")
                        .font(.system(size: 11))
                        .foregroundColor(.textSecondary)
                }
            }

            Spacer()
        }
        .padding(14)
        .background(isCurrent ? Color.cardBackground : Color.clear)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isCurrent ? Color.primaryAccent.opacity(0.3) : Color.clear, lineWidth: 1)
        )
    }
}

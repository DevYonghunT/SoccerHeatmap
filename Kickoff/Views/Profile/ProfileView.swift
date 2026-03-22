import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var storageService: MatchStorageService
    @State private var playerName: String = UserDefaults.standard.string(forKey: "playerName") ?? ""
    @State private var backNumber: String = UserDefaults.standard.string(forKey: "backNumber") ?? ""
    @State private var position: String = UserDefaults.standard.string(forKey: "position") ?? "MF"
    @State private var maxHeartRate: String = UserDefaults.standard.string(forKey: "maxHeartRate") ?? "200"

    private let positions = ["GK", "DF", "MF", "FW"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Avatar with Jersey
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.primaryAccent.opacity(0.15))
                                .frame(width: 88, height: 88)

                            if !backNumber.isEmpty {
                                Text(backNumber)
                                    .font(.system(size: 36, weight: .black, design: .rounded))
                                    .foregroundColor(.primaryAccent)
                            } else {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 36))
                                    .foregroundColor(.primaryAccent)
                            }
                        }

                        if !playerName.isEmpty {
                            Text(playerName)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.textPrimary)
                        }

                        Text(positionLabel)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.textSecondary)
                    }
                    .padding(.top, 16)

                    // Stats Overview
                    HStack(spacing: 12) {
                        profileStatCard(value: "\(storageService.totalMatches)", label: "총 경기")
                        profileStatCard(value: "\(storageService.totalWins)", label: "승리")
                        profileStatCard(value: String(format: "%.0f%%", storageService.winRate), label: "승률")
                    }
                    .padding(.horizontal, 24)

                    // Settings
                    VStack(alignment: .leading, spacing: 16) {
                        Text("설정")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.textPrimary)

                        // Player Name
                        settingRow(title: "선수 이름") {
                            TextField("이름 입력", text: $playerName)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.textPrimary)
                                .multilineTextAlignment(.trailing)
                                .onChange(of: playerName) { newValue in
                                    UserDefaults.standard.set(newValue, forKey: "playerName")
                                }
                        }

                        // Back Number
                        settingRow(title: "등번호") {
                            TextField("번호", text: $backNumber)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.textPrimary)
                                .multilineTextAlignment(.trailing)
                                .keyboardType(.numberPad)
                                .frame(width: 60)
                                .onChange(of: backNumber) { newValue in
                                    UserDefaults.standard.set(newValue, forKey: "backNumber")
                                }
                        }

                        // Position
                        settingRow(title: "포지션") {
                            Picker("포지션", selection: $position) {
                                ForEach(positions, id: \.self) { pos in
                                    Text(pos).tag(pos)
                                }
                            }
                            .pickerStyle(.segmented)
                            .frame(width: 180)
                            .onChange(of: position) { newValue in
                                UserDefaults.standard.set(newValue, forKey: "position")
                            }
                        }

                        // Max Heart Rate
                        settingRow(title: "최대 심박수") {
                            TextField("200", text: $maxHeartRate)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.textPrimary)
                                .multilineTextAlignment(.trailing)
                                .keyboardType(.numberPad)
                                .frame(width: 60)
                                .onChange(of: maxHeartRate) { newValue in
                                    UserDefaults.standard.set(newValue, forKey: "maxHeartRate")
                                }
                        }
                    }
                    .padding(.horizontal, 24)

                    // App Info
                    VStack(spacing: 8) {
                        Text("KICKOFF")
                            .font(.system(size: 16, weight: .black, design: .rounded))
                            .foregroundColor(.primaryAccent)
                        Text("v1.0.0")
                            .font(.system(size: 12))
                            .foregroundColor(.textTertiary)
                        Text("Soccer Heatmap Tracker")
                            .font(.system(size: 12))
                            .foregroundColor(.textTertiary)
                    }
                    .padding(.top, 24)
                }
                .padding(.bottom, 24)
            }
            .background(Color.appBackground)
            .navigationTitle("프로필")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private var positionLabel: String {
        switch position {
        case "GK": return "골키퍼"
        case "DF": return "수비수"
        case "MF": return "미드필더"
        case "FW": return "공격수"
        default: return position
        }
    }

    private func profileStatCard(value: String, label: String) -> some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.textPrimary)
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(Color.cardBackground)
        .cornerRadius(14)
    }

    private func settingRow<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.textSecondary)
            Spacer()
            content()
        }
        .padding(16)
        .background(Color.cardBackground)
        .cornerRadius(12)
    }
}

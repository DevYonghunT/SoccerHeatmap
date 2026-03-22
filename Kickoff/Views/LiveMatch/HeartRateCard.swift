import SwiftUI

struct HeartRateCard: View {
    let currentBpm: Int
    let zone: HeartRateZone
    let history: [Int]

    private var zoneColor: Color {
        switch zone {
        case .zone1: return .zone1
        case .zone2: return .zone2
        case .zone3: return .zone3
        case .zone4: return .zone4
        case .zone5: return .zone5
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundColor(.primaryAccent)
                    .font(.system(size: 14))
                Text("심박수")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.textSecondary)
                Spacer()
                Text(zone.shortLabel)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(zoneColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(zoneColor.opacity(0.15))
                    .cornerRadius(6)
            }

            // BPM Display
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text("\(currentBpm)")
                    .font(.system(size: 48, weight: .black, design: .rounded))
                    .foregroundColor(.textPrimary)
                    .monospacedDigit()
                Text("bpm")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.textSecondary)
            }

            // Zone Label
            Text(zone.label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(zoneColor)

            // Mini Bar Chart
            if !history.isEmpty {
                heartRateChart
            }
        }
        .padding(18)
        .background(Color.cardBackground)
        .cornerRadius(20)
    }

    private var heartRateChart: some View {
        let recentHistory = Array(history.suffix(30))
        let maxBpm = Double(recentHistory.max() ?? 200)
        let minBpm = Double(max((recentHistory.min() ?? 60) - 20, 40))

        return GeometryReader { geo in
            HStack(alignment: .bottom, spacing: 2) {
                ForEach(0..<recentHistory.count, id: \.self) { i in
                    let bpm = Double(recentHistory[i])
                    let normalized = (bpm - minBpm) / max(maxBpm - minBpm, 1)
                    let height = max(normalized * geo.size.height, 4)

                    RoundedRectangle(cornerRadius: 2)
                        .fill(barColor(for: recentHistory[i]))
                        .frame(width: max((geo.size.width - CGFloat(recentHistory.count) * 2) / CGFloat(recentHistory.count), 3), height: height)
                }
            }
        }
        .frame(height: 50)
    }

    private func barColor(for bpm: Int) -> Color {
        let zone = HeartRateZone.from(bpm: bpm)
        switch zone {
        case .zone1: return .zone1
        case .zone2: return .zone2
        case .zone3: return .zone3
        case .zone4: return .zone4
        case .zone5: return .zone5
        }
    }
}

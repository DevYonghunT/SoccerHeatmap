import SwiftUI

struct AccentLabel: View {
    let text: String
    var color: Color = .primaryAccent

    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .bold))
            .foregroundColor(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(color.opacity(0.15))
            .cornerRadius(8)
    }
}

struct ResultBadge: View {
    let result: MatchResult

    var color: Color {
        switch result {
        case .win: return .primaryAccent
        case .lose: return .secondaryAccent
        case .draw: return .textSecondary
        }
    }

    var body: some View {
        AccentLabel(text: result.text, color: color)
    }
}

struct LiveBadge: View {
    let isRunning: Bool
    @State private var opacity: Double = 1.0

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(isRunning ? Color.primaryAccent : Color.warning)
                .frame(width: 6, height: 6)
                .opacity(opacity)
                .onAppear {
                    if isRunning {
                        withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                            opacity = 0.3
                        }
                    }
                }

            Text(isRunning ? "LIVE" : "PAUSED")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(isRunning ? .primaryAccent : .warning)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background((isRunning ? Color.primaryAccent : Color.warning).opacity(0.15))
        .cornerRadius(16)
    }
}

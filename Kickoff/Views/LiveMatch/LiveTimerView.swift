import SwiftUI

struct LiveTimerView: View {
    let formattedTime: String
    let halfLabel: String

    var body: some View {
        VStack(spacing: 8) {
            Text(halfLabel)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primaryAccent)

            Text(formattedTime)
                .font(.system(size: 64, weight: .black, design: .rounded))
                .foregroundColor(.textPrimary)
                .monospacedDigit()
        }
        .padding(.top, 16)
    }
}

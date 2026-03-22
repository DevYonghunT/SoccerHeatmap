import SwiftUI

extension Color {
    // MARK: - Background
    static let appBackground = Color(hex: 0x0D0F14)
    static let cardBackground = Color(hex: 0x161A23)
    static let cardInner = Color(hex: 0x1E2230)
    static let divider = Color(hex: 0x2A2E3A)

    // MARK: - Accent
    static let primaryAccent = Color(hex: 0xFF4A7C)
    static let secondaryAccent = Color(hex: 0x3B82F6)
    static let success = Color(hex: 0x32D74B)
    static let warning = Color(hex: 0xFF9500)

    // MARK: - Text
    static let textPrimary = Color.white
    static let textSecondary = Color(hex: 0x8A8A8A)
    static let textTertiary = Color(hex: 0x525252)

    // MARK: - Heatmap
    static let heatmapLow = Color(hex: 0x1E3A5F)
    static let heatmapMid = Color(hex: 0xFF9500)
    static let heatmapHigh = Color(hex: 0xFF4A7C)

    // MARK: - Field
    static let fieldGreen = Color(hex: 0x0A1A0A)
    static let fieldLine = Color(hex: 0x2A4A2A)

    // MARK: - Heart Rate Zones
    static let zone1 = Color(hex: 0x3B82F6)
    static let zone2 = Color(hex: 0x32D74B)
    static let zone3 = Color(hex: 0xFFD60A)
    static let zone4 = Color(hex: 0xFF9500)
    static let zone5 = Color(hex: 0xFF4A7C)

    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: alpha
        )
    }
}

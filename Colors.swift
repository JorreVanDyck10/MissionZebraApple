import SwiftUI

// MARK: - App Colors
extension Color {
    /// Primary brand colors
    static let missionBlue = Color(red: 0.2, green: 0.6, blue: 1.0)
    static let missionPurple = Color(red: 0.6, green: 0.3, blue: 1.0)
    static let missionGreen = Color(red: 0.2, green: 0.8, blue: 0.4)
    
    /// Semantic colors
    static let success = Color.green
    static let warning = Color.orange
    static let error = Color.red
    static let info = Color.blue
    
    /// Task status colors
    static let taskIncomplete = Color.gray
    static let taskPending = Color.orange
    static let taskCompleted = Color.green
    
    /// Reward status colors
    static let rewardAvailable = Color.blue
    static let rewardRequested = Color.orange
    static let rewardRedeemed = Color.green
    
    /// Background colors
    static let cardBackground = Color(.systemBackground)
    static let screenBackground = Color(.systemGroupedBackground)
    
    /// Zebra theme colors
    static let zebraStripe1 = Color.black
    static let zebraStripe2 = Color.white
    static let zebraAccent = Color(red: 1.0, green: 0.84, blue: 0.0) // Gold
}

// MARK: - Color Helpers
extension Color {
    /// Create color from hex string
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
import Foundation

/// Child model representing a child user in the MissionZebra app
struct Child: Identifiable, Codable {
    let id: String
    let name: String
    let points: Int
    let dailyScreenTimeUsedMinutes: Int
    let dailyScreenTimeLimitMinutes: Int
    let isBlocked: Bool
    
    let purchasedAccessoryIds: [String]
    let equippedAccessoryId: String?
    
    let streak: Int
    let lastStreakCheckDate: String? // "YYYY-MM-DD"
    
    let motivationalMessage: String?
    
    let screenTimeHistory: [String: TimeInterval] // Date string to seconds
    
    init(id: String = "",
         name: String = "",
         points: Int = 0,
         dailyScreenTimeUsedMinutes: Int = 0,
         dailyScreenTimeLimitMinutes: Int = 60,
         isBlocked: Bool = false,
         purchasedAccessoryIds: [String] = [],
         equippedAccessoryId: String? = nil,
         streak: Int = 0,
         lastStreakCheckDate: String? = nil,
         motivationalMessage: String? = nil,
         screenTimeHistory: [String: TimeInterval] = [:]) {
        self.id = id
        self.name = name
        self.points = points
        self.dailyScreenTimeUsedMinutes = dailyScreenTimeUsedMinutes
        self.dailyScreenTimeLimitMinutes = dailyScreenTimeLimitMinutes
        self.isBlocked = isBlocked
        self.purchasedAccessoryIds = purchasedAccessoryIds
        self.equippedAccessoryId = equippedAccessoryId
        self.streak = streak
        self.lastStreakCheckDate = lastStreakCheckDate
        self.motivationalMessage = motivationalMessage
        self.screenTimeHistory = screenTimeHistory
    }
}

// MARK: - Computed Properties
extension Child {
    /// Remaining screen time in minutes
    var remainingScreenTimeMinutes: Int {
        max(0, dailyScreenTimeLimitMinutes - dailyScreenTimeUsedMinutes)
    }
    
    /// Screen time usage percentage (0.0 to 1.0)
    var screenTimeUsagePercentage: Double {
        guard dailyScreenTimeLimitMinutes > 0 else { return 0.0 }
        return Double(dailyScreenTimeUsedMinutes) / Double(dailyScreenTimeLimitMinutes)
    }
    
    /// Whether the child has exceeded their screen time limit
    var hasExceededScreenTimeLimit: Bool {
        dailyScreenTimeUsedMinutes >= dailyScreenTimeLimitMinutes
    }
}
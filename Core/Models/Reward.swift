import Foundation

/// Reward model representing a reward that can be redeemed by a child
struct Reward: Identifiable, Codable {
    let id: String
    let title: String
    let costPoints: Int
    let childId: String?
    let redeemed: Bool
    let requested: Bool
    
    init(id: String = "",
         title: String = "",
         costPoints: Int = 0,
         childId: String? = nil,
         redeemed: Bool = false,
         requested: Bool = false) {
        self.id = id
        self.title = title
        self.costPoints = costPoints
        self.childId = childId
        self.redeemed = redeemed
        self.requested = requested
    }
}

// MARK: - Computed Properties
extension Reward {
    /// Reward status for display purposes
    var status: RewardStatus {
        if redeemed {
            return .redeemed
        } else if requested {
            return .requested
        } else {
            return .available
        }
    }
    
    /// Whether the reward can be requested
    var canBeRequested: Bool {
        !redeemed && !requested
    }
}

// MARK: - Reward Status Enum
enum RewardStatus: String, CaseIterable {
    case available = "available"
    case requested = "requested"
    case redeemed = "redeemed"
    
    var displayName: String {
        switch self {
        case .available:
            return "Beschikbaar"
        case .requested:
            return "Aangevraagd"
        case .redeemed:
            return "Ingewisseld"
        }
    }
    
    var systemImageName: String {
        switch self {
        case .available:
            return "gift"
        case .requested:
            return "clock"
        case .redeemed:
            return "checkmark.circle.fill"
        }
    }
}
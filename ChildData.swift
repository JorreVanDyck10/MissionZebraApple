import Foundation

/// Simplified child data model for basic child information
struct ChildData: Identifiable, Codable {
    let id: String
    let name: String
    let remainingMinutes: Int
    
    init(id: String = "",
         name: String = "",
         remainingMinutes: Int = 0) {
        self.id = id
        self.name = name
        self.remainingMinutes = remainingMinutes
    }
}

// MARK: - Computed Properties
extension ChildData {
    /// Formatted remaining time string
    var formattedRemainingTime: String {
        let hours = remainingMinutes / 60
        let minutes = remainingMinutes % 60
        
        if hours > 0 {
            return "\(hours)u \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}
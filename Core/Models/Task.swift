import Foundation

/// Task model representing a task that can be completed by a child
struct Task: Identifiable, Codable {
    let id: String
    let title: String
    let points: Int
    let childId: String?
    let childName: String?
    let parentId: String?
    let pendingApproval: Bool
    let completed: Bool
    
    init(id: String = "",
         title: String = "",
         points: Int = 0,
         childId: String? = nil,
         childName: String? = nil,
         parentId: String? = nil,
         pendingApproval: Bool = false,
         completed: Bool = false) {
        self.id = id
        self.title = title
        self.points = points
        self.childId = childId
        self.childName = childName
        self.parentId = parentId
        self.pendingApproval = pendingApproval
        self.completed = completed
    }
}

// MARK: - Computed Properties
extension Task {
    /// Task status for display purposes
    var status: TaskStatus {
        if completed {
            return .completed
        } else if pendingApproval {
            return .pendingApproval
        } else {
            return .incomplete
        }
    }
    
    /// Whether the task can be marked as done by a child
    var canBeMarkedAsDone: Bool {
        !completed && !pendingApproval
    }
}

// MARK: - Task Status Enum
enum TaskStatus: String, CaseIterable {
    case incomplete = "incomplete"
    case pendingApproval = "pendingApproval"
    case completed = "completed"
    
    var displayName: String {
        switch self {
        case .incomplete:
            return "Te doen"
        case .pendingApproval:
            return "Wacht op goedkeuring"
        case .completed:
            return "Voltooid"
        }
    }
    
    var systemImageName: String {
        switch self {
        case .incomplete:
            return "circle"
        case .pendingApproval:
            return "clock"
        case .completed:
            return "checkmark.circle.fill"
        }
    }
}
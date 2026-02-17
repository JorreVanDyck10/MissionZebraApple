import Foundation

/// API endpoints for Firebase/backend communication
struct APIEndpoints {
    private static let baseURL = "https://your-firebase-project.firebaseio.com"
    
    // MARK: - Children endpoints
    static func children() -> String {
        return "\(baseURL)/children.json"
    }
    
    static func child(id: String) -> String {
        return "\(baseURL)/children/\(id).json"
    }
    
    // MARK: - Tasks endpoints
    static func tasks() -> String {
        return "\(baseURL)/tasks.json"
    }
    
    static func task(id: String) -> String {
        return "\(baseURL)/tasks/\(id).json"
    }
    
    static func childTasks(childId: String) -> String {
        return "\(baseURL)/tasks.json?orderBy=\"childId\"&equalTo=\"\(childId)\""
    }
    
    // MARK: - Rewards endpoints
    static func rewards() -> String {
        return "\(baseURL)/rewards.json"
    }
    
    static func reward(id: String) -> String {
        return "\(baseURL)/rewards/\(id).json"
    }
    
    static func childRewards(childId: String) -> String {
        return "\(baseURL)/rewards.json?orderBy=\"childId\"&equalTo=\"\(childId)\""
    }
    
    // MARK: - Accessories endpoints (Zebra Shop)
    static func accessories() -> String {
        return "\(baseURL)/accessories.json"
    }
    
    static func accessory(id: String) -> String {
        return "\(baseURL)/accessories/\(id).json"
    }
    
    // MARK: - Screen time endpoints
    static func screenTime(childId: String) -> String {
        return "\(baseURL)/screenTime/\(childId).json"
    }
}

/// HTTP methods
enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case PATCH = "PATCH"
    case DELETE = "DELETE"
}
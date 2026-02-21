import Foundation

/// Session service for managing user authentication and session state
/// This replaces the Android SessionManager
class SessionService: ObservableObject {
    static let shared = SessionService()
    
    @Published var isLoggedIn = false
    @Published var currentUserType: UserType?
    @Published var currentChildId: String?
    @Published var currentChildName: String?
    
    private let userDefaults = UserDefaults.standard
    
    // UserDefaults keys
    private enum Keys {
        static let isLoggedIn = "isLoggedIn"
        static let userType = "userType"
        static let childId = "currentChildId"
        static let childName = "currentChildName"
    }
    
    private init() {
        loadSession()
    }
    
    // MARK: - Public Methods
    
    /// Get the start destination based on current session
    func getStartDestination() -> AppRoute {
        if isLoggedIn {
            switch currentUserType {
            case .parent:
                return .parentDashboard
            case .child:
                return .childDashboard
            case .none:
                return .welcome
            }
        } else {
            return .welcome
        }
    }
    
    /// Login as parent
    func loginAsParent() {
        isLoggedIn = true
        currentUserType = .parent
        saveSession()
    }
    
    /// Login as child
    func loginAsChild(childId: String, childName: String) {
        isLoggedIn = true
        currentUserType = .child
        currentChildId = childId
        currentChildName = childName
        saveSession()
    }
    
    /// Logout current user
    func logout() {
        isLoggedIn = false
        currentUserType = nil
        currentChildId = nil
        currentChildName = nil
        clearSession()
    }
    
    /// Check if user is logged in as parent
    var isParentLoggedIn: Bool {
        isLoggedIn && currentUserType == .parent
    }
    
    /// Check if user is logged in as child
    var isChildLoggedIn: Bool {
        isLoggedIn && currentUserType == .child
    }
    
    // MARK: - Private Methods
    
    private func loadSession() {
        isLoggedIn = userDefaults.bool(forKey: Keys.isLoggedIn)
        
        if let userTypeRaw = userDefaults.string(forKey: Keys.userType),
           let userType = UserType(rawValue: userTypeRaw) {
            currentUserType = userType
        }
        
        currentChildId = userDefaults.string(forKey: Keys.childId)
        currentChildName = userDefaults.string(forKey: Keys.childName)
    }
    
    private func saveSession() {
        userDefaults.set(isLoggedIn, forKey: Keys.isLoggedIn)
        userDefaults.set(currentUserType?.rawValue, forKey: Keys.userType)
        userDefaults.set(currentChildId, forKey: Keys.childId)
        userDefaults.set(currentChildName, forKey: Keys.childName)
    }
    
    private func clearSession() {
        userDefaults.removeObject(forKey: Keys.isLoggedIn)
        userDefaults.removeObject(forKey: Keys.userType)
        userDefaults.removeObject(forKey: Keys.childId)
        userDefaults.removeObject(forKey: Keys.childName)
    }
}

// MARK: - User Type Enum
enum UserType: String, CaseIterable {
    case parent = "parent"
    case child = "child"
    
    var displayName: String {
        switch self {
        case .parent:
            return "Ouder"
        case .child:
            return "Kind"
        }
    }
}
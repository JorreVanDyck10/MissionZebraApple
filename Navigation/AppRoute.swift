import Foundation

/// Route definitions for app navigation
enum AppRoute: String, CaseIterable {
    case welcome
    case parentLogin
    case childLogin
    case deviceMode
    case parentDashboard
    case childDashboard
    case parentPremiumDashboard
    case parentScreenTimeControl
    case privacyPolicy
    case parentOnlineSafety
    case taskCalendar
    
    var title: String {
        switch self {
        case .welcome:
            return "Welkom"
        case .parentLogin:
            return "Ouder Inloggen"
        case .childLogin:
            return "Kind Inloggen"
        case .deviceMode:
            return "Apparaat Instellen"
        case .parentDashboard:
            return "Ouder Dashboard"
        case .childDashboard:
            return "Kind Dashboard"
        case .parentPremiumDashboard:
            return "Premium Dashboard"
        case .parentScreenTimeControl:
            return "Schermtijd Controle"
        case .privacyPolicy:
            return "Privacy Beleid"
        case .parentOnlineSafety:
            return "Online Veiligheid"
        case .taskCalendar:
            return "Takenkalender"
        }
    }
}

/// Navigation data for parameterized routes
struct NavigationData {
    let childId: String?
    let childName: String?
    
    init(childId: String? = nil, childName: String? = nil) {
        self.childId = childId
        self.childName = childName
    }
}
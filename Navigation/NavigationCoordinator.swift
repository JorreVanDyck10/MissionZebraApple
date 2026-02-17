import SwiftUI
import Combine

/// Navigation coordinator for managing app navigation state
/// Compatible with iOS 15 - uses NavigationView instead of NavigationStack
class NavigationCoordinator: ObservableObject {
    @Published var currentRoute: AppRoute = .welcome
    @Published var navigationData = NavigationData()
    @Published var navigationPath: [AppRoute] = []
    
    // MARK: - Navigation Methods
    
    /// Navigate to a specific route
    func navigate(to route: AppRoute, with data: NavigationData = NavigationData()) {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentRoute = route
            navigationData = data
            
            // Add to navigation path if not already present
            if let lastRoute = navigationPath.last, lastRoute != route {
                navigationPath.append(route)
            } else if navigationPath.isEmpty {
                navigationPath.append(route)
            }
        }
    }
    
    /// Navigate back to previous route
    func navigateBack() {
        guard navigationPath.count > 1 else { return }
        
        withAnimation(.easeInOut(duration: 0.3)) {
            navigationPath.removeLast()
            if let previousRoute = navigationPath.last {
                currentRoute = previousRoute
            }
        }
    }
    
    /// Navigate to root (welcome screen)
    func navigateToRoot() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentRoute = .welcome
            navigationData = NavigationData()
            navigationPath = [.welcome]
        }
    }
    
    /// Navigate to child dashboard with specific child data
    func navigateToChildDashboard(childId: String, childName: String) {
        let data = NavigationData(childId: childId, childName: childName)
        navigate(to: .childDashboard, with: data)
    }
    
    /// Check if can navigate back
    var canNavigateBack: Bool {
        navigationPath.count > 1
    }
    
    /// Get the start destination based on session state
    func getStartDestination() -> AppRoute {
        // In a real app, this would check for saved session/login state
        // For now, always start at welcome screen
        return .welcome
    }
    
    // MARK: - Session Management Integration
    
    /// Initialize navigation with start destination
    func initializeNavigation() {
        let startDestination = getStartDestination()
        currentRoute = startDestination
        navigationPath = [startDestination]
    }
    
    /// Handle logout - return to welcome screen
    func handleLogout() {
        navigateToRoot()
        // In a real app, you would also clear session data here
    }
    
    /// Handle deep link navigation
    func handleDeepLink(_ url: URL) {
        // Parse URL and navigate to appropriate route
        // This is a simplified implementation
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let scheme = components.scheme,
              scheme == "missionzebra" else { return }
        
        switch components.host {
        case "child":
            if let childId = components.queryItems?.first(where: { $0.name == "id" })?.value,
               let childName = components.queryItems?.first(where: { $0.name == "name" })?.value {
                navigateToChildDashboard(childId: childId, childName: childName)
            }
        case "parent":
            navigate(to: .parentDashboard)
        default:
            navigateToRoot()
        }
    }
}

// MARK: - Navigation Helper View
/// A helper view to handle navigation logic in SwiftUI
struct NavigationHandler: View {
    @ObservedObject var coordinator: NavigationCoordinator
    
    var body: some View {
        NavigationView {
            destinationView
                .onAppear {
                    coordinator.initializeNavigation()
                }
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Force stack style for iOS 15
    }
    
    @ViewBuilder
    private var destinationView: some View {
        switch coordinator.currentRoute {
        case .welcome:
            WelcomeView()
        
        case .childLogin:
            ChildLoginView()
        
        case .childDashboard:
            if let childId = coordinator.navigationData.childId,
               let childName = coordinator.navigationData.childName {
                ChildDashboardView(childId: childId, childName: childName)
            } else {
                // Fallback if data is missing
                WelcomeView()
            }
        
        case .parentLogin:
            ParentLoginView()
        
        case .parentDashboard:
            ParentDashboardView()
        
        case .deviceMode:
            DeviceModeView()
        
        // Add other routes as needed
        default:
            WelcomeView()
        }
    }
}

// MARK: - Placeholder Views (to be implemented)
struct ChildLoginView: View {
    var body: some View {
        Text("Child Login View")
            .navigationTitle("Kind Inloggen")
    }
}

struct ParentLoginView: View {
    var body: some View {
        Text("Parent Login View")
            .navigationTitle("Ouder Inloggen")
    }
}

struct ParentDashboardView: View {
    var body: some View {
        Text("Parent Dashboard View")
            .navigationTitle("Ouder Dashboard")
    }
}

struct DeviceModeView: View {
    var body: some View {
        Text("Device Mode View")
            .navigationTitle("Apparaat Instellen")
    }
}
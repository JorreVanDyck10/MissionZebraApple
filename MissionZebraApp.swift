import SwiftUI

/// Main app entry point for MissionZebra iOS app
@main
struct MissionZebraApp: App {
    @StateObject private var navigationCoordinator = NavigationCoordinator()
    
    var body: some Scene {
        WindowGroup {
            NavigationHandler(coordinator: navigationCoordinator)
                .environmentObject(navigationCoordinator)
                .preferredColorScheme(.light) // Force light mode for consistency
        }
    }
}
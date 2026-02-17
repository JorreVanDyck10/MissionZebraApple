import Foundation
import Combine

/// ViewModel for the Welcome screen
class WelcomeViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var shouldNavigateToParentLogin = false
    @Published var shouldNavigateToChildLogin = false
    @Published var shouldNavigateToDeviceMode = false
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init() {
        setupBindings()
    }
    
    // MARK: - Public Methods
    
    /// Handle parent login button tap
    func parentLoginTapped() {
        withAnimation {
            shouldNavigateToParentLogin = true
        }
    }
    
    /// Handle child login button tap
    func childLoginTapped() {
        withAnimation {
            shouldNavigateToChildLogin = true
        }
    }
    
    /// Handle device mode button tap
    func deviceModeTapped() {
        withAnimation {
            shouldNavigateToDeviceMode = true
        }
    }
    
    /// Reset navigation flags
    func resetNavigation() {
        shouldNavigateToParentLogin = false
        shouldNavigateToChildLogin = false
        shouldNavigateToDeviceMode = false
    }
    
    /// Clear error message
    func clearError() {
        errorMessage = nil
    }
    
    // MARK: - Private Methods
    
    private func setupBindings() {
        // Any initial setup or data loading can go here
    }
}
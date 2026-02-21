import SwiftUI

/// Welcome screen for MissionZebra app
struct WelcomeView: View {
    @StateObject private var viewModel = WelcomeViewModel()
    @State private var titleOpacity: Double = 0
    @State private var titleScale: CGFloat = 0.8
    @State private var textOffset: CGFloat = 50
    @State private var buttonOffset: CGFloat = 50
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Spacer()
                    
                    // App Title
                    VStack(spacing: 8) {
                        Text("🦓")
                            .font(.system(size: 80))
                            .scaleEffect(titleScale)
                            .opacity(titleOpacity)
                        
                        Text("Welkom bij MissionZebra")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .opacity(titleOpacity)
                            .scaleEffect(titleScale)
                    }
                    
                    Spacer()
                    
                    // Description Text
                    Text("Beheer schermtijd, voltooi missies en verdien beloningen!")
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                        .offset(y: textOffset)
                        .opacity(titleOpacity)
                    
                    Spacer()
                    
                    // Buttons
                    VStack(spacing: 16) {
                        // Parent Button
                        Button(action: {
                            viewModel.parentLoginTapped()
                        }) {
                            HStack {
                                Image(systemName: "person.2.fill")
                                    .font(.title2)
                                Text("Ik ben een ouder")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.blue)
                            )
                            .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Child Button
                        Button(action: {
                            viewModel.childLoginTapped()
                        }) {
                            HStack {
                                Image(systemName: "face.smiling.fill")
                                    .font(.title2)
                                Text("Ik ben een kind")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.green)
                            )
                            .shadow(color: Color.green.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Device Mode Button
                        Button(action: {
                            viewModel.deviceModeTapped()
                        }) {
                            HStack {
                                Image(systemName: "ipad.and.iphone")
                                    .font(.title2)
                                Text("Apparaat instellen")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.primary.opacity(0.3), lineWidth: 2)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color(.systemBackground))
                                    )
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal, 32)
                    .offset(y: buttonOffset)
                    .opacity(titleOpacity)
                    
                    Spacer()
                }
                .padding()
                
                // Loading Overlay
                if viewModel.isLoading {
                    ZStack {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                        
                        ProgressView()
                            .scaleEffect(1.5)
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                startAnimations()
            }
            .alert("Fout", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.clearError()
                }
            } message: {
                if let error = viewModel.errorMessage {
                    Text(error)
                }
            }
            
            // Navigation - Note: In a real app, you would handle navigation differently
            // This is a simplified version for demonstration
            .onReceive(viewModel.$shouldNavigateToParentLogin) { shouldNavigate in
                if shouldNavigate {
                    // Handle navigation to parent login
                    viewModel.resetNavigation()
                }
            }
            .onReceive(viewModel.$shouldNavigateToChildLogin) { shouldNavigate in
                if shouldNavigate {
                    // Handle navigation to child login
                    viewModel.resetNavigation()
                }
            }
            .onReceive(viewModel.$shouldNavigateToDeviceMode) { shouldNavigate in
                if shouldNavigate {
                    // Handle navigation to device mode
                    viewModel.resetNavigation()
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Force stack style for iOS 15
    }
    
    // MARK: - Private Methods
    
    private func startAnimations() {
        // Title animation
        withAnimation(.easeOut(duration: 0.8)) {
            titleOpacity = 1.0
            titleScale = 1.0
        }
        
        // Text animation with delay
        withAnimation(.easeOut(duration: 0.6).delay(0.3)) {
            textOffset = 0
        }
        
        // Button animation with delay
        withAnimation(.easeOut(duration: 0.6).delay(0.5)) {
            buttonOffset = 0
        }
    }
}

// MARK: - Preview
struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
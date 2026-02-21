import SwiftUI

// MARK: - View Extensions
extension View {
    /// Apply card style with shadow and corner radius
    func cardStyle(backgroundColor: Color = Color.cardBackground, 
                   cornerRadius: CGFloat = 12,
                   shadowRadius: CGFloat = 2) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(backgroundColor)
                    .shadow(color: Color.black.opacity(0.1), radius: shadowRadius, x: 0, y: 1)
            )
    }
    
    /// Apply zebra-themed styling
    func zebraStyle() -> some View {
        self
            .foregroundColor(.primary)
            .font(.zebraBody)
    }
    
    /// Apply primary button style
    func primaryButtonStyle(backgroundColor: Color = .missionBlue) -> some View {
        self
            .font(AppTextStyles.buttonMedium)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(backgroundColor)
            )
    }
    
    /// Apply secondary button style
    func secondaryButtonStyle(borderColor: Color = .missionBlue) -> some View {
        self
            .font(AppTextStyles.buttonMedium)
            .foregroundColor(borderColor)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: 2)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemBackground))
                    )
            )
    }
    
    /// Apply loading overlay
    func loadingOverlay(isLoading: Bool, message: String = "Laden...") -> some View {
        self
            .overlay(
                Group {
                    if isLoading {
                        ZStack {
                            Color.black.opacity(0.3)
                                .ignoresSafeArea()
                            
                            VStack(spacing: 16) {
                                ProgressView()
                                    .scaleEffect(1.5)
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                
                                Text(message)
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
            )
    }
    
    /// Apply error alert modifier
    func errorAlert(error: Binding<String?>) -> some View {
        self
            .alert("Fout", isPresented: .constant(error.wrappedValue != nil)) {
                Button("OK") {
                    error.wrappedValue = nil
                }
            } message: {
                if let errorMessage = error.wrappedValue {
                    Text(errorMessage)
                }
            }
    }
    
    /// Apply animated scale effect on tap
    func bounceOnTap() -> some View {
        self
            .scaleEffect(1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: UUID())
    }
    
    /// Apply gradient background
    func gradientBackground(colors: [Color] = [Color.missionBlue.opacity(0.1), Color.missionPurple.opacity(0.1)]) -> some View {
        self
            .background(
                LinearGradient(
                    gradient: Gradient(colors: colors),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
    }
    
    /// Apply points badge styling
    func pointsBadge(points: Int, color: Color = .zebraAccent) -> some View {
        self
            .overlay(
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundColor(color)
                    
                    Text("\(points)")
                        .font(.pointsSmall)
                        .foregroundColor(.primary)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(color.opacity(0.2))
                ),
                alignment: .topTrailing
            )
    }
}

// MARK: - Animation Extensions
extension View {
    /// Fade in animation
    func fadeIn(duration: Double = 0.6, delay: Double = 0) -> some View {
        self
            .opacity(0)
            .onAppear {
                withAnimation(.easeIn(duration: duration).delay(delay)) {
                    // The opacity will be handled by the calling view
                }
            }
    }
    
    /// Slide in from bottom animation
    func slideInFromBottom(duration: Double = 0.5, delay: Double = 0) -> some View {
        self
            .offset(y: 50)
            .onAppear {
                withAnimation(.easeOut(duration: duration).delay(delay)) {
                    // The offset will be handled by the calling view
                }
            }
    }
    
    /// Scale in animation
    func scaleIn(duration: Double = 0.6, delay: Double = 0) -> some View {
        self
            .scaleEffect(0.8)
            .onAppear {
                withAnimation(.easeOut(duration: duration).delay(delay)) {
                    // The scale will be handled by the calling view
                }
            }
    }
}

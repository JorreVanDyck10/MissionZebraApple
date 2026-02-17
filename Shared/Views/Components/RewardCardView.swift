import SwiftUI

/// Reward card component for displaying individual rewards
struct RewardCardView: View {
    let reward: Reward
    let childPoints: Int
    let onRequest: () -> Void
    
    @State private var isAnimating = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Reward Header
            HStack {
                Text(reward.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                Spacer()
                
                // Status Badge
                HStack(spacing: 4) {
                    Image(systemName: reward.status.systemImageName)
                        .font(.caption)
                        .foregroundColor(statusColor)
                    
                    Text(reward.status.displayName)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(statusColor)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(statusColor.opacity(0.2))
                )
            }
            
            // Cost and Action
            HStack {
                // Cost Badge
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundColor(.yellow)
                    
                    Text("\(reward.costPoints)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text("punten")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.yellow.opacity(0.2))
                )
                
                Spacer()
                
                // Request Button
                if reward.canBeRequested {
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            isAnimating = true
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            onRequest()
                            isAnimating = false
                        }
                    }) {
                        Text(canAfford ? "Inwisselen" : "Te duur")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(canAfford ? Color.blue : Color.gray)
                            )
                            .scaleEffect(isAnimating ? 1.1 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isAnimating)
                    }
                    .disabled(!canAfford)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(borderColor, lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    // MARK: - Computed Properties
    
    private var canAfford: Bool {
        childPoints >= reward.costPoints
    }
    
    private var statusColor: Color {
        switch reward.status {
        case .available:
            return .blue
        case .requested:
            return .orange
        case .redeemed:
            return .green
        }
    }
    
    private var backgroundColor: Color {
        switch reward.status {
        case .available:
            return Color(.systemBackground)
        case .requested:
            return Color.orange.opacity(0.1)
        case .redeemed:
            return Color.green.opacity(0.1)
        }
    }
    
    private var borderColor: Color {
        switch reward.status {
        case .available:
            return Color.gray.opacity(0.2)
        case .requested:
            return Color.orange.opacity(0.3)
        case .redeemed:
            return Color.green.opacity(0.3)
        }
    }
}

// MARK: - Preview
struct RewardCardView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            RewardCardView(
                reward: Reward(
                    id: "1",
                    title: "Extra schermtijd (30 min)",
                    costPoints: 50,
                    childId: "child1"
                ),
                childPoints: 75,
                onRequest: {}
            )
            
            RewardCardView(
                reward: Reward(
                    id: "2",
                    title: "Uitje naar de bioscoop",
                    costPoints: 100,
                    childId: "child1",
                    requested: true
                ),
                childPoints: 75,
                onRequest: {}
            )
            
            RewardCardView(
                reward: Reward(
                    id: "3",
                    title: "Nieuwe game",
                    costPoints: 200,
                    childId: "child1",
                    redeemed: true
                ),
                childPoints: 75,
                onRequest: {}
            )
        }
        .padding()
    }
}
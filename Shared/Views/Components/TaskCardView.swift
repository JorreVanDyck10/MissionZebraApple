import SwiftUI

/// Task card component for displaying individual tasks
struct TaskCardView: View {
    let task: Task
    let onComplete: () -> Void
    
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Task Status Icon
            Button(action: {
                if task.canBeMarkedAsDone {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isAnimating = true
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        onComplete()
                        isAnimating = false
                    }
                }
            }) {
                Image(systemName: task.status.systemImageName)
                    .font(.title2)
                    .foregroundColor(statusColor)
                    .scaleEffect(isAnimating ? 1.2 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isAnimating)
            }
            .disabled(!task.canBeMarkedAsDone)
            
            // Task Details
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                HStack {
                    Text(task.status.displayName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    // Points Badge
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(.yellow)
                        
                        Text("\(task.points)")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.yellow.opacity(0.2))
                    )
                }
            }
            
            Spacer()
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
    
    private var statusColor: Color {
        switch task.status {
        case .incomplete:
            return .gray
        case .pendingApproval:
            return .orange
        case .completed:
            return .green
        }
    }
    
    private var backgroundColor: Color {
        switch task.status {
        case .incomplete:
            return Color(.systemBackground)
        case .pendingApproval:
            return Color.orange.opacity(0.1)
        case .completed:
            return Color.green.opacity(0.1)
        }
    }
    
    private var borderColor: Color {
        switch task.status {
        case .incomplete:
            return Color.gray.opacity(0.2)
        case .pendingApproval:
            return Color.orange.opacity(0.3)
        case .completed:
            return Color.green.opacity(0.3)
        }
    }
}

// MARK: - Preview
struct TaskCardView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            TaskCardView(
                task: Task(
                    id: "1",
                    title: "Kamer opruimen",
                    points: 10,
                    childId: "child1",
                    completed: false
                ),
                onComplete: {}
            )
            
            TaskCardView(
                task: Task(
                    id: "2",
                    title: "Huiswerk maken",
                    points: 15,
                    childId: "child1",
                    pendingApproval: true,
                    completed: false
                ),
                onComplete: {}
            )
            
            TaskCardView(
                task: Task(
                    id: "3",
                    title: "Afwas doen",
                    points: 20,
                    childId: "child1",
                    completed: true
                ),
                onComplete: {}
            )
        }
        .padding()
    }
}
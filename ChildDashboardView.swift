import SwiftUI

/// Child dashboard screen showing tasks, rewards, screen time, and zebra character
struct ChildDashboardView: View {
    let childId: String
    let childName: String
    
    @StateObject private var viewModel: ChildDashboardViewModel
    @State private var selectedTab = 0
    @State private var zebraScale: CGFloat = 1.0
    @State private var showingFocusAlert = false
    
    init(childId: String, childName: String) {
        self.childId = childId
        self.childName = childName
        self._viewModel = StateObject(wrappedValue: ChildDashboardViewModel(childId: childId, childName: childName))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.05), Color.purple.opacity(0.05)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                if viewModel.uiState.isLoading {
                    LoadingView(message: "Dashboard laden...")
                } else {
                    mainContent
                }
                
                // Focus Mode Overlay
                if viewModel.uiState.isFocusModeActive {
                    focusModeOverlay
                }
            }
            .navigationTitle("Hallo \(childName)! 🦓")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarHidden(viewModel.uiState.isFocusModeActive)
            .refreshable {
                viewModel.refresh()
            }
            .alert("Fout", isPresented: .constant(viewModel.uiState.error != nil)) {
                Button("OK") {
                    viewModel.clearError()
                }
            } message: {
                if let error = viewModel.uiState.error {
                    Text(error)
                }
            }
            .alert("Focus Modus", isPresented: $showingFocusAlert) {
                Button("Annuleren", role: .cancel) { }
                Button("Start Focus") {
                    viewModel.startFocusMode()
                }
            } message: {
                Text("Start focus modus om punten te verdienen door je concentratie te behouden!")
            }
            .sheet(isPresented: .constant(viewModel.uiState.isShopOpen)) {
                ZebraShopView(
                    childId: childId,
                    childPoints: viewModel.uiState.child?.points ?? 0,
                    onDismiss: {
                        viewModel.closeShop()
                    }
                )
            }
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Force stack style for iOS 15
    }
    
    // MARK: - Main Content
    
    private var mainContent: some View {
        VStack(spacing: 0) {
            // Header with zebra and stats
            headerView
            
            // Tab Selection
            Picker("Sectie", selection: $selectedTab) {
                Text("Taken").tag(0)
                Text("Beloningen").tag(1)
                Text("Statistieken").tag(2)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            .padding(.bottom)
            
            // Tab Content
            TabView(selection: $selectedTab) {
                tasksView.tag(0)
                rewardsView.tag(1)
                statsView.tag(2)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        }
    }
    
    // MARK: - Header View
    
    private var headerView: some View {
        VStack(spacing: 16) {
            HStack {
                // Zebra Character
                VStack {
                    Text("🦓")
                        .font(.system(size: 60))
                        .scaleEffect(zebraScale)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                zebraScale = 1.2
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    zebraScale = 1.0
                                }
                            }
                        }
                    
                    if let accessoryId = viewModel.uiState.child?.equippedAccessoryId {
                        Text("👑") // Placeholder for equipped accessory
                            .font(.title)
                            .offset(y: -40)
                    }
                }
                
                Spacer()
                
                // Stats
                VStack(alignment: .trailing, spacing: 8) {
                    // Points
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("\(viewModel.uiState.child?.points ?? 0)")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("punten")
                            .foregroundColor(.secondary)
                    }
                    
                    // Streak
                    if viewModel.uiState.streak > 0 {
                        HStack {
                            Image(systemName: "flame.fill")
                                .foregroundColor(.orange)
                            Text("\(viewModel.uiState.streak)")
                                .font(.title3)
                                .fontWeight(.semibold)
                            Text("dagen")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Screen Time
                    if let child = viewModel.uiState.child {
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundColor(.blue)
                            Text("\(child.remainingScreenTimeMinutes)m")
                                .font(.title3)
                                .fontWeight(.semibold)
                            Text("over")
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .padding(.horizontal)
            
            // Action Buttons
            HStack(spacing: 16) {
                // Focus Mode Button
                Button(action: {
                    showingFocusAlert = true
                }) {
                    HStack {
                        Image(systemName: "brain.head.profile")
                        Text("Focus")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.purple)
                    )
                }
                
                // Shop Button
                Button(action: {
                    viewModel.openShop()
                }) {
                    HStack {
                        Image(systemName: "bag.fill")
                        Text("Winkel")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.green)
                    )
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
        .padding()
    }
    
    // MARK: - Tasks View
    
    private var tasksView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if viewModel.uiState.tasks.isEmpty {
                    emptyTasksView
                } else {
                    ForEach(viewModel.uiState.tasks) { task in
                        TaskCardView(task: task) {
                            viewModel.completeTask(taskId: task.id)
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var emptyTasksView: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 60))
                .foregroundColor(.green)
            
            Text("Geen taken beschikbaar")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Alle taken zijn voltooid! Geweldig werk!")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .frame(minHeight: 200)
    }
    
    // MARK: - Rewards View
    
    private var rewardsView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if viewModel.uiState.rewards.isEmpty {
                    emptyRewardsView
                } else {
                    ForEach(viewModel.uiState.rewards) { reward in
                        RewardCardView(
                            reward: reward,
                            childPoints: viewModel.uiState.child?.points ?? 0
                        ) {
                            viewModel.requestReward(rewardId: reward.id)
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var emptyRewardsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "gift")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("Geen beloningen beschikbaar")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Voltooi taken om beloningen te verdienen!")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .frame(minHeight: 200)
    }
    
    // MARK: - Stats View
    
    private var statsView: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Screen Time Card
                if let child = viewModel.uiState.child {
                    screenTimeCard(for: child)
                }
                
                // Achievement Cards
                achievementCards
            }
            .padding(.horizontal)
        }
    }
    
    private func screenTimeCard(for child: Child) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Schermtijd vandaag")
                .font(.headline)
                .fontWeight(.semibold)
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 12)
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(child.hasExceededScreenTimeLimit ? Color.red : Color.blue)
                        .frame(width: geometry.size.width * min(child.screenTimeUsagePercentage, 1.0), height: 12)
                        .animation(.easeInOut, value: child.screenTimeUsagePercentage)
                }
            }
            .frame(height: 12)
            
            HStack {
                Text("\(child.dailyScreenTimeUsedMinutes) min gebruikt")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(child.dailyScreenTimeLimitMinutes) min limiet")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
    }
    
    private var achievementCards: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "trophy.fill")
                    .foregroundColor(.gold)
                Text("Prestaties")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            // Streak Achievement
            achievementCard(
                icon: "flame.fill",
                title: "Streak Meester",
                description: "\(viewModel.uiState.streak) dagen op rij actief",
                color: .orange
            )
            
            // Points Achievement
            achievementCard(
                icon: "star.fill",
                title: "Punten Verzamelaar",
                description: "\(viewModel.uiState.child?.points ?? 0) punten verzameld",
                color: .yellow
            )
        }
    }
    
    private func achievementCard(icon: String, title: String, description: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
    }
    
    // MARK: - Focus Mode Overlay
    
    private var focusModeOverlay: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Text("🧠")
                    .font(.system(size: 80))
                
                Text("Focus Modus Actief")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Blijf gefocust om punten te verdienen!")
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                
                if let startTime = viewModel.uiState.focusStartTime {
                    FocusTimerView(startTime: startTime)
                }
                
                Button("Stop Focus") {
                    viewModel.endFocusMode()
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.red)
                )
            }
            .padding()
        }
    }
}

// MARK: - Focus Timer View
struct FocusTimerView: View {
    let startTime: Date
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Focustijd")
                .font(.headline)
                .foregroundColor(.white.opacity(0.8))
            
            Text(formattedTime)
                .font(.system(size: 48, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
        }
        .onAppear {
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private var formattedTime: String {
        let minutes = Int(elapsedTime) / 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            elapsedTime = Date().timeIntervalSince(startTime)
        }
    }
}

// MARK: - Color Extension
extension Color {
    static let gold = Color(red: 1.0, green: 0.84, blue: 0.0)
}

// MARK: - Preview
struct ChildDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        ChildDashboardView(childId: "child1", childName: "Emma")
    }
}
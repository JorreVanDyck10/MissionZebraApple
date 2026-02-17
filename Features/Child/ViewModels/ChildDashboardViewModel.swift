import Foundation
import Combine

/// UI state for the Child Dashboard
struct ChildDashboardUiState {
    let child: Child?
    let tasks: [Task]
    let rewards: [Reward]
    let isLoading: Bool
    let error: String?
    let showScreenTimeDialog: Bool
    let needsUsagePermission: Bool
    let isFocusModeActive: Bool
    let focusStartTime: Date?
    let startScreenTimeMinutes: Int
    let focusSessionEarnedPoints: Int?
    let isShopOpen: Bool
    let streak: Int
    
    init(child: Child? = nil,
         tasks: [Task] = [],
         rewards: [Reward] = [],
         isLoading: Bool = true,
         error: String? = nil,
         showScreenTimeDialog: Bool = true,
         needsUsagePermission: Bool = false,
         isFocusModeActive: Bool = false,
         focusStartTime: Date? = nil,
         startScreenTimeMinutes: Int = 0,
         focusSessionEarnedPoints: Int? = nil,
         isShopOpen: Bool = false,
         streak: Int = 0) {
        self.child = child
        self.tasks = tasks
        self.rewards = rewards
        self.isLoading = isLoading
        self.error = error
        self.showScreenTimeDialog = showScreenTimeDialog
        self.needsUsagePermission = needsUsagePermission
        self.isFocusModeActive = isFocusModeActive
        self.focusStartTime = focusStartTime
        self.startScreenTimeMinutes = startScreenTimeMinutes
        self.focusSessionEarnedPoints = focusSessionEarnedPoints
        self.isShopOpen = isShopOpen
        self.streak = streak
    }
}

/// ViewModel for the Child Dashboard screen
class ChildDashboardViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var uiState = ChildDashboardUiState()
    
    // MARK: - Private Properties
    private let childId: String
    private let childName: String
    
    private let childRepository = ChildRepository()
    private let taskRepository = TaskRepository()
    private let rewardRepository = RewardRepository()
    
    private var cancellables = Set<AnyCancellable>()
    private var focusTimer: Timer?
    
    // MARK: - Initialization
    init(childId: String, childName: String) {
        self.childId = childId
        self.childName = childName
        
        setupBindings()
        loadData()
    }
    
    deinit {
        focusTimer?.invalidate()
    }
    
    // MARK: - Public Methods
    
    /// Refresh all data
    func refresh() {
        loadData()
    }
    
    /// Complete a task
    func completeTask(taskId: String) {
        taskRepository.completeTask(taskId: taskId, childId: childId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    // Play sound effect if available
                    self?.playTaskCompletionSound()
                    // Refresh data to show updated task status
                    self?.loadData()
                case .failure(let error):
                    self?.updateUiState { state in
                        ChildDashboardUiState(
                            child: state.child,
                            tasks: state.tasks,
                            rewards: state.rewards,
                            isLoading: false,
                            error: error.localizedDescription,
                            showScreenTimeDialog: state.showScreenTimeDialog,
                            needsUsagePermission: state.needsUsagePermission,
                            isFocusModeActive: state.isFocusModeActive,
                            focusStartTime: state.focusStartTime,
                            startScreenTimeMinutes: state.startScreenTimeMinutes,
                            focusSessionEarnedPoints: state.focusSessionEarnedPoints,
                            isShopOpen: state.isShopOpen,
                            streak: state.streak
                        )
                    }
                }
            }
        }
    }
    
    /// Request a reward
    func requestReward(rewardId: String) {
        guard let child = uiState.child,
              let reward = uiState.rewards.first(where: { $0.id == rewardId }),
              child.points >= reward.costPoints else {
            updateUiState { state in
                ChildDashboardUiState(
                    child: state.child,
                    tasks: state.tasks,
                    rewards: state.rewards,
                    isLoading: false,
                    error: "Niet genoeg punten voor deze beloning",
                    showScreenTimeDialog: state.showScreenTimeDialog,
                    needsUsagePermission: state.needsUsagePermission,
                    isFocusModeActive: state.isFocusModeActive,
                    focusStartTime: state.focusStartTime,
                    startScreenTimeMinutes: state.startScreenTimeMinutes,
                    focusSessionEarnedPoints: state.focusSessionEarnedPoints,
                    isShopOpen: state.isShopOpen,
                    streak: state.streak
                )
            }
            return
        }
        
        rewardRepository.requestReward(rewardId: rewardId, childId: childId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    // Deduct points from child
                    self?.childRepository.updatePoints(childId: self?.childId ?? "", points: child.points - reward.costPoints) { _ in
                        // Refresh data regardless of points update result
                        self?.loadData()
                    }
                case .failure(let error):
                    self?.updateUiState { state in
                        ChildDashboardUiState(
                            child: state.child,
                            tasks: state.tasks,
                            rewards: state.rewards,
                            isLoading: false,
                            error: error.localizedDescription,
                            showScreenTimeDialog: state.showScreenTimeDialog,
                            needsUsagePermission: state.needsUsagePermission,
                            isFocusModeActive: state.isFocusModeActive,
                            focusStartTime: state.focusStartTime,
                            startScreenTimeMinutes: state.startScreenTimeMinutes,
                            focusSessionEarnedPoints: state.focusSessionEarnedPoints,
                            isShopOpen: state.isShopOpen,
                            streak: state.streak
                        )
                    }
                }
            }
        }
    }
    
    /// Start focus mode
    func startFocusMode() {
        guard let child = uiState.child, !uiState.isFocusModeActive else { return }
        
        let startTime = Date()
        
        updateUiState { state in
            ChildDashboardUiState(
                child: state.child,
                tasks: state.tasks,
                rewards: state.rewards,
                isLoading: state.isLoading,
                error: state.error,
                showScreenTimeDialog: false,
                needsUsagePermission: state.needsUsagePermission,
                isFocusModeActive: true,
                focusStartTime: startTime,
                startScreenTimeMinutes: child.dailyScreenTimeUsedMinutes,
                focusSessionEarnedPoints: state.focusSessionEarnedPoints,
                isShopOpen: state.isShopOpen,
                streak: state.streak
            )
        }
        
        // Start focus timer
        startFocusTimer()
    }
    
    /// End focus mode
    func endFocusMode() {
        guard uiState.isFocusModeActive, let startTime = uiState.focusStartTime else { return }
        
        let endTime = Date()
        let focusDuration = endTime.timeIntervalSince(startTime)
        let focusMinutes = Int(focusDuration / 60)
        
        // Calculate earned points (1 point per minute of focus)
        let earnedPoints = max(0, focusMinutes)
        
        // Update child points
        if let child = uiState.child, earnedPoints > 0 {
            childRepository.updatePoints(childId: childId, points: child.points + earnedPoints) { [weak self] _ in
                DispatchQueue.main.async {
                    self?.loadData()
                }
            }
        }
        
        updateUiState { state in
            ChildDashboardUiState(
                child: state.child,
                tasks: state.tasks,
                rewards: state.rewards,
                isLoading: state.isLoading,
                error: state.error,
                showScreenTimeDialog: true,
                needsUsagePermission: state.needsUsagePermission,
                isFocusModeActive: false,
                focusStartTime: nil,
                startScreenTimeMinutes: 0,
                focusSessionEarnedPoints: earnedPoints,
                isShopOpen: state.isShopOpen,
                streak: state.streak
            )
        }
        
        focusTimer?.invalidate()
        focusTimer = nil
    }
    
    /// Open Zebra Shop
    func openShop() {
        updateUiState { state in
            ChildDashboardUiState(
                child: state.child,
                tasks: state.tasks,
                rewards: state.rewards,
                isLoading: state.isLoading,
                error: state.error,
                showScreenTimeDialog: state.showScreenTimeDialog,
                needsUsagePermission: state.needsUsagePermission,
                isFocusModeActive: state.isFocusModeActive,
                focusStartTime: state.focusStartTime,
                startScreenTimeMinutes: state.startScreenTimeMinutes,
                focusSessionEarnedPoints: state.focusSessionEarnedPoints,
                isShopOpen: true,
                streak: state.streak
            )
        }
    }
    
    /// Close Zebra Shop
    func closeShop() {
        updateUiState { state in
            ChildDashboardUiState(
                child: state.child,
                tasks: state.tasks,
                rewards: state.rewards,
                isLoading: state.isLoading,
                error: state.error,
                showScreenTimeDialog: state.showScreenTimeDialog,
                needsUsagePermission: state.needsUsagePermission,
                isFocusModeActive: state.isFocusModeActive,
                focusStartTime: state.focusStartTime,
                startScreenTimeMinutes: state.startScreenTimeMinutes,
                focusSessionEarnedPoints: state.focusSessionEarnedPoints,
                isShopOpen: false,
                streak: state.streak
            )
        }
    }
    
    /// Clear error message
    func clearError() {
        updateUiState { state in
            ChildDashboardUiState(
                child: state.child,
                tasks: state.tasks,
                rewards: state.rewards,
                isLoading: state.isLoading,
                error: nil,
                showScreenTimeDialog: state.showScreenTimeDialog,
                needsUsagePermission: state.needsUsagePermission,
                isFocusModeActive: state.isFocusModeActive,
                focusStartTime: state.focusStartTime,
                startScreenTimeMinutes: state.startScreenTimeMinutes,
                focusSessionEarnedPoints: state.focusSessionEarnedPoints,
                isShopOpen: state.isShopOpen,
                streak: state.streak
            )
        }
    }
    
    // MARK: - Private Methods
    
    private func setupBindings() {
        // Setup any additional bindings if needed
    }
    
    private func loadData() {
        updateUiState { state in
            ChildDashboardUiState(
                child: state.child,
                tasks: state.tasks,
                rewards: state.rewards,
                isLoading: true,
                error: nil,
                showScreenTimeDialog: state.showScreenTimeDialog,
                needsUsagePermission: state.needsUsagePermission,
                isFocusModeActive: state.isFocusModeActive,
                focusStartTime: state.focusStartTime,
                startScreenTimeMinutes: state.startScreenTimeMinutes,
                focusSessionEarnedPoints: state.focusSessionEarnedPoints,
                isShopOpen: state.isShopOpen,
                streak: state.streak
            )
        }
        
        // Combine all data loading using Combine
        let childPublisher = childRepository.getChild(id: childId)
        let tasksPublisher = taskRepository.getTasks(for: childId)
        let rewardsPublisher = rewardRepository.getRewards(for: childId)
        
        Publishers.CombineLatest3(childPublisher, tasksPublisher, rewardsPublisher)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .failure(let error):
                        self?.updateUiState { state in
                            ChildDashboardUiState(
                                child: state.child,
                                tasks: state.tasks,
                                rewards: state.rewards,
                                isLoading: false,
                                error: error.localizedDescription,
                                showScreenTimeDialog: state.showScreenTimeDialog,
                                needsUsagePermission: state.needsUsagePermission,
                                isFocusModeActive: state.isFocusModeActive,
                                focusStartTime: state.focusStartTime,
                                startScreenTimeMinutes: state.startScreenTimeMinutes,
                                focusSessionEarnedPoints: state.focusSessionEarnedPoints,
                                isShopOpen: state.isShopOpen,
                                streak: state.streak
                            )
                        }
                    case .finished:
                        break
                    }
                },
                receiveValue: { [weak self] (child, tasks, rewards) in
                    self?.updateUiState { state in
                        ChildDashboardUiState(
                            child: child,
                            tasks: tasks,
                            rewards: rewards,
                            isLoading: false,
                            error: nil,
                            showScreenTimeDialog: state.showScreenTimeDialog,
                            needsUsagePermission: state.needsUsagePermission,
                            isFocusModeActive: state.isFocusModeActive,
                            focusStartTime: state.focusStartTime,
                            startScreenTimeMinutes: state.startScreenTimeMinutes,
                            focusSessionEarnedPoints: state.focusSessionEarnedPoints,
                            isShopOpen: state.isShopOpen,
                            streak: child.streak
                        )
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    private func updateUiState(with update: (ChildDashboardUiState) -> ChildDashboardUiState) {
        uiState = update(uiState)
    }
    
    private func startFocusTimer() {
        focusTimer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [weak self] _ in
            // Update focus session every minute
            // This could be used to show progress or update screen time
        }
    }
    
    private func playTaskCompletionSound() {
        // Placeholder for sound effect
        // In a real app, you would use AVAudioPlayer or similar
    }
}
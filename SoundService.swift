import Foundation
import AVFoundation

/// Sound service for playing app sounds and effects
/// This replaces the Android SoundManager
class SoundService: ObservableObject {
    static let shared = SoundService()
    
    @Published var isSoundEnabled = true
    @Published var soundVolume: Float = 1.0
    
    private var audioPlayers: [String: AVAudioPlayer] = [:]
    private let userDefaults = UserDefaults.standard
    
    // UserDefaults keys
    private enum Keys {
        static let isSoundEnabled = "isSoundEnabled"
        static let soundVolume = "soundVolume"
    }
    
    // Sound file names
    private enum SoundFiles {
        static let taskComplete = "task_complete"
        static let pointsEarned = "points_earned"
        static let rewardUnlocked = "reward_unlocked"
        static let focusStart = "focus_start"
        static let focusEnd = "focus_end"
        static let buttonTap = "button_tap"
        static let error = "error"
        static let success = "success"
    }
    
    private init() {
        loadSettings()
        configureAudioSession()
    }
    
    // MARK: - Public Methods
    
    /// Play task completion sound
    func playTaskCompletionSound() {
        playSound(named: SoundFiles.taskComplete)
    }
    
    /// Play points earned sound
    func playPointsEarnedSound() {
        playSound(named: SoundFiles.pointsEarned)
    }
    
    /// Play reward unlocked sound
    func playRewardUnlockedSound() {
        playSound(named: SoundFiles.rewardUnlocked)
    }
    
    /// Play focus mode start sound
    func playFocusStartSound() {
        playSound(named: SoundFiles.focusStart)
    }
    
    /// Play focus mode end sound
    func playFocusEndSound() {
        playSound(named: SoundFiles.focusEnd)
    }
    
    /// Play button tap sound
    func playButtonTapSound() {
        playSound(named: SoundFiles.buttonTap)
    }
    
    /// Play error sound
    func playErrorSound() {
        playSound(named: SoundFiles.error)
    }
    
    /// Play success sound
    func playSuccessSound() {
        playSound(named: SoundFiles.success)
    }
    
    /// Enable or disable sounds
    func setSoundEnabled(_ enabled: Bool) {
        isSoundEnabled = enabled
        userDefaults.set(enabled, forKey: Keys.isSoundEnabled)
    }
    
    /// Set sound volume (0.0 to 1.0)
    func setSoundVolume(_ volume: Float) {
        soundVolume = max(0.0, min(1.0, volume))
        userDefaults.set(soundVolume, forKey: Keys.soundVolume)
        
        // Update volume for all players
        for player in audioPlayers.values {
            player.volume = soundVolume
        }
    }
    
    // MARK: - Private Methods
    
    private func loadSettings() {
        isSoundEnabled = userDefaults.bool(forKey: Keys.isSoundEnabled)
        soundVolume = userDefaults.float(forKey: Keys.soundVolume)
        
        // Set defaults if not previously set
        if userDefaults.object(forKey: Keys.isSoundEnabled) == nil {
            isSoundEnabled = true
            userDefaults.set(true, forKey: Keys.isSoundEnabled)
        }
        
        if userDefaults.object(forKey: Keys.soundVolume) == nil {
            soundVolume = 1.0
            userDefaults.set(1.0, forKey: Keys.soundVolume)
        }
    }
    
    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session category: \(error)")
        }
    }
    
    private func playSound(named soundName: String) {
        guard isSoundEnabled else { return }
        
        // Check if we already have a player for this sound
        if let existingPlayer = audioPlayers[soundName] {
            existingPlayer.stop()
            existingPlayer.currentTime = 0
            existingPlayer.volume = soundVolume
            existingPlayer.play()
            return
        }
        
        // Try to load the sound file
        guard let soundURL = Bundle.main.url(forResource: soundName, withExtension: "mp3") ?? 
                           Bundle.main.url(forResource: soundName, withExtension: "wav") else {
            // If sound file doesn't exist, create a simple system sound
            playSystemSound()
            return
        }
        
        do {
            let audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer.volume = soundVolume
            audioPlayer.prepareToPlay()
            audioPlayers[soundName] = audioPlayer
            audioPlayer.play()
        } catch {
            print("Failed to create audio player for \(soundName): \(error)")
            playSystemSound()
        }
    }
    
    private func playSystemSound() {
        // Fallback to system sound if custom sounds aren't available
        AudioServicesPlaySystemSound(1016) // Simple keyboard click sound
    }
}
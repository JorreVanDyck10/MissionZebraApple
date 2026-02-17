import Foundation
import Combine

/// Repository protocol for managing rewards
protocol RewardRepositoryProtocol {
    func getRewards() -> AnyPublisher<[Reward], NetworkError>
    func getRewards(for childId: String) -> AnyPublisher<[Reward], NetworkError>
    func getReward(id: String) -> AnyPublisher<Reward, NetworkError>
    func createReward(_ reward: Reward, completion: @escaping (Result<Reward, NetworkError>) -> Void)
    func updateReward(_ reward: Reward, completion: @escaping (Result<Reward, NetworkError>) -> Void)
    func requestReward(rewardId: String, childId: String, completion: @escaping (Result<Void, NetworkError>) -> Void)
    func redeemReward(rewardId: String, childId: String, completion: @escaping (Result<Void, NetworkError>) -> Void)
    func deleteReward(id: String, completion: @escaping (Result<Void, NetworkError>) -> Void)
}

/// Firebase implementation of RewardRepository
class RewardRepository: RewardRepositoryProtocol, ObservableObject {
    private let networkManager = NetworkManager.shared
    private let rewardsSubject = CurrentValueSubject<[Reward], NetworkError>([])
    
    // MARK: - Public methods
    
    func getRewards() -> AnyPublisher<[Reward], NetworkError> {
        return Future<[Reward], NetworkError> { [weak self] promise in
            guard let self = self else {
                promise(.failure(.unknown(NSError(domain: "RewardRepository", code: 0))))
                return
            }
            
            self.networkManager.get(
                url: APIEndpoints.rewards(),
                type: [String: Reward].self
            ) { result in
                switch result {
                case .success(let rewardsDict):
                    let rewards = Array(rewardsDict.values)
                    promise(.success(rewards))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func getRewards(for childId: String) -> AnyPublisher<[Reward], NetworkError> {
        return Future<[Reward], NetworkError> { [weak self] promise in
            guard let self = self else {
                promise(.failure(.unknown(NSError(domain: "RewardRepository", code: 0))))
                return
            }
            
            self.networkManager.get(
                url: APIEndpoints.childRewards(childId: childId),
                type: [String: Reward].self
            ) { result in
                switch result {
                case .success(let rewardsDict):
                    let rewards = Array(rewardsDict.values).filter { $0.childId == childId }
                    promise(.success(rewards))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func getReward(id: String) -> AnyPublisher<Reward, NetworkError> {
        return Future<Reward, NetworkError> { [weak self] promise in
            guard let self = self else {
                promise(.failure(.unknown(NSError(domain: "RewardRepository", code: 0))))
                return
            }
            
            self.networkManager.get(
                url: APIEndpoints.reward(id: id),
                type: Reward.self
            ) { result in
                switch result {
                case .success(let reward):
                    promise(.success(reward))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func createReward(_ reward: Reward, completion: @escaping (Result<Reward, NetworkError>) -> Void) {
        networkManager.post(
            url: APIEndpoints.rewards(),
            body: reward,
            responseType: Reward.self,
            completion: completion
        )
    }
    
    func updateReward(_ reward: Reward, completion: @escaping (Result<Reward, NetworkError>) -> Void) {
        networkManager.put(
            url: APIEndpoints.reward(id: reward.id),
            body: reward,
            responseType: Reward.self,
            completion: completion
        )
    }
    
    func requestReward(rewardId: String, childId: String, completion: @escaping (Result<Void, NetworkError>) -> Void) {
        // First get the reward, then update it to requested status
        getReward(id: rewardId)
            .sink(
                receiveCompletion: { publisherCompletion in
                    switch publisherCompletion {
                    case .failure(let error):
                        completion(.failure(error))
                    case .finished:
                        break
                    }
                },
                receiveValue: { [weak self] reward in
                    let updatedReward = Reward(
                        id: reward.id,
                        title: reward.title,
                        costPoints: reward.costPoints,
                        childId: reward.childId,
                        redeemed: false,
                        requested: true // Mark as requested
                    )
                    
                    self?.updateReward(updatedReward) { result in
                        switch result {
                        case .success:
                            completion(.success(()))
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                }
            )
            .cancel() // We don't need to store this subscription since it's one-time
    }
    
    func redeemReward(rewardId: String, childId: String, completion: @escaping (Result<Void, NetworkError>) -> Void) {
        // First get the reward, then update it to redeemed status
        getReward(id: rewardId)
            .sink(
                receiveCompletion: { publisherCompletion in
                    switch publisherCompletion {
                    case .failure(let error):
                        completion(.failure(error))
                    case .finished:
                        break
                    }
                },
                receiveValue: { [weak self] reward in
                    let updatedReward = Reward(
                        id: reward.id,
                        title: reward.title,
                        costPoints: reward.costPoints,
                        childId: reward.childId,
                        redeemed: true, // Mark as redeemed
                        requested: false
                    )
                    
                    self?.updateReward(updatedReward) { result in
                        switch result {
                        case .success:
                            completion(.success(()))
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                }
            )
            .cancel() // We don't need to store this subscription since it's one-time
    }
    
    func deleteReward(id: String, completion: @escaping (Result<Void, NetworkError>) -> Void) {
        networkManager.delete(
            url: APIEndpoints.reward(id: id),
            completion: completion
        )
    }
}
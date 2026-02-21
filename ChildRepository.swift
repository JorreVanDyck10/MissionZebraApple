import Foundation
import Combine

/// Repository protocol for managing child data
protocol ChildRepositoryProtocol {
    func getChildren() -> AnyPublisher<[Child], NetworkError>
    func getChild(id: String) -> AnyPublisher<Child, NetworkError>
    func updateChild(_ child: Child, completion: @escaping (Result<Child, NetworkError>) -> Void)
    func updateScreenTime(childId: String, usedMinutes: Int, completion: @escaping (Result<Void, NetworkError>) -> Void)
    func updatePoints(childId: String, points: Int, completion: @escaping (Result<Void, NetworkError>) -> Void)
    func blockChild(childId: String, isBlocked: Bool, completion: @escaping (Result<Void, NetworkError>) -> Void)
}

/// Firebase implementation of ChildRepository
class ChildRepository: ChildRepositoryProtocol, ObservableObject {
    private let networkManager = NetworkManager.shared
    private let childrenSubject = CurrentValueSubject<[Child], NetworkError>([])
    
    // MARK: - Public methods
    
    func getChildren() -> AnyPublisher<[Child], NetworkError> {
        return Future<[Child], NetworkError> { [weak self] promise in
            guard let self = self else {
                promise(.failure(.unknown(NSError(domain: "ChildRepository", code: 0))))
                return
            }
            
            self.networkManager.get(
                url: APIEndpoints.children(),
                type: [String: Child].self
            ) { result in
                switch result {
                case .success(let childrenDict):
                    let children = Array(childrenDict.values)
                    promise(.success(children))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func getChild(id: String) -> AnyPublisher<Child, NetworkError> {
        return Future<Child, NetworkError> { [weak self] promise in
            guard let self = self else {
                promise(.failure(.unknown(NSError(domain: "ChildRepository", code: 0))))
                return
            }
            
            self.networkManager.get(
                url: APIEndpoints.child(id: id),
                type: Child.self
            ) { result in
                switch result {
                case .success(let child):
                    promise(.success(child))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func updateChild(_ child: Child, completion: @escaping (Result<Child, NetworkError>) -> Void) {
        networkManager.put(
            url: APIEndpoints.child(id: child.id),
            body: child,
            responseType: Child.self,
            completion: completion
        )
    }
    
    func updateScreenTime(childId: String, usedMinutes: Int, completion: @escaping (Result<Void, NetworkError>) -> Void) {
        // First get the child, then update screen time
        getChild(id: childId)
            .sink(
                receiveCompletion: { publisherCompletion in
                    switch publisherCompletion {
                    case .failure(let error):
                        completion(.failure(error))
                    case .finished:
                        break
                    }
                },
                receiveValue: { [weak self] child in
                    let updatedChild = Child(
                        id: child.id,
                        name: child.name,
                        points: child.points,
                        dailyScreenTimeUsedMinutes: usedMinutes,
                        dailyScreenTimeLimitMinutes: child.dailyScreenTimeLimitMinutes,
                        isBlocked: child.isBlocked,
                        purchasedAccessoryIds: child.purchasedAccessoryIds,
                        equippedAccessoryId: child.equippedAccessoryId,
                        streak: child.streak,
                        lastStreakCheckDate: child.lastStreakCheckDate,
                        motivationalMessage: child.motivationalMessage,
                        screenTimeHistory: child.screenTimeHistory
                    )
                    
                    self?.updateChild(updatedChild) { result in
                        switch result {
                        case .success:
                            completion(.success(()))
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                }
            )
            .cancel()
    }
    
    func updatePoints(childId: String, points: Int, completion: @escaping (Result<Void, NetworkError>) -> Void) {
        // First get the child, then update points
        getChild(id: childId)
            .sink(
                receiveCompletion: { publisherCompletion in
                    switch publisherCompletion {
                    case .failure(let error):
                        completion(.failure(error))
                    case .finished:
                        break
                    }
                },
                receiveValue: { [weak self] child in
                    let updatedChild = Child(
                        id: child.id,
                        name: child.name,
                        points: points,
                        dailyScreenTimeUsedMinutes: child.dailyScreenTimeUsedMinutes,
                        dailyScreenTimeLimitMinutes: child.dailyScreenTimeLimitMinutes,
                        isBlocked: child.isBlocked,
                        purchasedAccessoryIds: child.purchasedAccessoryIds,
                        equippedAccessoryId: child.equippedAccessoryId,
                        streak: child.streak,
                        lastStreakCheckDate: child.lastStreakCheckDate,
                        motivationalMessage: child.motivationalMessage,
                        screenTimeHistory: child.screenTimeHistory
                    )
                    
                    self?.updateChild(updatedChild) { result in
                        switch result {
                        case .success:
                            completion(.success(()))
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                }
            )
            .cancel()
    }
    
    func blockChild(childId: String, isBlocked: Bool, completion: @escaping (Result<Void, NetworkError>) -> Void) {
        // First get the child, then update block status
        getChild(id: childId)
            .sink(
                receiveCompletion: { publisherCompletion in
                    switch publisherCompletion {
                    case .failure(let error):
                        completion(.failure(error))
                    case .finished:
                        break
                    }
                },
                receiveValue: { [weak self] child in
                    let updatedChild = Child(
                        id: child.id,
                        name: child.name,
                        points: child.points,
                        dailyScreenTimeUsedMinutes: child.dailyScreenTimeUsedMinutes,
                        dailyScreenTimeLimitMinutes: child.dailyScreenTimeLimitMinutes,
                        isBlocked: isBlocked,
                        purchasedAccessoryIds: child.purchasedAccessoryIds,
                        equippedAccessoryId: child.equippedAccessoryId,
                        streak: child.streak,
                        lastStreakCheckDate: child.lastStreakCheckDate,
                        motivationalMessage: child.motivationalMessage,
                        screenTimeHistory: child.screenTimeHistory
                    )
                    
                    self?.updateChild(updatedChild) { result in
                        switch result {
                        case .success:
                            completion(.success(()))
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                }
            )
            .cancel()
    }
}
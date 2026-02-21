import Foundation
import Combine

/// Repository protocol for managing Zebra Shop accessories
protocol ZebraShopRepositoryProtocol {
    func getAccessories() -> AnyPublisher<[Accessory], NetworkError>
    func getAccessory(id: String) -> AnyPublisher<Accessory, NetworkError>
    func purchaseAccessory(accessoryId: String, childId: String, completion: @escaping (Result<Void, NetworkError>) -> Void)
    func equipAccessory(accessoryId: String, childId: String, completion: @escaping (Result<Void, NetworkError>) -> Void)
}

/// Firebase implementation of ZebraShopRepository
class ZebraShopRepository: ZebraShopRepositoryProtocol, ObservableObject {
    private let networkManager = NetworkManager.shared
    private let childRepository = ChildRepository()
    
    // Default accessories for the Zebra Shop
    private let defaultAccessories = [
        Accessory(id: "hat1", name: "Cowboyhoed", price: 50, emoji: "🤠", description: "Een stoere cowboyhoed voor echte avonturiers"),
        Accessory(id: "hat2", name: "Feesthoed", price: 30, emoji: "🥳", description: "Een vrolijke feesthoed voor speciale gelegenheden"),
        Accessory(id: "sunglasses", name: "Zonnebril", price: 40, emoji: "😎", description: "Coole zonnebril om er stijlvol uit te zien"),
        Accessory(id: "crown", name: "Kroon", price: 100, emoji: "👑", description: "Een koninklijke kroon voor echte winnaars"),
        Accessory(id: "cap", name: "Baseballcap", price: 25, emoji: "🧢", description: "Een sportieve cap voor actieve dagen"),
        Accessory(id: "tophat", name: "Hoge hoed", price: 75, emoji: "🎩", description: "Een elegante hoge hoed voor formele gelegenheden"),
        Accessory(id: "helmet", name: "Helm", price: 60, emoji: "⛑️", description: "Een veiligheidshelm voor spannende avonturen"),
        Accessory(id: "beret", name: "Beret", price: 35, emoji: "👨‍🎨", description: "Een artistieke beret voor creatieve geesten")
    ]
    
    // MARK: - Public methods
    
    func getAccessories() -> AnyPublisher<[Accessory], NetworkError> {
        return Future<[Accessory], NetworkError> { [weak self] promise in
            guard let self = self else {
                promise(.failure(.unknown(NSError(domain: "ZebraShopRepository", code: 0))))
                return
            }
            
            // First try to get accessories from Firebase
            self.networkManager.get(
                url: APIEndpoints.accessories(),
                type: [String: Accessory].self
            ) { [weak self] result in
                switch result {
                case .success(let accessoriesDict):
                    let accessories = Array(accessoriesDict.values)
                    promise(.success(accessories))
                case .failure:
                    // If Firebase fails, return default accessories
                    promise(.success(self?.defaultAccessories ?? []))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func getAccessory(id: String) -> AnyPublisher<Accessory, NetworkError> {
        return Future<Accessory, NetworkError> { [weak self] promise in
            guard let self = self else {
                promise(.failure(.unknown(NSError(domain: "ZebraShopRepository", code: 0))))
                return
            }
            
            // First try to get accessory from Firebase
            self.networkManager.get(
                url: APIEndpoints.accessory(id: id),
                type: Accessory.self
            ) { [weak self] result in
                switch result {
                case .success(let accessory):
                    promise(.success(accessory))
                case .failure:
                    // If Firebase fails, try to find in default accessories
                    if let accessory = self?.defaultAccessories.first(where: { $0.id == id }) {
                        promise(.success(accessory))
                    } else {
                        promise(.failure(.noData))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func purchaseAccessory(accessoryId: String, childId: String, completion: @escaping (Result<Void, NetworkError>) -> Void) {
        // Get child data first
        childRepository.getChild(id: childId)
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
                    // Get accessory price
                    self?.getAccessory(id: accessoryId)
                        .sink(
                            receiveCompletion: { publisherCompletion in
                                switch publisherCompletion {
                                case .failure(let error):
                                    completion(.failure(error))
                                case .finished:
                                    break
                                }
                            },
                            receiveValue: { [weak self] accessory in
                                // Check if child has enough points
                                guard child.points >= accessory.price else {
                                    completion(.failure(.unknown(NSError(domain: "ZebraShop", code: 1, userInfo: [NSLocalizedDescriptionKey: "Niet genoeg punten"]))))
                                    return
                                }
                                
                                // Check if already purchased
                                guard !child.purchasedAccessoryIds.contains(accessoryId) else {
                                    completion(.failure(.unknown(NSError(domain: "ZebraShop", code: 2, userInfo: [NSLocalizedDescriptionKey: "Al gekocht"]))))
                                    return
                                }
                                
                                // Update child with purchase
                                let updatedChild = Child(
                                    id: child.id,
                                    name: child.name,
                                    points: child.points - accessory.price,
                                    dailyScreenTimeUsedMinutes: child.dailyScreenTimeUsedMinutes,
                                    dailyScreenTimeLimitMinutes: child.dailyScreenTimeLimitMinutes,
                                    isBlocked: child.isBlocked,
                                    purchasedAccessoryIds: child.purchasedAccessoryIds + [accessoryId],
                                    equippedAccessoryId: child.equippedAccessoryId,
                                    streak: child.streak,
                                    lastStreakCheckDate: child.lastStreakCheckDate,
                                    motivationalMessage: child.motivationalMessage,
                                    screenTimeHistory: child.screenTimeHistory
                                )
                                
                                self?.childRepository.updateChild(updatedChild) { result in
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
            )
            .cancel()
    }
    
    func equipAccessory(accessoryId: String, childId: String, completion: @escaping (Result<Void, NetworkError>) -> Void) {
        // Get child data first
        childRepository.getChild(id: childId)
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
                    // Check if accessory is purchased
                    guard child.purchasedAccessoryIds.contains(accessoryId) else {
                        completion(.failure(.unknown(NSError(domain: "ZebraShop", code: 3, userInfo: [NSLocalizedDescriptionKey: "Accessoire niet gekocht"]))))
                        return
                    }
                    
                    // Update child with equipped accessory
                    let updatedChild = Child(
                        id: child.id,
                        name: child.name,
                        points: child.points,
                        dailyScreenTimeUsedMinutes: child.dailyScreenTimeUsedMinutes,
                        dailyScreenTimeLimitMinutes: child.dailyScreenTimeLimitMinutes,
                        isBlocked: child.isBlocked,
                        purchasedAccessoryIds: child.purchasedAccessoryIds,
                        equippedAccessoryId: accessoryId,
                        streak: child.streak,
                        lastStreakCheckDate: child.lastStreakCheckDate,
                        motivationalMessage: child.motivationalMessage,
                        screenTimeHistory: child.screenTimeHistory
                    )
                    
                    self?.childRepository.updateChild(updatedChild) { result in
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
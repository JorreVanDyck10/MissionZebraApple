import Foundation
import Combine

/// Repository protocol for managing tasks
protocol TaskRepositoryProtocol {
    func getTasks() -> AnyPublisher<[Task], NetworkError>
    func getTasks(for childId: String) -> AnyPublisher<[Task], NetworkError>
    func getTask(id: String) -> AnyPublisher<Task, NetworkError>
    func createTask(_ task: Task, completion: @escaping (Result<Task, NetworkError>) -> Void)
    func updateTask(_ task: Task, completion: @escaping (Result<Task, NetworkError>) -> Void)
    func completeTask(taskId: String, childId: String, completion: @escaping (Result<Void, NetworkError>) -> Void)
    func deleteTask(id: String, completion: @escaping (Result<Void, NetworkError>) -> Void)
}

/// Firebase implementation of TaskRepository
class TaskRepository: TaskRepositoryProtocol, ObservableObject {
    private let networkManager = NetworkManager.shared
    private let tasksSubject = CurrentValueSubject<[Task], NetworkError>([])
    
    // MARK: - Public methods
    
    func getTasks() -> AnyPublisher<[Task], NetworkError> {
        return Future<[Task], NetworkError> { [weak self] promise in
            guard let self = self else {
                promise(.failure(.unknown(NSError(domain: "TaskRepository", code: 0))))
                return
            }
            
            self.networkManager.get(
                url: APIEndpoints.tasks(),
                type: [String: Task].self
            ) { result in
                switch result {
                case .success(let tasksDict):
                    let tasks = Array(tasksDict.values)
                    promise(.success(tasks))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func getTasks(for childId: String) -> AnyPublisher<[Task], NetworkError> {
        return Future<[Task], NetworkError> { [weak self] promise in
            guard let self = self else {
                promise(.failure(.unknown(NSError(domain: "TaskRepository", code: 0))))
                return
            }
            
            self.networkManager.get(
                url: APIEndpoints.childTasks(childId: childId),
                type: [String: Task].self
            ) { result in
                switch result {
                case .success(let tasksDict):
                    let tasks = Array(tasksDict.values).filter { $0.childId == childId }
                    promise(.success(tasks))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func getTask(id: String) -> AnyPublisher<Task, NetworkError> {
        return Future<Task, NetworkError> { [weak self] promise in
            guard let self = self else {
                promise(.failure(.unknown(NSError(domain: "TaskRepository", code: 0))))
                return
            }
            
            self.networkManager.get(
                url: APIEndpoints.task(id: id),
                type: Task.self
            ) { result in
                switch result {
                case .success(let task):
                    promise(.success(task))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func createTask(_ task: Task, completion: @escaping (Result<Task, NetworkError>) -> Void) {
        networkManager.post(
            url: APIEndpoints.tasks(),
            body: task,
            responseType: Task.self,
            completion: completion
        )
    }
    
    func updateTask(_ task: Task, completion: @escaping (Result<Task, NetworkError>) -> Void) {
        networkManager.put(
            url: APIEndpoints.task(id: task.id),
            body: task,
            responseType: Task.self,
            completion: completion
        )
    }
    
    func completeTask(taskId: String, childId: String, completion: @escaping (Result<Void, NetworkError>) -> Void) {
        // First get the task, then update it
        getTask(id: taskId)
            .sink(
                receiveCompletion: { publisherCompletion in
                    switch publisherCompletion {
                    case .failure(let error):
                        completion(.failure(error))
                    case .finished:
                        break
                    }
                },
                receiveValue: { [weak self] task in
                    let updatedTask = Task(
                        id: task.id,
                        title: task.title,
                        points: task.points,
                        childId: task.childId,
                        childName: task.childName,
                        parentId: task.parentId,
                        pendingApproval: true, // Mark as pending approval when completed
                        completed: false
                    )
                    
                    self?.updateTask(updatedTask) { result in
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
    
    func deleteTask(id: String, completion: @escaping (Result<Void, NetworkError>) -> Void) {
        networkManager.delete(
            url: APIEndpoints.task(id: id),
            completion: completion
        )
    }
}
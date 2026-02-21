import Foundation
import Combine

/// Network manager that replaces Retrofit with URLSession for iOS 15 compatibility
class NetworkManager: ObservableObject {
    static let shared = NetworkManager()
    
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30.0
        config.timeoutIntervalForResource = 60.0
        
        self.session = URLSession(configuration: config)
        self.decoder = JSONDecoder()
        self.encoder = JSONEncoder()
        
        // Configure date formatting if needed
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        encoder.dateEncodingStrategy = .formatted(dateFormatter)
    }
    
    // MARK: - Generic network methods compatible with Swift 5.5
    
    /// Generic GET request
    func get<T: Decodable>(
        url: String,
        type: T.Type,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        guard let url = URL(string: url) else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.GET.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        performRequest(request: request, responseType: type, completion: completion)
    }
    
    /// Generic POST request
    func post<T: Codable, U: Decodable>(
        url: String,
        body: T,
        responseType: U.Type,
        completion: @escaping (Result<U, NetworkError>) -> Void
    ) {
        guard let url = URL(string: url) else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.POST.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try encoder.encode(body)
        } catch {
            completion(.failure(.encodingError(error)))
            return
        }
        
        performRequest(request: request, responseType: responseType, completion: completion)
    }
    
    /// Generic PUT request
    func put<T: Codable, U: Decodable>(
        url: String,
        body: T,
        responseType: U.Type,
        completion: @escaping (Result<U, NetworkError>) -> Void
    ) {
        guard let url = URL(string: url) else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.PUT.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try encoder.encode(body)
        } catch {
            completion(.failure(.encodingError(error)))
            return
        }
        
        performRequest(request: request, responseType: responseType, completion: completion)
    }
    
    /// Generic PATCH request
    func patch<T: Codable, U: Decodable>(
        url: String,
        body: T,
        responseType: U.Type,
        completion: @escaping (Result<U, NetworkError>) -> Void
    ) {
        guard let url = URL(string: url) else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.PATCH.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try encoder.encode(body)
        } catch {
            completion(.failure(.encodingError(error)))
            return
        }
        
        performRequest(request: request, responseType: responseType, completion: completion)
    }
    
    /// Generic DELETE request
    func delete(
        url: String,
        completion: @escaping (Result<Void, NetworkError>) -> Void
    ) {
        guard let url = URL(string: url) else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.DELETE.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        performVoidRequest(request: request, completion: completion)
    }
    
    // MARK: - Private helper methods
    
    private func performRequest<T: Decodable>(
        request: URLRequest,
        responseType: T.Type,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        session.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    if (error as NSError).code == NSURLErrorNotConnectedToInternet {
                        completion(.failure(.networkUnavailable))
                    } else if (error as NSError).code == NSURLErrorTimedOut {
                        completion(.failure(.timeout))
                    } else {
                        completion(.failure(.unknown(error)))
                    }
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(.unknown(NSError(domain: "NetworkManager", code: 0, userInfo: nil))))
                    return
                }
                
                guard 200...299 ~= httpResponse.statusCode else {
                    completion(.failure(.httpError(httpResponse.statusCode)))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(.noData))
                    return
                }
                
                guard let decoder = self?.decoder else {
                    completion(.failure(.unknown(NSError(domain: "NetworkManager", code: 0, userInfo: nil))))
                    return
                }
                
                do {
                    let decodedData = try decoder.decode(responseType, from: data)
                    completion(.success(decodedData))
                } catch {
                    completion(.failure(.decodingError(error)))
                }
            }
        }.resume()
    }
    
    private func performVoidRequest(
        request: URLRequest,
        completion: @escaping (Result<Void, NetworkError>) -> Void
    ) {
        session.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    if (error as NSError).code == NSURLErrorNotConnectedToInternet {
                        completion(.failure(.networkUnavailable))
                    } else if (error as NSError).code == NSURLErrorTimedOut {
                        completion(.failure(.timeout))
                    } else {
                        completion(.failure(.unknown(error)))
                    }
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(.unknown(NSError(domain: "NetworkManager", code: 0, userInfo: nil))))
                    return
                }
                
                guard 200...299 ~= httpResponse.statusCode else {
                    completion(.failure(.httpError(httpResponse.statusCode)))
                    return
                }
                
                completion(.success(()))
            }
        }.resume()
    }
}
import Foundation

/// Network errors that can occur during API calls
enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError(Error)
    case encodingError(Error)
    case httpError(Int)
    case networkUnavailable
    case timeout
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Ongeldige URL"
        case .noData:
            return "Geen data ontvangen"
        case .decodingError(let error):
            return "Fout bij decoderen: \(error.localizedDescription)"
        case .encodingError(let error):
            return "Fout bij encoderen: \(error.localizedDescription)"
        case .httpError(let code):
            return "HTTP fout: \(code)"
        case .networkUnavailable:
            return "Geen internetverbinding"
        case .timeout:
            return "Verzoek verlopen"
        case .unknown(let error):
            return "Onbekende fout: \(error.localizedDescription)"
        }
    }
}
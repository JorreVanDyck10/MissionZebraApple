import Foundation

/// Accessory model representing items that can be purchased in the Zebra Shop
struct Accessory: Identifiable, Codable {
    let id: String
    let name: String
    let price: Int
    let emoji: String
    let description: String
    
    init(id: String,
         name: String,
         price: Int,
         emoji: String,
         description: String = "") {
        self.id = id
        self.name = name
        self.price = price
        self.emoji = emoji
        self.description = description
    }
}

// MARK: - Computed Properties
extension Accessory {
    /// Formatted price string for display
    var formattedPrice: String {
        "\(price) punten"
    }
}
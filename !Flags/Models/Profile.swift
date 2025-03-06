import Foundation

struct Profile: Codable {
    var name: String
    var avatarName: String
    var isPro: Bool
    var scores: [String: Int]
    
    init(name: String = "Гість", avatarName: String = "🌍", isPro: Bool = false) {
        self.name = name
        self.avatarName = avatarName
        self.isPro = isPro
        self.scores = [:]
    }
} 
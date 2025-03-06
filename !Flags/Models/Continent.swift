import Foundation

enum Continent: String, CaseIterable, Codable, Identifiable {
    case europe = "europe"
    case asia = "asia"
    case northAmerica = "northAmerica"
    case southAmerica = "southAmerica"
    case africa = "africa"
    case oceania = "oceania"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .europe:
            return "🏰"
        case .asia:
            return "🗻"
        case .northAmerica:
            return "🗽"
        case .southAmerica:
            return "🌋"
        case .africa:
            return "🐘"
        case .oceania:
            return "🦘"
        }
    }
    
    var description: String {
        switch self {
        case .europe:
            return "Старий світ"
        case .asia:
            return "Колиска цивілізацій"
        case .northAmerica:
            return "Новий світ"
        case .southAmerica:
            return "Земля інків"
        case .africa:
            return "Чорний континент"
        case .oceania:
            return "Світ островів"
        }
    }
    
    var localizedName: String {
        switch self {
        case .europe: return "Європа"
        case .asia: return "Азія"
        case .northAmerica: return "Північна Америка"
        case .southAmerica: return "Південна Америка"
        case .africa: return "Африка"
        case .oceania: return "Океанія"
        }
    }
} 
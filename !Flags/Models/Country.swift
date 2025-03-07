import Foundation
import SwiftUI

struct Country: Codable, Identifiable {
    let id: String
    let name: String
    let capital: String
    let population: String
    let continent: Continent
    let isIsland: Bool
    let flagImageName: String
    let funFact: String
    
    // Localized names
    var localizedName: String {
        // Get localized name from Localizable.strings
        let key = "country.\(id)"
        let localizedName = NSLocalizedString(key, comment: "")
        // If no localization found, return original name
        return localizedName == key ? name : localizedName
    }
    
    // Localized capital
    var localizedCapital: String {
        // Convert capital to lowercase and replace spaces with underscores
        let capitalKey = capital.lowercased()
            .replacingOccurrences(of: " ", with: "_")
            .folding(options: .diacriticInsensitive, locale: .current)
        let key = "capital.\(capitalKey)"
        let localizedCapital = NSLocalizedString(key, comment: "")
        // If no localization found, return original capital
        return localizedCapital == key ? capital : localizedCapital
    }
    
    // Localized fun fact
    var localizedFunFact: String {
        let key = "funfact.\(id)"
        let localizedFunFact = NSLocalizedString(key, comment: "")
        // If no localization found, return original fun fact
        return localizedFunFact == key ? funFact : localizedFunFact
    }
    
    private enum CodingKeys: String, CodingKey {
        case name, capital, population, flagImageName, funFact
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        name = try container.decode(String.self, forKey: .name)
        capital = try container.decode(String.self, forKey: .capital)
        population = try container.decode(String.self, forKey: .population)
        flagImageName = try container.decode(String.self, forKey: .flagImageName)
        funFact = try container.decode(String.self, forKey: .funFact)
        
        // Generate ID from country name
        id = name.lowercased()
            .replacingOccurrences(of: " ", with: "_")
            .folding(options: .diacriticInsensitive, locale: .current)
        print("🆔 Created ID for country \(name): \(id)")
        
        // Determine continent based on JSON structure
        let continentString = decoder.codingPath.first?.stringValue ?? "europe"
        continent = Continent(rawValue: continentString) ?? .europe
        
        // Set isIsland to false by default
        isIsland = false
    }
    
    // Preview and testing initializer
    init(id: String = UUID().uuidString,
         name: String,
         capital: String,
         population: String,
         continent: Continent,
         isIsland: Bool = false,
         flagImageName: String,
         funFact: String) {
        self.id = id
        self.name = name
        self.capital = capital
        self.population = population
        self.continent = continent
        self.isIsland = isIsland
        self.flagImageName = flagImageName
        self.funFact = funFact
    }
}

enum Continent: String, Codable, CaseIterable {
    case europe = "europe"
    case asia = "asia"
    case northAmerica = "northAmerica"
    case southAmerica = "southAmerica"
    case africa = "africa"
    case oceania = "oceania"
    case antarctica = "antarctica"
    
    var localizedName: String {
        switch self {
        case .europe: return L10n.Continent.europe.localized
        case .asia: return L10n.Continent.asia.localized
        case .northAmerica: return L10n.Continent.northAmerica.localized
        case .southAmerica: return L10n.Continent.southAmerica.localized
        case .africa: return L10n.Continent.africa.localized
        case .oceania: return L10n.Continent.oceania.localized
        case .antarctica: return L10n.Continent.antarctica.localized
        }
    }
    
    var countryCount: String {
        let count = countries.count
        return L10n.Continent.countryCount.localized([count])
    }
    
    private var gradientColors: (start: Color, end: Color) {
        switch self {
        case .europe:
            return (.init(red: 0.4, green: 0.6, blue: 1.0), .init(red: 0.6, green: 0.5, blue: 1.0))
        case .asia:
            return (.init(red: 1.0, green: 0.5, blue: 0.5), .init(red: 0.4, green: 0.6, blue: 1.0))
        case .northAmerica:
            return (.init(red: 0.4, green: 0.8, blue: 1.0), .init(red: 0.2, green: 0.6, blue: 0.8))
        case .southAmerica:
            return (.init(red: 0.6, green: 0.4, blue: 1.0), .init(red: 0.4, green: 0.2, blue: 0.8))
        case .africa:
            return (.init(red: 1.0, green: 0.8, blue: 0.4), .init(red: 0.6, green: 0.8, blue: 0.4))
        case .oceania:
            return (.init(red: 0.4, green: 0.6, blue: 1.0), .init(red: 0.5, green: 0.5, blue: 0.9))
        case .antarctica:
            return (.init(red: 0.8, green: 0.9, blue: 1.0), .white)
        }
    }
    
    var gradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [gradientColors.start, gradientColors.end]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var startColor: Color {
        gradientColors.start
    }
    
    var endColor: Color {
        gradientColors.end
    }
    
    var countries: [Country] {
        return CountryService.shared.getCountriesForContinent(self)
    }
} 
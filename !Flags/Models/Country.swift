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
        let key = "country.\(flagImageName)"
        let localizedString = Bundle.main.localizedString(forKey: key, value: nil, table: "Localizable")
        // If key wasn't found (returns the same key), use JSON value
        return localizedString == key ? name : localizedString
    }
    
    // Localized capital
    var localizedCapital: String {
        let key = "capital.\(flagImageName)"
        let localizedString = Bundle.main.localizedString(forKey: key, value: nil, table: "Localizable")
        // If key wasn't found (returns the same key), use JSON value
        return localizedString == key ? capital : localizedString
    }
    
    // Localized fun fact
    var localizedFunFact: String {
        let key = "funfact.\(flagImageName)"
        let localizedString = Bundle.main.localizedString(forKey: key, value: nil, table: "Localizable")
        // If key wasn't found (returns the same key), use JSON value
        return localizedString == key ? funFact : localizedString
    }
    
    // Localized population
    var localizedPopulation: String {
        let currentLocale = Bundle.main.preferredLocalizations.first ?? "en"
        
        if currentLocale.hasPrefix("uk") || currentLocale.hasPrefix("pl") {
            // Handle different number formats
            let populationLower = population.lowercased()
            
            // Handle "million"
            if populationLower.contains("million") {
                let numStr = populationLower.replacingOccurrences(of: " million", with: "")
                if let num = Double(numStr) {
                    if currentLocale.hasPrefix("uk") {
                        return String(format: "%.1f млн", num)
                    } else if currentLocale.hasPrefix("pl") {
                        return String(format: "%.1f mln", num)
                    }
                }
            }
            // Handle "M"
            else if populationLower.hasSuffix("m") {
                let numStr = populationLower.replacingOccurrences(of: "m", with: "")
                if let num = Double(numStr) {
                    if currentLocale.hasPrefix("uk") {
                        return String(format: "%.1f млн", num)
                    } else if currentLocale.hasPrefix("pl") {
                        return String(format: "%.1f mln", num)
                    }
                }
            }
            // Handle "thousand"
            else if populationLower.contains("thousand") {
                let numStr = populationLower.replacingOccurrences(of: " thousand", with: "")
                if let num = Double(numStr) {
                    if currentLocale.hasPrefix("uk") {
                        return String(format: "%.0f тис", num)
                    } else if currentLocale.hasPrefix("pl") {
                        return String(format: "%.0f tys", num)
                    }
                }
            }
            // Handle "K"
            else if populationLower.hasSuffix("k") {
                let numStr = populationLower.replacingOccurrences(of: "k", with: "")
                if let num = Double(numStr) {
                    if currentLocale.hasPrefix("uk") {
                        return String(format: "%.0f тис", num)
                    } else if currentLocale.hasPrefix("pl") {
                        return String(format: "%.0f tys", num)
                    }
                }
            }
            // Handle "billion"
            else if populationLower.contains("billion") {
                let numStr = populationLower.replacingOccurrences(of: " billion", with: "")
                if let num = Double(numStr) {
                    if currentLocale.hasPrefix("uk") {
                        return String(format: "%.2f млрд", num)
                    } else if currentLocale.hasPrefix("pl") {
                        return String(format: "%.2f mld", num)
                    }
                }
            }
            // Handle "B"
            else if populationLower.hasSuffix("b") {
                let numStr = populationLower.replacingOccurrences(of: "b", with: "")
                if let num = Double(numStr) {
                    if currentLocale.hasPrefix("uk") {
                        return String(format: "%.2f млрд", num)
                    } else if currentLocale.hasPrefix("pl") {
                        return String(format: "%.2f mld", num)
                    }
                }
            }
            // Handle raw numbers (no suffix)
            else if let num = Double(populationLower.replacingOccurrences(of: ",", with: "")) {
                if num >= 1_000_000_000 {
                    if currentLocale.hasPrefix("uk") {
                        return String(format: "%.2f млрд", num / 1_000_000_000)
                    } else if currentLocale.hasPrefix("pl") {
                        return String(format: "%.2f mld", num / 1_000_000_000)
                    }
                } else if num >= 1_000_000 {
                    if currentLocale.hasPrefix("uk") {
                        return String(format: "%.1f млн", num / 1_000_000)
                    } else if currentLocale.hasPrefix("pl") {
                        return String(format: "%.1f mln", num / 1_000_000)
                    }
                } else if num >= 1_000 {
                    if currentLocale.hasPrefix("uk") {
                        return String(format: "%.0f тис", num / 1_000)
                    } else if currentLocale.hasPrefix("pl") {
                        return String(format: "%.0f tys", num / 1_000)
                    }
                } else {
                    return String(format: "%.0f", num)
                }
            }
        }
        
        return population
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
        
        // Generate ID from flagImageName
        id = flagImageName
        
        // Determine continent based on JSON structure
        let continentString = decoder.codingPath.first?.stringValue ?? "europe"
        print("🌍 Decoding country: \(name)")
        print("🌐 Continent string from JSON path: \(continentString)")
        print("📍 Full coding path: \(decoder.codingPath.map { $0.stringValue })")
        continent = Continent(rawValue: continentString) ?? .europe
        print("🌎 Final continent value: \(continent)")
        
        print("🌍 Created country: \(name)")
        print("🆔 ID: \(id)")
        print("🌐 Continent: \(continent)")
        print("🏁 Flag image: \(flagImageName)")
        print("------------------")
        
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
        let count = CountryService.shared.getCountriesCount(for: self)
        return String(format: "continent.country_count".localized, count)
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